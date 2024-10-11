import 'package:flutter/material.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/util/constants/money_enum.dart';

class EditRecord {
  final BuildContext context;
  final RecordData? recordData;
  final ViewMode viewMode;

  EditRecord(
      {required this.context,
      required this.recordData,
      required this.viewMode});
}

class RecordData {
  final rc.Record record;
  final Account fromAccount;
  final Account? toAccount;
  final Category? category;

  RecordData({
    required this.record,
    required this.fromAccount,
    required this.toAccount,
    required this.category,
  });
}
