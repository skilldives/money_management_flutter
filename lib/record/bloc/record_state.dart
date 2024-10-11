part of 'record_bloc.dart';

@immutable
abstract class RecordState {
  final bool isDeleteOperation;
  final bool isDeleted;
  final bool isUpdateOperation;
  final bool isUpdated;
  final ViewMode viewMode;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String dateTimeText;
  const RecordState({
    required this.viewMode,
    required this.startDateTime,
    required this.endDateTime,
    required this.dateTimeText,
    required this.isDeleteOperation,
    required this.isDeleted,
    required this.isUpdateOperation,
    required this.isUpdated,
  });
}

class RecordManagementInitial extends RecordState {
  const RecordManagementInitial({
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
    required super.viewMode,
    required super.startDateTime,
    required super.endDateTime,
    required super.dateTimeText,
  });
}

class RecordStateLoading extends RecordState {
  const RecordStateLoading({
    required super.viewMode,
    required super.startDateTime,
    required super.endDateTime,
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
    required super.dateTimeText,
  });
}

class RecordStateEmptyFetch extends RecordState {
  const RecordStateEmptyFetch({
    required super.viewMode,
    required super.startDateTime,
    required super.endDateTime,
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
    required super.dateTimeText,
  });
}

class RecordStateFetched extends RecordState {
  final List<rc.Record> records;
  final Map<String, ct.Category> categoryMap;
  final Map<String, Account> accountMap;
  final String totalIncome;
  final String totalExpense;
  final String totalBalance;

  const RecordStateFetched({
    required this.records,
    required this.categoryMap,
    required this.accountMap,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required super.viewMode,
    required super.startDateTime,
    required super.endDateTime,
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
    required super.dateTimeText,
  });
}
