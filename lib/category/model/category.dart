import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/record/model/record.dart';
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const String tableCategory = 'category';
const String columnId = 'id';
const String columnRecordType = 'record_type';
const String columnName = 'name';
const String columnIconDataCodePoint = 'icon_data_code_point';
const String columnIsIgnored = 'is_ignored';
const String columnIsSubCategory = 'is_sub_category';
const String columnCategoryGroup = 'category_group';

class Category extends Equatable {
  final String id;
  final RecordType recordType;
  final String name;
  final int iconDataCodePoint;
  final bool isIgnored;
  final bool isSubCategory;
  final String? categoryGroup;

  const Category({
    required this.id,
    required this.recordType,
    required this.name,
    required this.iconDataCodePoint,
    required this.isIgnored,
    required this.isSubCategory,
    this.categoryGroup,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: id,
      columnRecordType: recordType.toString(),
      columnName: name,
      columnIconDataCodePoint: iconDataCodePoint,
      columnIsIgnored: isIgnored == true ? 1 : 0,
      columnIsSubCategory: isSubCategory == true ? 1 : 0,
      columnCategoryGroup: categoryGroup,
    };
    return map;
  }

  Category.fromMap(Map<String, Object?> map)
      : id = map[columnId] as String,
        recordType = _parseRecordType(map[columnRecordType] as String),
        name = map[columnName] as String,
        iconDataCodePoint = map[columnIconDataCodePoint] as int,
        isIgnored = (map[columnIsIgnored] as int) == 1,
        isSubCategory = (map[columnIsSubCategory] as int) == 1,
        categoryGroup = map[columnCategoryGroup] as String?;

  static RecordType _parseRecordType(String value) {
    if (value == 'RecordType.income') {
      return RecordType.income;
    } else if (value == 'RecordType.expense') {
      return RecordType.expense;
    } else if (value == 'recordType.transfer') {
      return RecordType.transfer;
    } else {
      throw ArgumentError('Invalid record type value: $value');
    }
  }

  @override
  List<Object?> get props => [id];
}

class CategoryProvider {
  Database db;

  CategoryProvider(this.db);

  Future<Category> insert(Category category) async {
    await db.insert(tableCategory, category.toMap());
    return category;
  }

  Future<Category> getCategory(String id) async {
    final maps = await db.query(
      tableCategory,
      columns: [
        columnId,
        columnRecordType,
        columnName,
        columnIconDataCodePoint,
        columnIsIgnored,
        columnIsSubCategory,
        columnCategoryGroup,
      ],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    } else {
      throw CouldNotFindCategory();
    }
  }

  Future<List<Category>> getAllCategories() async {
    final maps = await db.query(
      tableCategory,
      columns: [
        columnId,
        columnRecordType,
        columnName,
        columnIconDataCodePoint,
        columnIsIgnored,
        columnIsSubCategory,
        columnCategoryGroup,
      ],
    );
    if (maps.isNotEmpty) {
      List<Category> categories = [];
      for (var element in maps) {
        categories.add(Category.fromMap(element));
      }
      return categories;
    } else {
      throw CouldNotFindCategory();
    }
  }

  Future<Map<String, List<Category>>> geAllCategoriesByRecordType(
      RecordType recordType) async {
    final categories = await db.query(
      tableCategory,
      columns: [
        columnId,
        columnRecordType,
        columnName,
        columnIconDataCodePoint,
        columnIsIgnored,
        columnIsSubCategory,
        columnCategoryGroup,
      ],
      where: '$columnRecordType = ?',
      whereArgs: [recordType.toString()],
    );
    if (categories.isNotEmpty) {
      Map<String, List<Category>> categoriesMap = {};
      for (var categoryMap in categories) {
        final category = Category.fromMap(categoryMap);
        if (!category.isSubCategory) {
          // Category with isSubcategory set to false
          categoriesMap[category.id] = [category];
        }
      }
      for (var categoryMap in categories) {
        final category = Category.fromMap(categoryMap);
        if (category.isSubCategory) {
          // Category with isSubcategory set to true
          categoriesMap[category.categoryGroup!]?.add(category);
        }
      }
      return categoriesMap;
    } else {
      throw CouldNotFindCategory();
    }
  }

