import 'package:money_management/account/model/account.dart';
import 'package:money_management/service/storage_service_sql.dart';

class AccountService {
  static final AccountService _shared = AccountService._sharedInstance();

  AccountService._sharedInstance();

  factory AccountService() => _shared;

  StorageService storageService = StorageService();

  Future<Map<String, Account>> getAccountMap() async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    List<Account> accounts = await AccountProvider(db).getAllAccounts();
    Map<String, Account> accountMap = {};
    for (var element in accounts) {
      accountMap[element.id] = element;
    }
    return accountMap;
  }

  Future<List<Account>> getAccountList() async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    List<Account> accounts = await AccountProvider(db).getAllAccounts();
    return accounts;
  }

  createNewAccount(Account account) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await AccountProvider(db).insert(account);
  }

  updateAccount(Account account) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await AccountProvider(db).update(account);
  }

  deleteAccount({
    required Account account,
  }) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await AccountProvider(db).delete(account.id);
  }
}
