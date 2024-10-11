import 'package:flutter/material.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/record/view/record_date_list_tile.dart';
import 'package:money_management/record/view/record_list_tile.dart';

import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

class RecordListView extends StatelessWidget {
  const RecordListView({
    super.key,
    required this.records,
    required this.categoryMap,
    required this.accountMap,
    required this.viewMode,
  });

  final List<rc.Record> records;
  final Map<String, Category> categoryMap;

  final Map<String, Account> accountMap;
  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        rc.Record record = records[index];
        return index == 0 ||
                !CommonUtil.isSameDate(
                    record.dateTime, records[index - 1].dateTime)
            ? Column(
                children: [
                  RecordDateListTile(record: record),
                  const Divider(
                    endIndent: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: RecordListTile(
                      record: record,
                      accountMap: accountMap,
                      categoryMap: categoryMap,
                      viewMode: viewMode,
                    ),
                  )
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(left: 16),
                child: RecordListTile(
                  record: record,
                  accountMap: accountMap,
                  categoryMap: categoryMap,
                  viewMode: viewMode,
                ),
              );
      },
    );
  }
}
