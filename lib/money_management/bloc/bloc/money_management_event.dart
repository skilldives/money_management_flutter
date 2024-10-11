part of 'money_management_bloc.dart';

@immutable
sealed class MoneyManagementEvent {
  const MoneyManagementEvent();
}

class MMEventFetchCurrency extends MoneyManagementEvent {
  const MMEventFetchCurrency();
}

class MMEventUpdateCurrency extends MoneyManagementEvent {
  final Currency currency;
  const MMEventUpdateCurrency({required this.currency});
}
