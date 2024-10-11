import 'dart:ui';

import 'package:money_management/analysis/model/analysis_data.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:money_management/category/model/category.dart' as ct;

class AnalysisService {
  static AnalysisData prepareParentData({
    required AnalysisType analysisType,
    required Map<ct.Category, Map<ct.Category, num>> expenseOverview,
    required Map<ct.Category, Map<ct.Category, num>> incomeOverview,
  }) {
    List<MapEntry<ct.Category, num>> listEntry = [];
    Map<ct.Category, Color> colorData = {};
    if (AnalysisType.expenseOverview == analysisType) {
      num sum = 0;
      for (var x in expenseOverview.values) {
        for (var y in x.values) {
          sum += y;
        }
      }
      int index = 0;
      expenseOverview.forEach((key, value) {
        num subCatSum = 0;
        value.forEach((subKey, subValue) {
          subCatSum += subValue;
        });
        listEntry.add(MapEntry(key, ((subCatSum / sum) * 100)));
        colorData[key] = pieChartColors[(index + 1) % pieChartColors.length];
        index++;
      });
    } else if (AnalysisType.incomeOverview == analysisType) {
      num sum = 0;
      for (var x in incomeOverview.values) {
        for (var y in x.values) {
          sum += y;
        }
      }
      int index = 0;
      incomeOverview.forEach((key, value) {
        num subCatSum = 0;
        value.forEach((subKey, subValue) {
          subCatSum += subValue;
        });
        listEntry.add(MapEntry(key, ((subCatSum / sum) * 100)));
        colorData[key] = pieChartColors[(index + 1) % pieChartColors.length];
        index++;
      });
    }
    return AnalysisData(
      listEntry: listEntry,
      colorData: colorData,
    );
  }

  static AnalysisData prepareChildData({
    required AnalysisType analysisType,
    required Map<ct.Category, Map<ct.Category, num>> expenseOverview,
    required Map<ct.Category, Map<ct.Category, num>> incomeOverview,
    required int parentTouchedIndex,
  }) {
    List<MapEntry<ct.Category, num>> listEntry = [];
    Map<ct.Category, Color> colorData = {};
    if (expenseOverview.isNotEmpty &&
        AnalysisType.expenseOverview == analysisType) {
      num sum = 0;
      for (var x
          in expenseOverview.values.elementAt(parentTouchedIndex).values) {
        sum += x;
      }
      int index = 0;
      expenseOverview.values
          .elementAt(parentTouchedIndex)
          .forEach((key, value) {
        listEntry.add(MapEntry(key, ((value / sum) * 100)));
        colorData[key] = pieChartColors[(index + 1) % pieChartColors.length];
        index++;
      });
    } else if (incomeOverview.isNotEmpty &&
        AnalysisType.incomeOverview == analysisType) {
      num sum = 0;
      for (var x
          in incomeOverview.values.elementAt(parentTouchedIndex).values) {
        sum += x;
      }
      int index = 0;
      incomeOverview.values.elementAt(parentTouchedIndex).forEach((key, value) {
        listEntry.add(MapEntry(key, ((value / sum) * 100)));
        colorData[key] = pieChartColors[(index + 1) % pieChartColors.length];
        index++;
      });
    }
    return AnalysisData(
      listEntry: listEntry,
      colorData: colorData,
    );
  }

  static AnalysisListData prepareAnalysisListData({
    required AnalysisType analysisType,
    required Map<ct.Category, Map<ct.Category, num>> expenseOverview,
    required Map<ct.Category, Map<ct.Category, num>> incomeOverview,
    required AnalysisData parentData,
  }) {
    Map<ct.Category, bool> parentEnabledEntry = {};
    Map<ct.Category, List<MapEntry<ct.Category, num>>> childPercentEntry = {};
    List<MapEntry<ct.Category, String>> parentValueEntry = [];
    Map<ct.Category, List<MapEntry<ct.Category, String>>> childValueEntry = {};

    if (AnalysisType.expenseOverview == analysisType) {
      for (var expense in expenseOverview.entries) {
        num subCatSum = 0;
        List<MapEntry<ct.Category, String>> subCat = [];
        for (var subExpense in expense.value.entries) {
          subCatSum += subExpense.value;

          // String subVal = await CommonUtil.getAmountWithIconByRecordType(
          //   amount: subExpense.value,
          //   recordType: RecordType.expense,
          // );
          String subVal = subExpense.value.toStringAsFixed(2);
          subCat.add(MapEntry(subExpense.key, subVal));
        }
        childValueEntry[expense.key] = subCat;
        // String val = await CommonUtil.getAmountWithIconByRecordType(
        //   amount: subCatSum,
        //   recordType: RecordType.expense,
        // );
        String val = subCatSum.toStringAsFixed(2);
        parentValueEntry.add(MapEntry(expense.key, val));
      }
    } else if (AnalysisType.incomeOverview == analysisType) {
      incomeOverview.forEach((key, value) {
        num subCatSum = 0;
        List<MapEntry<ct.Category, String>> subCat = [];
        value.forEach((subKey, subValue) {
          subCatSum += subValue;
          // String subVal = await CommonUtil.getAmountWithIconByRecordType(
          //   amount: subValue,
          //   recordType: RecordType.expense,
          // );
          String subVal = subValue.toStringAsFixed(2);
          subCat.add(MapEntry(subKey, subVal));
        });
        childValueEntry[key] = subCat;
        // String val = await CommonUtil.getAmountWithIconByRecordType(
        //   amount: subCatSum,
        //   recordType: RecordType.expense,
        // );
        String val = subCatSum.toStringAsFixed(2);
        parentValueEntry.add(MapEntry(key, val));
      });
    }

    int index = 0;
    for (MapEntry<ct.Category, num> element in parentData.listEntry) {
      parentEnabledEntry[element.key] = false;
      AnalysisData childData = prepareChildData(
        analysisType: analysisType,
        expenseOverview: expenseOverview,
        incomeOverview: incomeOverview,
        parentTouchedIndex: index,
      );
      childPercentEntry[element.key] = childData.listEntry;
      index++;
    }
    return AnalysisListData(
      parentPercentEntry: parentData.listEntry,
      childPercentEntry: childPercentEntry,
      parentEnabledEntry: parentEnabledEntry,
      parentValueEntry: parentValueEntry,
      childValueEntry: childValueEntry,
    );
  }
}
