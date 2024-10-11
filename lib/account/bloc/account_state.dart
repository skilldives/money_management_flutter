part of 'account_bloc.dart';

@immutable
abstract class AccountState {
  final bool isDeleteOperation;
  final bool isDeleted;
  final bool isUpdateOperation;
  final bool isUpdated;
  const AccountState({
    required this.isDeleteOperation,
    required this.isDeleted,
    required this.isUpdateOperation,
    required this.isUpdated,
  });
}

class AccountInitial extends AccountState {
  const AccountInitial({
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
  });
}

class AccountStateUpdateFromAccount extends AccountState {
  final Account account;

  const AccountStateUpdateFromAccount({required this.account})
      : super(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        );
}

class AccountStateUpdateToAccount extends AccountState {
  final Account account;

  const AccountStateUpdateToAccount({required this.account})
      : super(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        );
}

class AccountStateLoading extends AccountState {
  const AccountStateLoading({
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
  });
}

class AccountStateEmptyFetch extends AccountState {
  const AccountStateEmptyFetch({
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
  });
}

class AccountStateFetched extends AccountState {
  final List<Account> accounts;
  final Map<String, String> amountMap;
  final String totalIncome;
  final String totalExpense;
  final String totalBalance;

  const AccountStateFetched({
    required this.accounts,
    required this.amountMap,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
  });
}
