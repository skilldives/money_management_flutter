part of 'analysis_bloc.dart';

@immutable
sealed class AnalysisState {}

final class AnalysisInitial extends AnalysisState {}

final class AnalysisStateLoading extends AnalysisState {}

class AnalysisStateCompleted extends AnalysisState {
  final Map<ct.Category, Map<ct.Category, num>> expenseOverview;
  final Map<ct.Category, Map<ct.Category, num>> incomeOverview;
  final List<rc.Record> expenseFlow;
  final List<rc.Record> incomeFlow;
  final Map<Account, num> accountAnalysis;

  AnalysisStateCompleted({
    required this.expenseOverview,
    required this.incomeOverview,
    required this.incomeFlow,
    required this.expenseFlow,
    required this.accountAnalysis,
  });
}

final class AnalysisStateEmpty extends AnalysisState {}
