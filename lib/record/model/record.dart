import 'package:equatable/equatable.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:sqflite/sqflite.dart';

const String tableRecord = 'record';
const String columnId = 'id';
const String columnRecordType = 'record_type';
const String columnNote = 'note';
const String columnAmount = 'amount';
const String columnDateTime = 'date_time';
const String columnFromAccount = 'from_account';
const String columnToAccount = 'to_account';
const String columnCategory = 'category';

class Record extends Equatable {
  final String id;
  final RecordType recordType;
  final String note;
  final num amount;
  final DateTime dateTime;
  final String fromAccount;
  final String? toAccount;
  final String? category;

  const Record({
    required this.id,
    required this.recordType,
    required this.note,
    required this.amount,
    required this.dateTime,
    required this.fromAccount,
    this.toAccount,
    this.category,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: id,
      columnRecordType: recordType.toString(),
      columnNote: note,
      columnAmount: amount,
      columnDateTime: dateTime.millisecondsSinceEpoch,
      columnFromAccount: fromAccount,
      columnToAccount: toAccount,
      columnCategory: category,
    };
    return map;
  }

  Record.fromMap(Map<String, Object?> map)
      : id = map[columnId] as String,
        recordType = _parseRecordType(map[columnRecordType] as String),
        note = map[columnNote] as String,
        amount = map[columnAmount] as num,
        dateTime =
            DateTime.fromMillisecondsSinceEpoch(map[columnDateTime] as int),
        fromAccount = map[columnFromAccount] as String,
        toAccount = map[columnToAccount] as String?,
        category = map[columnCategory] as String?;

  static RecordType _parseRecordType(String value) {
    if (value == 'RecordType.income') {
      return RecordType.income;
    } else if (value == 'RecordType.expense') {
      return RecordType.expense;
    } else if (value == 'RecordType.transfer') {
      return RecordType.transfer;
    } else {
      throw ArgumentError('Invalid record type value: $value');
    }
  }

  @override
  List<Object?> get props => [id];
}

class RecordProvider {
  Database db;

  RecordProvider(this.db);

  Future crateTable() async {
    const createRecordTable = '''
        CREATE TABLE IF NOT EXISTS $tableRecord ( 
	$columnId                   TEXT NOT NULL  PRIMARY KEY  ,
	$columnRecordType     TEXT NOT NULL    ,
	$columnNote                 TEXT NOT NULL    ,
	$columnAmount               REAL NOT NULL    ,
	$columnDateTime            INTEGER NOT NULL    ,
	$columnFromAccount         TEXT NOT NULL    ,
	$columnToAccount           TEXT     ,
	$columnCategory             TEXT     ,
	FOREIGN KEY ( $columnFromAccount ) REFERENCES $tableAccount( $columnId ) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ( $columnToAccount ) REFERENCES $tableAccount( $columnId ) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ( $columnCategory ) REFERENCES $tableCategory( $columnId ) ON DELETE CASCADE ON UPDATE CASCADE
 );
''';
    // Create record table
    await db.execute(createRecordTable);
  }

