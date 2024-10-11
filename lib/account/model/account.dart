import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:money_management/record/model/record.dart';
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const String tableAccount = 'account';
const String columnId = 'id';
const String columnInitialAmount = 'initial_amount';
const String columnName = 'name';
const String columnIconDataCodePoint = 'icon_data_code_point';
const String columnIsIgnored = 'is_ignored';

class Account extends Equatable {
  final String id;
  final num initialAmount;
  final String name;
  final int iconDataCodePoint;
  final bool isIgnored;

  const Account({
    required this.id,
    required this.initialAmount,
    required this.name,
    required this.iconDataCodePoint,
    required this.isIgnored,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: id,
      columnInitialAmount: initialAmount,
      columnName: name,
      columnIconDataCodePoint: iconDataCodePoint,
      columnIsIgnored: isIgnored == true ? 1 : 0,
    };
    return map;
  }

  Account.fromMap(Map<String, Object?> map)
      : id = map[columnId] as String,
        initialAmount = map[columnInitialAmount] as num,
        name = map[columnName] as String,
        iconDataCodePoint = map[columnIconDataCodePoint] as int,
        isIgnored = (map[columnIsIgnored] as int) == 1;

  @override
  List<Object?> get props => [id];
}

class AccountProvider {
  Database db;

  AccountProvider(this.db);

  Future<Account> insert(Account account) async {
    await db.insert(tableAccount, account.toMap());
    return account;
  }

  Future<Account> getAccount(String id) async {
    final maps = await db.query(tableAccount,
        columns: [
          columnId,
          columnInitialAmount,
          columnName,
          columnIconDataCodePoint,
          columnIsIgnored
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    } else {
      throw CouldNotFindAccount();
    }
  }

  Future<List<Account>> getAllAccounts() async {
    final maps = await db.query(
      tableAccount,
      columns: [
        columnId,
        columnInitialAmount,
        columnName,
        columnIconDataCodePoint,
        columnIsIgnored
      ],
    );
    if (maps.isNotEmpty) {
      List<Account> accounts = [];
      for (var element in maps) {
        accounts.add(Account.fromMap(element));
      }
      return accounts;
    } else {
      throw CouldNotFindAccount();
    }
  }

  Future<int> delete(String id) async {
    int count = 0;
    await db.transaction((txn) async {
      await txn.delete(
        tableRecord,
        where:
            '$columnFromAccount = ? AND ($columnRecordType = ? OR $columnRecordType = ?)',
        whereArgs: [
          id,
          RecordType.income.toString(),
          RecordType.expense.toString(),
        ],
      );
      final recordMap = await txn.query(
        tableRecord,
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
        where:
            '$columnRecordType = ? AND ($columnFromAccount = ? OR $columnToAccount = ?)',
        whereArgs: [
          RecordType.transfer.toString(),
          id,
          id,
        ],
      );
      List<Record> tranferRecords = [];
      for (var element in recordMap) {
        tranferRecords.add(Record.fromMap(element));
      }
      for (Record record in tranferRecords) {
        if (record.fromAccount == id) {
          // update to account
          await txn.rawUpdate(
            '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount - ${record.amount}
        WHERE $columnId = ?
      ''',
            [record.toAccount],
          );
        } else if (record.toAccount == id) {
          await txn.rawUpdate(
            '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount + ${record.amount}
        WHERE $columnId = ?
      ''',
            [record.fromAccount],
          );
        }

        await txn.delete(
          tableRecord,
          where: '$columnId = ?',
          whereArgs: [record.id],
        );
      }

      count = await txn
          .delete(tableAccount, where: '$columnId = ?', whereArgs: [id]);
    });

    if (count == 0) {
      throw CouldNotDeleteAccount();
    }
    return count;
  }

  Future<int> update(Account account) async {
    int count = await db.update(tableAccount, account.toMap(),
        where: '$columnId = ?', whereArgs: [account.id]);
    if (count == 0) {
      throw CouldNotUpdateAccount();
    }
    return count;
  }

  Future close() async => db.close();

  Future crateTable() async {
    const createAccountTable = '''
        CREATE TABLE IF NOT EXISTS $tableAccount ( 
	$columnId                   TEXT NOT NULL  PRIMARY KEY  ,
	$columnInitialAmount       REAL NOT NULL    ,
	$columnName                 TEXT NOT NULL    ,
	$columnIconDataCodePoint INTEGER NOT NULL    ,
	$columnIsIgnored           INTEGER NOT NULL    
 );
        ''';
    // Create account table
    await db.execute(createAccountTable);
    await insert(Account(
      id: const Uuid().v4(),
      initialAmount: 0.00,
      name: 'Card',
      iconDataCodePoint: Icons.credit_card_outlined.codePoint,
      isIgnored: false,
    ));
    await insert(Account(
      id: const Uuid().v4(),
      initialAmount: 0.00,
      name: 'Cash',
      iconDataCodePoint: Icons.money.codePoint,
      isIgnored: false,
    ));
    await insert(Account(
      id: const Uuid().v4(),
      initialAmount: 0.00,
      name: 'Savings',
      iconDataCodePoint: Icons.savings.codePoint,
      isIgnored: false,
    ));
  }
}
