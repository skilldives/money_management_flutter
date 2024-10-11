import 'package:equatable/equatable.dart';
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const String tableOthers = 'others';
const String columnId = 'id';
const String columnCurrencyName = 'currency_name';
const String columnCurrencySymbol = 'currency_symbol';
const String columnCurrencyCode = 'currency_code';
const String columnCurrencyNumber = 'currency_number';
const String columnIsSymbolOnLeft = 'is_symbol_on_left';
const String columnIsSpaceBetweenAmountAndSymbol =
    'is_space_between_amount_and_symbol';
const String columnLastBackUpDateTime = 'last_back_up_date_time';
const String columnIsCloudSynced = 'is_cloud_synced';

class Others extends Equatable {
  final String id;
  final String currencyName;
  final String currencySymbol;
  final String currencyCode;
  final int currencyNumber;
  final bool isSymbolOnLeft;
  final bool isSpaceBetweenAmountAndSymbol;
  final DateTime lastBackUpDateTime;
  final bool isCloudSynced;

  const Others({
    required this.id,
    required this.currencyName,
    required this.currencySymbol,
    required this.currencyCode,
    required this.currencyNumber,
    required this.isSymbolOnLeft,
    required this.isSpaceBetweenAmountAndSymbol,
    required this.lastBackUpDateTime,
    required this.isCloudSynced,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: id,
      columnCurrencyName: currencyName,
      columnCurrencySymbol: currencySymbol,
      columnCurrencyCode: currencyCode,
      columnCurrencyNumber: currencyNumber,
      columnIsSymbolOnLeft: isSymbolOnLeft == true ? 1 : 0,
      columnIsSpaceBetweenAmountAndSymbol:
          isSpaceBetweenAmountAndSymbol == true ? 1 : 0,
      columnLastBackUpDateTime: lastBackUpDateTime.millisecondsSinceEpoch,
      columnIsCloudSynced: isCloudSynced == true ? 1 : 0,
    };
    return map;
  }

  Others.fromMap(Map<String, Object?> map)
      : id = map[columnId] as String,
        currencyName = map[columnCurrencyName] as String,
        currencySymbol = map[columnCurrencySymbol] as String,
        currencyCode = map[columnCurrencyCode] as String,
        currencyNumber = map[columnCurrencyNumber] as int,
        isSymbolOnLeft = (map[columnIsSymbolOnLeft] as int) == 1,
        isSpaceBetweenAmountAndSymbol =
            (map[columnIsSpaceBetweenAmountAndSymbol] as int) == 1,
        lastBackUpDateTime = DateTime.fromMillisecondsSinceEpoch(
            map[columnLastBackUpDateTime] as int),
        isCloudSynced = (map[columnIsCloudSynced] as int) == 1;

  @override
  List<Object?> get props => [id];
}

class OthersProvider {
  Database db;
  OthersProvider(this.db);

  Future<Others> insert(Others others) async {
    await db.insert(tableOthers, others.toMap());
    return others;
  }

  Future<int> update(Others others) async {
    int count = await db.update(
      tableOthers,
      others.toMap(),
      where: '$columnId = ?',
      whereArgs: [others.id],
    );
    if (count == 0) {
      throw CouldNotDeleteOthers();
    }
    return count;
  }

  Future<Others> getOthers() async {
    final maps = await db.query(
      tableOthers,
      columns: [
        columnId,
        columnCurrencyName,
        columnCurrencySymbol,
        columnCurrencyCode,
        columnCurrencyNumber,
        columnIsSymbolOnLeft,
        columnIsSpaceBetweenAmountAndSymbol,
        columnLastBackUpDateTime,
        columnIsCloudSynced,
      ],
    );
    if (maps.isNotEmpty) {
      return Others.fromMap(maps.first);
    } else {
      throw CouldNotFindOthers();
    }
  }

  Future crateTable() async {
    const createOthersTable = '''
        CREATE TABLE IF NOT EXISTS $tableOthers ( 
	$columnId                   TEXT NOT NULL  PRIMARY KEY  ,
	$columnCurrencyName        TEXT NOT NULL    ,
	$columnCurrencySymbol      TEXT NOT NULL    ,
	$columnCurrencyCode        TEXT NOT NULL    ,
	$columnCurrencyNumber      INTEGER NOT NULL    ,
	$columnIsSymbolOnLeft    INTEGER NOT NULL    ,
	$columnIsSpaceBetweenAmountAndSymbol INTEGER NOT NULL    ,
	$columnLastBackUpDateTime INTEGER NOT NULL    ,
	$columnIsCloudSynced      INTEGER NOT NULL    
 );
''';
    // Create record table
    await db.execute(createOthersTable);
    await insert(Others(
      id: const Uuid().v4(),
      currencyName: 'Indian Rupee',
      currencySymbol: '₹',
      currencyCode: 'INR',
      currencyNumber: 356,
      isSymbolOnLeft: true,
      isSpaceBetweenAmountAndSymbol: false,
      lastBackUpDateTime: DateTime.now(),
      isCloudSynced: false,
    ));
  }
}
