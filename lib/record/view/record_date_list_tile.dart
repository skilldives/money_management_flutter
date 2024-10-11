import 'package:flutter/material.dart';
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/util/common_util.dart';

class RecordDateListTile extends StatelessWidget {
  const RecordDateListTile({
    super.key,
    required this.record,
  });

  final rc.Record record;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(
        CommonUtil.resolveWeekDay(record.dateTime),
        style: TextStyle(
          fontSize: textTheme.titleMedium?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Text(
        '${record.dateTime.day}',
        style: TextStyle(
          fontSize: textTheme.headlineMedium?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${CommonUtil.resolveMonth(record.dateTime)} ${record.dateTime.year}',
        style: TextStyle(
          fontSize: textTheme.titleSmall?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
