part of 'record_bloc.dart';

@immutable
abstract class RecordEvent {
  const RecordEvent();
}

class RecordEventFetch extends RecordEvent {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool isDeleteOperation;
  final bool isDeleted;
  final bool isUpdateOperation;
  final bool isUpdated;
  final ViewMode viewMode;
  final String dateTimeText;

  const RecordEventFetch({
    required this.isDeleteOperation,
    required this.isDeleted,
    required this.isUpdateOperation,
    required this.isUpdated,
    required this.viewMode,
    required this.startDateTime,
    required this.endDateTime,
    required this.dateTimeText,
  });
}

class RecordEventInsert extends RecordEvent {
  final rc.Record record;
  final ViewMode viewMode;

  const RecordEventInsert({
    required this.record,
    required this.viewMode,
  });
}

class RecordEventUpdate extends RecordEvent {
  final rc.Record newRecord;
  final rc.Record oldRecord;
  final ViewMode viewMode;

  const RecordEventUpdate({
    required this.newRecord,
    required this.oldRecord,
    required this.viewMode,
  });
}

class RecordEventDelete extends RecordEvent {
  final rc.Record record;
  final ViewMode viewMode;

  const RecordEventDelete({
    required this.record,
    required this.viewMode,
  });
}

class RecordEventViewMode extends RecordEvent {
  final ViewMode viewMode;
  final bool isDeleteOperation;
  final bool isDeleted;
  final bool isUpdateOperation;
  final bool isUpdated;

  const RecordEventViewMode({
    required this.isDeleteOperation,
    required this.isDeleted,
    required this.isUpdateOperation,
    required this.isUpdated,
    required this.viewMode,
  });
}

class RecordEventNext extends RecordEvent {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final ViewMode viewMode;

  const RecordEventNext({
    required this.startDateTime,
    required this.endDateTime,
    required this.viewMode,
  });
}

class RecordEventPrevious extends RecordEvent {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final ViewMode viewMode;

  const RecordEventPrevious({
    required this.startDateTime,
    required this.endDateTime,
    required this.viewMode,
  });
}
