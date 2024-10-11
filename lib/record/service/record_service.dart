import 'package:money_management/record/model/record.dart';
import 'package:money_management/service/storage_service_sql.dart';

class RecordService {
  static final RecordService _shared = RecordService._sharedInstance();

  RecordService._sharedInstance();

  factory RecordService() => _shared;

  StorageService storageService = StorageService();

  Future<List<Record>> getAllRecordsByRange({
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    return await RecordProvider(db).getAllRecordsBetweenDateTimeRange(
      startDateTime: startDateTime,
      endDateTime: endDateTime,
    );
  }

  Future<List<Record>> getAllRecords() async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    return await RecordProvider(db).getAllRecords();
  }

  createNewRecord({
    required Record record,
    required String fromAccount,
    required String? toAccount,
    required num amount,
  }) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await RecordProvider(db).insert(
      record: record,
      fromAccount: fromAccount,
      toAccount: toAccount,
      amount: amount,
    );
  }

  updateRecord({
    required Record newRecord,
    required Record oldRecord,
  }) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await RecordProvider(db).update(
      newRecord: newRecord,
      oldRecord: oldRecord,
    );
  }

  deleteRecord({
    required Record record,
  }) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await RecordProvider(db).delete(record);
  }
}
