import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/model/others.dart';
import 'package:money_management/service/storage_service_sql.dart';

part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  StorageService storageService = StorageService();
  BackupBloc() : super(BackupInitial()) {
    on<BackupEventCloudBackup>(backupEventCloudBackup);
    on<BackupEventNeedCloudBackup>(backupEventNeedCloudBackup);
  }

  FutureOr<void> backupEventNeedCloudBackup(event, emit) async {
    emit(const BackupStateCloudBackupLoading());
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    Others others = await OthersProvider(db).getOthers();

    await OthersProvider(db).update(Others(
      id: others.id,
      currencyName: others.currencyName,
      currencySymbol: others.currencySymbol,
      currencyCode: others.currencyCode,
      currencyNumber: others.currencyNumber,
      isSymbolOnLeft: others.isSymbolOnLeft,
      isSpaceBetweenAmountAndSymbol: others.isSpaceBetweenAmountAndSymbol,
      lastBackUpDateTime: others.lastBackUpDateTime,
      isCloudSynced: false,
    ));
    emit(const BackupStateNeedCloudBackup());
  }

  FutureOr<void> backupEventCloudBackup(event, emit) async {
    emit(const BackupStateCloudBackupLoading());
    try {
      await storageService.uploadDatabaseIntoDrive();
      emit(const BackupStateCloudBackupCompleted());
    } catch (_) {
      emit(const BackupStateCloudBackupFailed());
    }
  }
}
