import 'dart:async';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/model/others.dart';
import 'package:money_management/util/common_util.dart';

part 'money_management_event.dart';
part 'money_management_state.dart';

class MoneyManagementBloc
    extends Bloc<MoneyManagementEvent, MoneyManagementState> {
  MoneyManagementBloc() : super(MoneyManagementInitial()) {
    on<MMEventFetchCurrency>(mmEventFetchCurrency);
    on<MMEventUpdateCurrency>(mmEventUpdateCurrency);
  }

  FutureOr<void> mmEventFetchCurrency(
    MMEventFetchCurrency event,
    Emitter<MoneyManagementState> emit,
  ) async {
    Others others = await CommonUtil.getOthers();
    emit(MMCurrencyFetched(others: others));
  }

  FutureOr<void> mmEventUpdateCurrency(
    MMEventUpdateCurrency event,
    Emitter<MoneyManagementState> emit,
  ) async {
    Others others = await CommonUtil.getOthers();
    Others updatedOthers = Others(
      id: others.id,
      currencyName: event.currency.name,
      currencySymbol: event.currency.symbol,
      currencyCode: event.currency.code,
      currencyNumber: event.currency.number,
      isSymbolOnLeft: event.currency.symbolOnLeft,
      isSpaceBetweenAmountAndSymbol: event.currency.spaceBetweenAmountAndSymbol,
      lastBackUpDateTime: others.lastBackUpDateTime,
      isCloudSynced: others.isCloudSynced,
    );
    await CommonUtil.updateOthersTable(updatedOthers);
    emit(MMCurrencyFetched(others: updatedOthers));
    emit(MMCurrencyUpdated());
  }
}
