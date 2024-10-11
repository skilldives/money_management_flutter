import 'package:flutter/material.dart';
import 'package:money_management/model/others.dart';
import 'package:money_management/service/storage_service_sql.dart';
import 'package:money_management/util/constants/money_enum.dart';

class CommonUtil {
  static showSnackBarMessage(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(msg)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String getFormattedDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  static bool isSameDate(DateTime current, DateTime previous) {
    return current.day == previous.day &&
        current.month == previous.month &&
        current.year == previous.year;
  }

  static Color getColorByRecordType(
      RecordType recordType, ColorScheme colorScheme) {
    if (recordType == RecordType.expense) {
      return colorScheme.error;
    } else if (recordType == RecordType.income) {
      return colorScheme.primary;
    } else {
      return colorScheme.tertiary;
    }
  }

  static Color getColorByAmount(num amount, ColorScheme colorScheme) {
    if (amount < 0) {
      return colorScheme.error;
    } else {
      return colorScheme.primary;
    }
  }

  static Future<String> getAmountWithIconByRecordType({
    required num amount,
    required RecordType recordType,
  }) async {
    Others others = await getOthers();
    String response = '';
    String value = amount.toStringAsFixed(2);
    if (recordType == RecordType.expense) {
      response = '-$response';
    }
    if (others.isSpaceBetweenAmountAndSymbol) {
      if (others.isSymbolOnLeft) {
        response = '$response${others.currencySymbol} $value';
      } else {
        response = '$response$value ${others.currencySymbol}';
      }
    } else {
      if (others.isSymbolOnLeft) {
        response = '$response${others.currencySymbol}$value';
      } else {
        response = '$response$value${others.currencySymbol}';
      }
    }
    return response;
  }

  static Future<Others> getOthers() async {
    StorageService storageService = StorageService();
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    Others others = await OthersProvider(db).getOthers();
    return others;
  }

  static Future<void> updateOthersTable(Others others) async {
    StorageService storageService = StorageService();
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    OthersProvider othersProvider = OthersProvider(db);

    await othersProvider.update(Others(
      id: others.id,
      currencyName: others.currencyName,
      currencySymbol: others.currencySymbol,
      currencyCode: others.currencyCode,
      currencyNumber: others.currencyNumber,
      isSymbolOnLeft: others.isSymbolOnLeft,
      isSpaceBetweenAmountAndSymbol: others.isSpaceBetweenAmountAndSymbol,
      lastBackUpDateTime: others.lastBackUpDateTime,
      isCloudSynced: others.isCloudSynced,
    ));
  }

  static String getRecordDialogDateTime(DateTime dateTime) {
    String month = resolveMonth(dateTime).substring(0, 3);
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
    String response =
        '$month ${dateTime.day}, ${dateTime.year} ${timeOfDay.hour}:${timeOfDay.minute} ${timeOfDay.period.name.toUpperCase()}';
    return response;
  }

  static String resolveWeekDay(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'None';
    }
  }

  static String resolveMonth(DateTime dateTime) {
    switch (dateTime.month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'None';
    }
  }
}
