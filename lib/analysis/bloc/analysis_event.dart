part of 'analysis_bloc.dart';

@immutable
sealed class AnalysisEvent {}

class AnalysisEventFetch extends AnalysisEvent {
  final List<rc.Record> records;
  final Map<String, ct.Category> categoryMap;
  final Map<String, Account> accountMap;

  AnalysisEventFetch({
    required this.records,
    required this.categoryMap,
    required this.accountMap,
  });
}

class AnalysisEventLoading extends AnalysisEvent {}
