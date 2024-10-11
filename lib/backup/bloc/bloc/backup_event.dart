part of 'backup_bloc.dart';

@immutable
abstract class BackupEvent {
  const BackupEvent();
}

class BackupEventCloudBackup extends BackupEvent {
  const BackupEventCloudBackup();
}

class BackupEventNeedCloudBackup extends BackupEvent {
  const BackupEventNeedCloudBackup();
}
