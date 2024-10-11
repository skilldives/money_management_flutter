import 'package:equatable/equatable.dart';
import 'package:money_management/category/model/category.dart'
    show tableCategory;
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:sqflite/sqflite.dart';

const String tableBudget = 'budget';
const String columnId = 'id';
const String columnCategory = 'category';
const String columnGoal = 'goal';
const String columnToDate = 'to_date';
const String columnFromDate = 'from_date';
const String columnShouldRenew = 'should_renew';

class Budget extends Equatable {
  final String id;
  final String category;
  final num goal;
  final DateTime toDate;
  final DateTime fromDate;
  final bool shouldRenew;

  const Budget({
    required this.id,
    required this.category,
    required this.goal,
    required this.toDate,
    required this.fromDate,
    required this.shouldRenew,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: id,
      columnCategory: category,
      columnGoal: goal,
      columnToDate: toDate.millisecondsSinceEpoch,
      columnFromDate: fromDate.millisecondsSinceEpoch,
      columnShouldRenew: shouldRenew == true ? 1 : 0,
    };
    return map;
  }

  Budget.fromMap(Map<String, Object?> map)
      : id = map[columnId] as String,
        category = map[columnCategory] as String,
        goal = map[columnGoal] as num,
        toDate = DateTime.fromMillisecondsSinceEpoch(map[columnToDate] as int),
        fromDate =
            DateTime.fromMillisecondsSinceEpoch(map[columnFromDate] as int),
        shouldRenew = (map[columnShouldRenew] as int) == 1;

  @override
  List<Object?> get props => [id];
}

class BudgetProvider {
  Database db;

  BudgetProvider(this.db);

  Future crateTable() async {
    const createBudgetTable = '''
        CREATE TABLE IF NOT EXISTS $tableBudget ( 
	$columnId                   TEXT NOT NULL  PRIMARY KEY  ,
	$columnCategory             TEXT NOT NULL    ,
	$columnGoal                REAL NOT NULL    ,
	$columnToDate              INTEGER NOT NULL    ,
	$columnFromDate            INTEGER NOT NULL    ,
	$columnShouldRenew         INTEGER NOT NULL    ,
	FOREIGN KEY ( $columnCategory ) REFERENCES $tableCategory( $columnId ) ON DELETE CASCADE ON UPDATE CASCADE
 );
''';
    // Create category table
    await db.execute(createBudgetTable);
  }

  Future<Budget> insert(Budget budget) async {
    await db.insert(tableBudget, budget.toMap());
    return budget;
  }

  Future<Budget> getBudget(String id) async {
    final maps = await db.query(tableBudget,
        columns: [
          columnId,
          columnCategory,
          columnGoal,
          columnToDate,
          columnFromDate,
          columnShouldRenew,
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    } else {
      throw CouldNotFindBudget();
    }
  }

  Future<int> delete(String id) async {
    int count =
        await db.delete(tableBudget, where: '$columnId = ?', whereArgs: [id]);
    if (count == 0) {
      throw CouldNotDeleteBudget();
    }
    return count;
  }

  Future<int> update(Budget budget) async {
    int count = await db.update(tableBudget, budget.toMap(),
        where: '$columnId = ?', whereArgs: [budget.id]);
    if (count == 0) {
      throw CouldNotUpdateBudget();
    }
    return count;
  }

  Future close() async => db.close();
}
