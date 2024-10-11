import 'package:flutter/material.dart';
import 'package:money_management/category/model/category.dart' as ct;

class AnalysisData {
  final List<MapEntry<ct.Category, num>> listEntry;
  final Map<ct.Category, Color> colorData;

  AnalysisData({
    required this.listEntry,
    required this.colorData,
  });
}

class AnalysisListData {
  List<MapEntry<ct.Category, num>> parentPercentEntry;
  Map<ct.Category, List<MapEntry<ct.Category, num>>> childPercentEntry;
  List<MapEntry<ct.Category, String>> parentValueEntry;
  Map<ct.Category, List<MapEntry<ct.Category, String>>> childValueEntry;
  Map<ct.Category, bool> parentEnabledEntry;
  AnalysisListData({
    required this.parentPercentEntry,
    required this.childPercentEntry,
    required this.parentEnabledEntry,
    required this.parentValueEntry,
    required this.childValueEntry,
  });
}

List<Color> pieChartColors = [
  Colors.blue,
  Colors.teal,
  const Color(0xFFDC143C), // Crimson
  Colors.orange,
  Colors.purple,
  Colors.yellow,
  const Color(0xFFFF00FF), // Magenta
  Colors.cyan,
  Colors.grey,
  Colors.red,
  Colors.lime,
  const Color(0xFF013ADF), // Sapphire Blue
  const Color(0xFF40E0D0), // Turquoise
  Colors.amber,
  Colors.indigo,
  Colors.pink,
  const Color(0xFF808000), // Olive
  const Color(0xFFD3D3D3), // Light Grey
  Colors.green,
  const Color(0xFFFFD700), // Gold
];
