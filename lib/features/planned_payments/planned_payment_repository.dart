import 'package:budget_tracker/models/planned_payment.dart';
import 'package:budget_tracker/services/database_service.dart';

class PlannedPaymentRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<List<PlannedPayment>> getAll() async {
    return await _dbService.getPlannedPayments();
  }

  Future<void> add(PlannedPayment payment) async {
    await _dbService.insertPlannedPayment(payment);
  }

  Future<void> update(PlannedPayment payment) async {
    await _dbService.updatePlannedPayment(payment);
  }

  Future<void> delete(String id) async {
    await _dbService.deletePlannedPayment(id);
  }
}
