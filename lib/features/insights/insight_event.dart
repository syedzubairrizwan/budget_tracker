import 'package:equatable/equatable.dart';

abstract class InsightEvent extends Equatable {
  const InsightEvent();

  @override
  List<Object> get props => [];
}

class LoadInsights extends InsightEvent {}