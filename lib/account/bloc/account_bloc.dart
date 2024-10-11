import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/account/service/account_service.dart';
import 'package:money_management/record/service/record_service.dart';
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountService accountService = AccountService();
  RecordService recordService = RecordService();

  AccountBloc()
      : super(const AccountInitial(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        )) {
    on<AccountEventUpdateFromAccount>(accountEventUpdateFromAccount);

    on<AccountEventUpdateToAccount>(accountEventUpdateToAccount);

    on<AccountEventFetch>(accountEventFetch);

    on<AccountEventInsert>(accountEventInsert);
    on<AccountEventDelete>(accountEventDelete);
    on<AccountEventUpdate>(accountEventUpdate);
  }

  FutureOr<void> accountEventInsert(event, emit) async {
    Account account = event.account;
    await accountService.createNewAccount(account);
    add(const AccountEventFetch(
      isDeleteOperation: false,
      isDeleted: false,
      isUpdateOperation: false,
      isUpdated: false,
    ));
  }

  FutureOr<void> accountEventFetch(
    AccountEventFetch event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountStateLoading(
      isDeleteOperation: event.isDeleteOperation,
      isDeleted: event.isDeleted,
      isUpdateOperation: event.isUpdateOperation,
      isUpdated: event.isUpdated,
    ));
    try {
      List<Account> accounts = await accountService.getAccountList();
      List<rc.Record> records = [];
      try {
        records = await recordService.getAllRecords();
      } catch (_) {}
      Map<String, String> amountMap = {};
      for (var account in accounts) {
        String amount = await CommonUtil.getAmountWithIconByRecordType(
          amount: account.initialAmount.abs(),
          recordType: (account.initialAmount < 0)
              ? RecordType.expense
              : RecordType.transfer,
        );
        amountMap[account.id] = amount;
      }
      num expense = 0;
      num income = 0;
      for (var record in records) {
        if (RecordType.expense == record.recordType) {
          expense += record.amount;
        } else if (RecordType.income == record.recordType) {
          income += record.amount;
        }
      }

      String totalIncome = await CommonUtil.getAmountWithIconByRecordType(
        amount: income,
        recordType: RecordType.income,
      );
      String totalExpense = await CommonUtil.getAmountWithIconByRecordType(
        amount: expense,
        recordType: RecordType.expense,
      );
      String totalBalance = await CommonUtil.getAmountWithIconByRecordType(
        amount: (income - expense).abs(),
        recordType:
            (income - expense) < 0 ? RecordType.expense : RecordType.transfer,
      );
      emit(AccountStateFetched(
        accounts: accounts,
        amountMap: amountMap,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        totalBalance: totalBalance,
        isDeleteOperation: event.isDeleteOperation,
        isDeleted: event.isDeleted,
        isUpdateOperation: event.isUpdateOperation,
        isUpdated: event.isUpdated,
      ));
    } on CouldNotFindAccount {
      emit(AccountStateEmptyFetch(
        isDeleteOperation: event.isDeleteOperation,
        isDeleted: event.isDeleted,
        isUpdateOperation: event.isUpdateOperation,
        isUpdated: event.isUpdated,
      ));
    }
  }

  FutureOr<void> accountEventUpdateToAccount(event, emit) {
    emit(AccountStateUpdateToAccount(account: event.account));
  }

  FutureOr<void> accountEventUpdateFromAccount(event, emit) {
    emit(AccountStateUpdateFromAccount(account: event.account));
  }

  FutureOr<void> accountEventDelete(
    AccountEventDelete event,
    Emitter<AccountState> emit,
  ) async {
    Account account = event.account;
    try {
      await accountService.deleteAccount(account: account);
      add(const AccountEventFetch(
        isDeleteOperation: true,
        isDeleted: true,
        isUpdateOperation: false,
        isUpdated: false,
      ));
    } catch (e) {
      add(const AccountEventFetch(
        isDeleteOperation: true,
        isDeleted: false,
        isUpdateOperation: false,
        isUpdated: false,
      ));
    }
  }

  FutureOr<void> accountEventUpdate(
    AccountEventUpdate event,
    Emitter<AccountState> emit,
  ) async {
    try {
      Account account = event.account;
      await accountService.updateAccount(account);
      add(const AccountEventFetch(
        isDeleteOperation: false,
        isDeleted: false,
        isUpdateOperation: true,
        isUpdated: true,
      ));
    } catch (_) {
      add(const AccountEventFetch(
        isDeleteOperation: false,
        isDeleted: false,
        isUpdateOperation: true,
        isUpdated: false,
      ));
    }
  }
}
