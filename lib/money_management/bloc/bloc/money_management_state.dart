part of 'money_management_bloc.dart';

@immutable
sealed class MoneyManagementState {}

final class MoneyManagementInitial extends MoneyManagementState {}

final class MMCurrencyFetched extends MoneyManagementState {
  final Others others;
  MMCurrencyFetched({required this.others});
}

final class MMCurrencyUpdated extends MoneyManagementState {}
