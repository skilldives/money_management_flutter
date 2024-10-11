import 'package:flutter/material.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/record/view/record_view_dialog.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

class RecordListTile extends StatelessWidget {
  const RecordListTile({
    super.key,
    required this.record,
    required this.accountMap,
    required this.categoryMap,
    required this.viewMode,
  });

  final rc.Record record;
  final Map<String, Account> accountMap;
  final Map<String, Category> categoryMap;
  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    var text = record.recordType == RecordType.transfer
        ? 'Transfer'
        : categoryMap[record.category]?.name;
    IconData icon = record.recordType == RecordType.transfer
        ? Icons.sync_alt
        : IconData(
            categoryMap[record.category]!.iconDataCodePoint,
            fontFamily: 'MaterialIcons',
          );
    return Column(
      children: [
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(
            text!,
            style: TextStyle(
              fontSize: textTheme.titleSmall?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            String transAmount = await CommonUtil.getAmountWithIconByRecordType(
              amount: record.amount,
              recordType: record.recordType,
            );
            // ignore: use_build_context_synchronously
            showRecordViewDialog(
              context,
              record: record,
              transAmount: transAmount,
              fromAccount: accountMap[record.fromAccount]!,
              toAccount: accountMap[record.toAccount],
              category: categoryMap[record.category],
              viewMode: viewMode,
            );
          },
          trailing: Text(
            '${record.amount}',
            style: TextStyle(
              fontSize: textTheme.titleMedium?.fontSize,
              color: CommonUtil.getColorByRecordType(
                  record.recordType, colorScheme),
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Icon(
            icon,
            size: textTheme.headlineMedium?.fontSize,
          ),
          subtitle: Row(
            children: [
              Icon(
                IconData(
                  accountMap[record.fromAccount]!.iconDataCodePoint,
                  fontFamily: 'MaterialIcons',
                ),
              ),
              Text(
                '${accountMap[record.fromAccount]?.name}',
              ),
              Visibility(
                visible: record.recordType == RecordType.transfer,
                child: const Icon(Icons.arrow_right_alt),
              ),
              Visibility(
                visible: record.recordType == RecordType.transfer,
                child: Icon(
                  IconData(
                    accountMap[record.toAccount]?.iconDataCodePoint ?? 0,
                    fontFamily: 'MaterialIcons',
                  ),
                ),
              ),
              Visibility(
                visible: record.recordType == RecordType.transfer,
                child: Text(
                  '${accountMap[record.toAccount]?.name}',
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Divider(
            endIndent: 16,
          ),
        ),
      ],
    );
  }
}
