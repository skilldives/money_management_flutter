import 'package:flutter/material.dart';

class IconDataClass {
  IconData iconData;
  bool isSelected;

  IconDataClass({required this.iconData, required this.isSelected});
}

final List<IconDataClass> allIcons = [
  // Mandatory
  IconDataClass(iconData: Icons.credit_card_outlined, isSelected: false),
  IconDataClass(iconData: Icons.money, isSelected: false),
  IconDataClass(iconData: Icons.savings, isSelected: false),
  // In general
  IconDataClass(iconData: Icons.account_balance_wallet, isSelected: true),
  IconDataClass(iconData: Icons.storefront, isSelected: false),
  IconDataClass(iconData: Icons.paypal, isSelected: false),
  IconDataClass(iconData: Icons.lightbulb, isSelected: false),
  IconDataClass(iconData: Icons.account_balance, isSelected: false),
  IconDataClass(iconData: Icons.house, isSelected: false),
];
