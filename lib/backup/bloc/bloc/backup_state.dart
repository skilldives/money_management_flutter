part of 'backup_bloc.dart';

@immutable
abstract class BackupState {
  const BackupState();
}

class BackupInitial extends BackupState {}

class BackupStateCloudBackupCompleted extends BackupState {
  const BackupStateCloudBackupCompleted();
}

class BackupStateCloudBackupLoading extends BackupState {
  const BackupStateCloudBackupLoading();
}

class BackupStateCloudBackupFailed extends BackupState {
  const BackupStateCloudBackupFailed();
}

class BackupStateNeedCloudBackup extends BackupState {
  const BackupStateNeedCloudBackup();
}
