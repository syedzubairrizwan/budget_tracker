import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/planned_payments/planned_payment_repository.dart';
import 'package:budget_tracker/models/planned_payment.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class PlannedPaymentEvent {}

class LoadPlannedPayments extends PlannedPaymentEvent {}

class AddPlannedPayment extends PlannedPaymentEvent {
  final PlannedPayment payment;
  AddPlannedPayment(this.payment);
}

class UpdatePlannedPayment extends PlannedPaymentEvent {
  final PlannedPayment payment;
  UpdatePlannedPayment(this.payment);
}

class DeletePlannedPayment extends PlannedPaymentEvent {
  final String id;
  DeletePlannedPayment(this.id);
}

/// Marks a planned payment as paid and dispatches a real Transaction.
/// [transactionBloc] is passed so the BLoC can emit to TransactionBloc.
class MarkPlannedPaymentPaid extends PlannedPaymentEvent {
  final PlannedPayment payment;
  final TransactionBloc transactionBloc;
  MarkPlannedPaymentPaid({required this.payment, required this.transactionBloc});
}

// ─── States ─────────────────────────────────────────────────────────────────

abstract class PlannedPaymentState {}

class PlannedPaymentInitial extends PlannedPaymentState {}

class PlannedPaymentLoading extends PlannedPaymentState {}

class PlannedPaymentLoaded extends PlannedPaymentState {
  final List<PlannedPayment> payments;
  PlannedPaymentLoaded(this.payments);
}

class PlannedPaymentError extends PlannedPaymentState {
  final String message;
  PlannedPaymentError(this.message);
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class PlannedPaymentBloc extends Bloc<PlannedPaymentEvent, PlannedPaymentState> {
  final PlannedPaymentRepository _repository;
  final NotificationService _notificationService;

  PlannedPaymentBloc({
    required PlannedPaymentRepository repository,
    required NotificationService notificationService,
  })  : _repository = repository,
        _notificationService = notificationService,
        super(PlannedPaymentInitial()) {
    on<LoadPlannedPayments>(_onLoad);
    on<AddPlannedPayment>(_onAdd);
    on<UpdatePlannedPayment>(_onUpdate);
    on<DeletePlannedPayment>(_onDelete);
    on<MarkPlannedPaymentPaid>(_onMarkPaid);
  }

  Future<void> _onLoad(
      LoadPlannedPayments event, Emitter<PlannedPaymentState> emit) async {
    emit(PlannedPaymentLoading());
    try {
      final payments = await _repository.getAll();
      // Sort: unpaid first (overdue at top), then paid
      payments.sort((a, b) {
        if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
        return a.dueDate.compareTo(b.dueDate);
      });
      emit(PlannedPaymentLoaded(payments));
    } catch (e) {
      emit(PlannedPaymentError(e.toString()));
    }
  }

  Future<void> _onAdd(
      AddPlannedPayment event, Emitter<PlannedPaymentState> emit) async {
    try {
      await _repository.add(event.payment);
      // Schedule notification if enabled
      if (event.payment.notificationEnabled) {
        await _scheduleNotification(event.payment);
      }
      add(LoadPlannedPayments());
    } catch (e) {
      emit(PlannedPaymentError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdatePlannedPayment event, Emitter<PlannedPaymentState> emit) async {
    try {
      await _repository.update(event.payment);
      add(LoadPlannedPayments());
    } catch (e) {
      emit(PlannedPaymentError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeletePlannedPayment event, Emitter<PlannedPaymentState> emit) async {
    try {
      await _repository.delete(event.id);
      add(LoadPlannedPayments());
    } catch (e) {
      emit(PlannedPaymentError(e.toString()));
    }
  }

  Future<void> _onMarkPaid(
      MarkPlannedPaymentPaid event, Emitter<PlannedPaymentState> emit) async {
    try {
      final paid = event.payment.copyWith(
        isPaid: true,
        paidDate: DateTime.now(),
      );
      await _repository.update(paid);

      // Dispatch a real Transaction to transaction history
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: paid.title,
        amount: paid.amount,
        date: DateTime.now(),
        categoryId: paid.categoryId,
        type: paid.type,
        details: paid.notes,
      );
      event.transactionBloc.add(AddTransaction(transaction: transaction));

      add(LoadPlannedPayments());
    } catch (e) {
      emit(PlannedPaymentError(e.toString()));
    }
  }

  Future<void> _scheduleNotification(PlannedPayment payment) async {
    final typeLabel = payment.type == TransactionType.income ? 'income' : 'expense';
    await _notificationService.showNotification(
      payment.id.hashCode,
      '📅 Planned Payment Reminder',
      '${payment.title} — Rs. ${payment.amount.toStringAsFixed(0)} $typeLabel due today',
      '',
    );
  }
}
