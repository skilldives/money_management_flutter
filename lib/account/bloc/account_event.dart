part of 'account_bloc.dart';

@immutable
abstract class AccountEvent {
  const AccountEvent();
}

class AccountEventUpdateFromAccount extends AccountEvent {
  final Account account;

  const AccountEventUpdateFromAccount({required this.account});
}

class AccountEventUpdateToAccount extends AccountEvent {
  final Account account;

  const AccountEventUpdateToAccount({required this.account});
}

class AccountEventFetch extends AccountEvent {
  final bool isDeleteOperation;
  final bool isDeleted;
  final bool isUpdateOperation;
  final bool isUpdated;

  const AccountEventFetch({
    required this.isDeleteOperation,
    required this.isDeleted,
    required this.isUpdateOperation,
    required this.isUpdated,
  });
}

class AccountEventInsert extends AccountEvent {
  final Account account;

  const AccountEventInsert({required this.account});
}

class AccountEventUpdate extends AccountEvent {
  final Account account;

  const AccountEventUpdate({required this.account});
}

class AccountEventDelete extends AccountEvent {
  final Account account;

  const AccountEventDelete({required this.account});
}
