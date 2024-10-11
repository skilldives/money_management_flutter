import 'package:flutter/material.dart';

class IconDataClass {
  IconData iconData;
  bool isSelected;

  IconDataClass({required this.iconData, required this.isSelected});
}

final List<IconDataClass> allIcons = [
  // Income----------------------
  // Award
  IconDataClass(iconData: Icons.emoji_events, isSelected: true),
  // Interest Money
  IconDataClass(iconData: Icons.percent, isSelected: false),

  // Salary
  IconDataClass(iconData: Icons.paid, isSelected: false),

  // Gifts
  IconDataClass(iconData: Icons.card_giftcard, isSelected: false),

  // Debt Recovery
  IconDataClass(iconData: Icons.arrow_circle_left, isSelected: false),
  // Other Income
  IconDataClass(iconData: Icons.iron, isSelected: false),

  // Expense----------------------
  // Business
  IconDataClass(iconData: Icons.business_center, isSelected: false),

  // Food & Beverage
  IconDataClass(iconData: Icons.emoji_food_beverage, isSelected: false),

  IconDataClass(iconData: Icons.restaurant, isSelected: false),

  IconDataClass(iconData: Icons.local_cafe, isSelected: false),

  // Bills & Utilities
  IconDataClass(iconData: Icons.receipt_long, isSelected: false),

  IconDataClass(iconData: Icons.phone_android, isSelected: false),

  IconDataClass(iconData: Icons.water_drop, isSelected: false),

  IconDataClass(iconData: Icons.electric_meter, isSelected: false),

  IconDataClass(iconData: Icons.gas_meter, isSelected: false),

  IconDataClass(iconData: Icons.tv, isSelected: false),

  IconDataClass(iconData: Icons.network_check, isSelected: false),

  IconDataClass(iconData: Icons.maps_home_work_rounded, isSelected: false),

  // Transportation
  IconDataClass(iconData: Icons.emoji_transportation, isSelected: false),

  IconDataClass(iconData: Icons.local_taxi, isSelected: false),

  IconDataClass(iconData: Icons.local_parking, isSelected: false),

  IconDataClass(iconData: Icons.oil_barrel, isSelected: false),

  IconDataClass(iconData: Icons.miscellaneous_services, isSelected: false),

  // Shopping
  IconDataClass(iconData: Icons.shopping_bag_outlined, isSelected: false),

  IconDataClass(iconData: Icons.checkroom, isSelected: false),

  IconDataClass(iconData: Icons.ice_skating, isSelected: false),

  IconDataClass(iconData: Icons.diamond, isSelected: false),

  IconDataClass(iconData: Icons.mobile_friendly, isSelected: false),

  // Entertainment
  IconDataClass(iconData: Icons.sports_esports, isSelected: false),

  IconDataClass(iconData: Icons.movie, isSelected: false),

  IconDataClass(iconData: Icons.smart_toy, isSelected: false),

  // Travel
  IconDataClass(iconData: Icons.airplane_ticket, isSelected: false),

  // Health & Fitness
  IconDataClass(iconData: Icons.medical_services, isSelected: false),

  IconDataClass(iconData: Icons.sports_baseball, isSelected: false),

  IconDataClass(iconData: Icons.medication_liquid, isSelected: false),

  IconDataClass(iconData: Icons.local_pharmacy, isSelected: false),

  IconDataClass(iconData: Icons.spa, isSelected: false),

  // Gift & Donations

  IconDataClass(iconData: Icons.favorite, isSelected: false),

  IconDataClass(iconData: Icons.church, isSelected: false),

  IconDataClass(iconData: Icons.food_bank, isSelected: false),

  // Family
  IconDataClass(iconData: Icons.home_sharp, isSelected: false),

  IconDataClass(iconData: Icons.child_friendly, isSelected: false),

  IconDataClass(iconData: Icons.home, isSelected: false),

  IconDataClass(iconData: Icons.home_repair_service, isSelected: false),

  IconDataClass(iconData: Icons.pets, isSelected: false),

  // Education
  IconDataClass(iconData: Icons.school, isSelected: false),

  IconDataClass(iconData: Icons.menu_book, isSelected: false),

  // Investment
  IconDataClass(iconData: Icons.analytics, isSelected: false),

  // Insurances
  IconDataClass(iconData: Icons.verified_user, isSelected: false),

  // Fees & Charges
  IconDataClass(iconData: Icons.payments, isSelected: false),

  // Withdrawal
  IconDataClass(iconData: Icons.point_of_sale, isSelected: false),

  // Lend
  IconDataClass(iconData: Icons.arrow_circle_right, isSelected: false),

  // Other Expense
  IconDataClass(iconData: Icons.shopping_cart, isSelected: false),
];
