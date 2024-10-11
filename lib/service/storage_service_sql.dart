import 'dart:async';

import 'package:currency_picker/currency_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:money_management/auth/service/login_service.dart';
import 'package:money_management/budget/model/budget.dart';
import 'package:money_management/model/others.dart';
import 'package:money_management/record/model/record.dart';
import 'package:money_management/service/exception/auth_exception.dart';
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:money_management/service/google_auth_client.dart';
import 'package:money_management/util/common_util.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:io' as dd;

import '../account/model/account.dart';
import '../category/model/category.dart';

const dbName = 'expense.db';

class StorageService {
  static final StorageService _shared = StorageService._sharedInstance();

  StorageService._sharedInstance();

  factory StorageService() => _shared;

  Database? _db;

  Database getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> initializeDatabase() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          AccountProvider accountProvider = AccountProvider(db);
          CategoryProvider categoryProvider = CategoryProvider(db);
          RecordProvider recordProvider = RecordProvider(db);
          BudgetProvider budgetProvider = BudgetProvider(db);
          OthersProvider othersProvider = OthersProvider(db);
          await accountProvider.crateTable();
          await categoryProvider.crateTable();
          await recordProvider.crateTable();
          await budgetProvider.crateTable();
          await othersProvider.crateTable();
        },
      );
      _db = db;
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  final LoginService _loginService = LoginService();

  Future<drive.DriveApi> getDriveApi() async {
    GoogleSignInAccount? googleSignInAccount =
        await _loginService.currentAccount;

    var headers = await googleSignInAccount?.authHeaders;
    if (headers == null) {
      try {
        await _loginService.googleLogIn();
        googleSignInAccount ??= await _loginService.currentAccount;

        headers = await googleSignInAccount?.authHeaders;
      } catch (e) {
        throw Exception(e);
      }
    }
    final client = GoogleAuthClient(headers!);
    drive.DriveApi driveApi = drive.DriveApi(client);
    return driveApi;
  }

  Future<String> getDriveDBFileId(drive.DriveApi driveApi) async {
    final fileList = await driveApi.files.list(
        q: "name = '$dbName'",
        spaces: 'appDataFolder',
        $fields: 'files(id, name, modifiedTime)');
    final files = fileList.files;
    String fileId = files == null || files.isEmpty ? '' : files.first.id!;
    return fileId;
  }

  Future<Media?> syncDataWithDrive(Currency currency) async {
    DriveApi driveApi;
    try {
      driveApi = await getDriveApi();
    } catch (_) {
      throw DriveApiNotFoundException();
    }
    try {
      String fileId = await getDriveDBFileId(driveApi);
      Media? response;
      if (fileId.isEmpty) {
        uploadDatabaseIntoDrive(currency: currency);
        return response;
      } else {
        // Download the file content
        response = await driveApi.files.get(
          fileId,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as Media;
      }
      return response;
    } catch (_) {
      throw SynchronizationFailedException();
    }
  }

  Future<void> uploadDatabaseIntoDrive({Currency? currency}) async {
    DriveApi driveApi;
    try {
      driveApi = await getDriveApi();
    } catch (_) {
      throw DriveApiNotFoundException();
    }
    Others others = await CommonUtil.getOthers();
    await CommonUtil.updateOthersTable(Others(
      id: others.id,
      currencyName: currency == null ? others.currencyName : currency.name,
      currencySymbol:
          currency == null ? others.currencySymbol : currency.symbol,
      currencyCode: currency == null ? others.currencyCode : currency.code,
      currencyNumber:
          currency == null ? others.currencyNumber : currency.number,
      isSymbolOnLeft:
          currency == null ? others.isSymbolOnLeft : currency.symbolOnLeft,
      isSpaceBetweenAmountAndSymbol: currency == null
          ? others.isSpaceBetweenAmountAndSymbol
          : currency.spaceBetweenAmountAndSymbol,
      lastBackUpDateTime: DateTime.now(),
      isCloudSynced: true,
    ));
    try {
      String fileId = await getDriveDBFileId(driveApi);
      // Set up File info
      var driveFile = drive.File();

      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      dd.File databaseFile = dd.File(dbPath);
      final databaseContentStream = databaseFile.openRead();

      final media = drive.Media(
        databaseContentStream,
        databaseFile.lengthSync(),
      );
      if (fileId.isEmpty) {
        driveFile.name = dbName;
        driveFile.modifiedTime = DateTime.now().toUtc();
        driveFile.parents = ["appDataFolder"];
        await driveApi.files.create(driveFile, uploadMedia: media);
      } else {
        await driveApi.files.update(driveFile, fileId, uploadMedia: media);
      }
    } catch (_) {
      throw UploadFailedException();
    }
  }
}