  Future<List<Category>> getCategoriesListByRecordAndCategoryType(
      RecordType recordType, bool isSubCategorySelected) async {
    final maps = await db.query(
      tableCategory,
      columns: [
        columnId,
        columnRecordType,
        columnName,
        columnIconDataCodePoint,
        columnIsIgnored,
        columnIsSubCategory,
        columnCategoryGroup,
      ],
      where: '$columnRecordType = ? and $columnIsSubCategory = ?',
      whereArgs: [recordType.toString(), isSubCategorySelected ? '1' : '0'],
    );
    if (maps.isNotEmpty) {
      List<Category> categories = [];
      for (var element in maps) {
        categories.add(Category.fromMap(element));
      }
      return categories;
    } else {
      throw CouldNotFindCategory();
    }
  }

  Future<int> delete(Category category) async {
    int count = 0;
    await db.transaction(
      (txn) async {
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
          where: '$columnCategory = ?',
          whereArgs: [category.id],
        );
        List<Record> tranferRecords = [];
        for (var element in recordMap) {
          tranferRecords.add(Record.fromMap(element));
        }
        for (var record in tranferRecords) {
          await txn.delete(
            tableRecord,
            where: '$columnId = ?',
            whereArgs: [record.id],
          );

          String sign;
          if (record.recordType == RecordType.expense) {
            sign = '+';
          } else {
            sign = '-';
          }
          // Update from account
          await txn.rawUpdate(
            '''
        UPDATE $tableAccount
        SET $columnInitialAmount = $columnInitialAmount $sign ${record.amount}
        WHERE $columnId = ?
      ''',
            [record.fromAccount],
          );
        }

        if (!category.isSubCategory) {
          final categoryMaps = await txn.query(
            tableCategory,
            columns: [
              columnId,
              columnRecordType,
              columnName,
              columnIconDataCodePoint,
              columnIsIgnored,
              columnIsSubCategory,
              columnCategoryGroup,
            ],
            where: '$columnIsSubCategory = ? AND $columnCategoryGroup = ?',
            whereArgs: [1, category.id],
          );

          List<Category> categories = [];
          for (var element in categoryMaps) {
            categories.add(Category.fromMap(element));
          }
          for (Category subCategory in categories) {
            Category ct = Category(
              id: subCategory.id,
              recordType: subCategory.recordType,
              name: subCategory.name,
              iconDataCodePoint: subCategory.iconDataCodePoint,
              isIgnored: subCategory.isIgnored,
              isSubCategory: false,
              categoryGroup: null,
            );
            await txn.update(
              tableCategory,
              ct.toMap(),
              where: '$columnId = ?',
              whereArgs: [ct.id],
            );
          }
        }

        count = await txn.delete(tableCategory,
            where: '$columnId = ?', whereArgs: [category.id]);
      },
    );