  Future<Record> insert({
    required Record record,
    required String fromAccount,
    required String? toAccount,
    required num amount,
  }) async {
    await db.transaction((txn) async {
      await txn.insert(tableRecord, record.toMap());

      String sign;
      if (record.recordType == RecordType.expense ||
          record.recordType == RecordType.transfer) {
        sign = '-';
      } else {
        sign = '+';
      }
      // Update from account
      await txn.rawUpdate(
        '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount $sign $amount
        WHERE $columnId = ?
      ''',
        [fromAccount],
      );

      // Update to account
      if (toAccount != null) {
        await txn.rawUpdate(
          '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount + $amount
        WHERE $columnId = ?
      ''',
          [toAccount],
        );
      }
    });
    return record;
  }

  Future<Record> getRecord(String id) async {
    final maps = await db.query(tableRecord,
        columns: [
          columnId,
          columnRecordType,
          columnNote,
          columnAmount,
          columnDateTime,
          columnFromAccount,
          columnToAccount,
          columnCategory,
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Record.fromMap(maps.first);
    } else {
      throw CouldNotFindRecord();
    }
  }

  Future<List<Record>> getAllRecords() async {
    final maps = await db.query(tableRecord,
        columns: [
          columnId,
          columnRecordType,
          columnNote,
          columnAmount,
          columnDateTime,
          columnFromAccount,
          columnToAccount,
          columnCategory,
        ],
        orderBy: "$columnDateTime DESC");
    if (maps.isNotEmpty) {
      List<Record> records = [];
      for (var element in maps) {
        records.add(Record.fromMap(element));
      }
      return records;
    } else {
      throw CouldNotFindRecord();
    }
  }

  Future<List<Record>> getAllRecordsBetweenDateTimeRange({
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    final maps = await db.query(tableRecord,
        columns: [
          columnId,
          columnRecordType,
          columnNote,
          columnAmount,
          columnDateTime,
          columnFromAccount,
          columnToAccount,
          columnCategory,
        ],
        where: "$columnDateTime >= ? AND $columnDateTime <= ?",
        whereArgs: [
          startDateTime.millisecondsSinceEpoch,
          endDateTime.millisecondsSinceEpoch,
        ],
        orderBy: "$columnDateTime DESC");
    if (maps.isNotEmpty) {
      List<Record> records = [];
      for (var element in maps) {
        records.add(Record.fromMap(element));
      }
      return records;
    } else {
      throw CouldNotFindRecord();
    }
  }

  Future<int> delete(Record record) async {
    int count = 0;

    await db.transaction(
      (txn) async {
        count = await txn.delete(
          tableRecord,
          where: '$columnId = ?',
          whereArgs: [record.id],
        );

        String sign;
        if (record.recordType == RecordType.expense ||
            record.recordType == RecordType.transfer) {
          sign = '+';
        } else {
          sign = '-';
        }
        // Update from account
        await txn.rawUpdate(
          '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount $sign ${record.amount}
        WHERE $columnId = ?
      ''',
          [record.fromAccount],
        );

        // Update to account
        if (RecordType.transfer == record.recordType) {
          await txn.rawUpdate(
            '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount - ${record.amount}
        WHERE $columnId = ?
      ''',
            [record.toAccount],
          );
        }
      },
    );
    if (count == 0) {
      throw CouldNotDeleteRecord();
    }
    return count;
  }

  Future<int> update({
    required Record newRecord,
    required Record oldRecord,
  }) async {
    int count = 0;
    await db.transaction((txn) async {
      // updating account for oldRecord
      String sign;
      if (oldRecord.recordType == RecordType.expense ||
          oldRecord.recordType == RecordType.transfer) {
        sign = '+';
      } else {
        sign = '-';
      }
      // Update from account
      await txn.rawUpdate(
        '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount $sign ${oldRecord.amount}
        WHERE $columnId = ?
      ''',
        [oldRecord.fromAccount],
      );

      // Update to account
      if (RecordType.transfer == oldRecord.recordType) {
        await txn.rawUpdate(
          '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount - ${oldRecord.amount}
        WHERE $columnId = ?
      ''',
          [oldRecord.toAccount],
        );
      }

      // updating for new Record
      String newSign;
      if (newRecord.recordType == RecordType.expense ||
          newRecord.recordType == RecordType.transfer) {
        newSign = '-';
      } else {
        newSign = '+';
      }
      // Update from account
      await txn.rawUpdate(
        '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount $newSign ${newRecord.amount}
        WHERE $columnId = ?
      ''',
        [newRecord.fromAccount],
      );

      // Update to account
      if (RecordType.transfer == newRecord.recordType) {
        await txn.rawUpdate(
          '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount + ${newRecord.amount}
        WHERE $columnId = ?
      ''',
          [newRecord.toAccount],
        );
      }

      // update record
      count = await txn.update(
        tableRecord,
        newRecord.toMap(),
        where: '$columnId = ?',
        whereArgs: [newRecord.id],
      );
    });

    if (count == 0) {
      throw CouldNotUpdateRecord();
    }
    return count;
  }

  Future close() async => db.close();
}