    if (count == 0) {
      throw CouldNotDeleteCategory();
    }
    return count;
  }

  Future<int> update(Category category) async {
    int count = await db.update(tableCategory, category.toMap(),
        where: '$columnId = ?', whereArgs: [category.id]);
    if (count == 0) {
      throw CouldNotUpdateCategory();
    }
    return count;
  }

  Future close() async => db.close();

  Future crateTable() async {
    const createCategoryTable = '''
        CREATE TABLE IF NOT EXISTS $tableCategory ( 
	$columnId                   TEXT NOT NULL  PRIMARY KEY  ,
	$columnRecordType     TEXT NOT NULL    ,
	$columnName                 TEXT NOT NULL    ,
	$columnIconDataCodePoint INTEGER NOT NULL    ,
	$columnIsIgnored           INTEGER NOT NULL    ,
	$columnIsSubCategory      INTEGER NOT NULL    ,
	$columnCategoryGroup       TEXT   ,
	FOREIGN KEY ( $columnCategoryGroup ) REFERENCES $tableCategory( $columnId ) ON DELETE CASCADE ON UPDATE CASCADE
 );
''';
    // Create category table
    await db.execute(createCategoryTable);

    // Income----------------------
    // Award
    Category category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.income,
      name: 'award',
      iconDataCodePoint: Icons.emoji_events.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Interest Money
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.income,
      name: 'Interest Money',
      iconDataCodePoint: Icons.percent.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Salary
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.income,
      name: 'Salary',
      iconDataCodePoint: Icons.paid.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Gifts
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.income,
      name: 'Gifts',
      iconDataCodePoint: Icons.card_giftcard.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Selling
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.income,
      name: 'Selling',
      iconDataCodePoint: Icons.point_of_sale.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Loan Taken
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.income,
      name: 'Loan Taken',
      iconDataCodePoint: Icons.arrow_circle_left.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Debt Recovery
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.income,
      name: 'Debt Recovery',
      iconDataCodePoint: Icons.arrow_circle_left.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Other Income
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.income,
      name: 'Other Income',
      iconDataCodePoint: Icons.iron.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Expense----------------------
    // Business
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Business',
      iconDataCodePoint: Icons.business_center.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Food & Beverage
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Food, Beverage',
      iconDataCodePoint: Icons.emoji_food_beverage.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Restaurants',
      iconDataCodePoint: Icons.restaurant.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Cafe',
      iconDataCodePoint: Icons.local_cafe.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Bills & Utilities
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Bills & Utilities',
      iconDataCodePoint: Icons.receipt_long.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Phone Bill',
      iconDataCodePoint: Icons.phone_android.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Water Bill',
      iconDataCodePoint: Icons.water_drop.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Electricity Bill',
      iconDataCodePoint: Icons.electric_meter.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Gas Bill',
      iconDataCodePoint: Icons.gas_meter.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Television Bill',
      iconDataCodePoint: Icons.tv.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Internet Bill',
      iconDataCodePoint: Icons.network_check.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Rentals',
      iconDataCodePoint: Icons.maps_home_work_rounded.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Transportation
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Transportation',
      iconDataCodePoint: Icons.emoji_transportation.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Taxi',
      iconDataCodePoint: Icons.local_taxi.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Parking Fees',
      iconDataCodePoint: Icons.local_parking.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Petrol',
      iconDataCodePoint: Icons.oil_barrel.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Maintenance',
      iconDataCodePoint: Icons.miscellaneous_services.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Shopping
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Shopping',
      iconDataCodePoint: Icons.shopping_bag_outlined.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Clothing',
      iconDataCodePoint: Icons.checkroom.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Footwear',
      iconDataCodePoint: Icons.ice_skating.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Accessories',
      iconDataCodePoint: Icons.diamond.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Electronics',
      iconDataCodePoint: Icons.mobile_friendly.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Friends & Lover
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Friends & Lover',
      iconDataCodePoint: Icons.favorite.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Entertainment
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Entertainment',
      iconDataCodePoint: Icons.sports_esports.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Movies',
      iconDataCodePoint: Icons.movie.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Games',
      iconDataCodePoint: Icons.smart_toy.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Travel
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Travel',
      iconDataCodePoint: Icons.airplane_ticket.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Health & Fitness
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Health & Fitness',
      iconDataCodePoint: Icons.medical_services.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Sports',
      iconDataCodePoint: Icons.sports_baseball.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Doctor',
      iconDataCodePoint: Icons.medication_liquid.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Pharmacy',
      iconDataCodePoint: Icons.local_pharmacy.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Personal Care',
      iconDataCodePoint: Icons.spa.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Gift & Donations
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Gift & Donations',
      iconDataCodePoint: Icons.card_giftcard.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Marriage',
      iconDataCodePoint: Icons.favorite.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Funeral',
      iconDataCodePoint: Icons.church.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Charity',
      iconDataCodePoint: Icons.food_bank.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Family
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Family',
      iconDataCodePoint: Icons.home_sharp.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Children & Babies',
      iconDataCodePoint: Icons.child_friendly.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Home Improvement',
      iconDataCodePoint: Icons.home.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Home Service',
      iconDataCodePoint: Icons.home_repair_service.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Pets',
      iconDataCodePoint: Icons.pets.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Education
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Education',
      iconDataCodePoint: Icons.school.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
    await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Books',
      iconDataCodePoint: Icons.menu_book.codePoint,
      isIgnored: false,
      isSubCategory: true,
      categoryGroup: category.id,
    ));

    // Investment
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Investment',
      iconDataCodePoint: Icons.analytics.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Insurances
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Insurances',
      iconDataCodePoint: Icons.verified_user.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Fees & Charges
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Fees & Charges',
      iconDataCodePoint: Icons.payments.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Withdrawal
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Withdrawal',
      iconDataCodePoint: Icons.point_of_sale.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Loan Repayment
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Loan Repayment',
      iconDataCodePoint: Icons.arrow_circle_right.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Lend
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Lend',
      iconDataCodePoint: Icons.arrow_circle_right.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));

    // Other Expense
    category = await insert(Category(
      id: const Uuid().v4(),
      recordType: RecordType.expense,
      name: 'Other Expense',
      iconDataCodePoint: Icons.shopping_cart.codePoint,
      isIgnored: false,
      isSubCategory: false,
      categoryGroup: null,
    ));
  }
}
