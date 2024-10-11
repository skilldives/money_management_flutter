import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/category/model/category.dart' as ct;
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/account/service/account_service.dart';
import 'package:money_management/category/service/category_service.dart';
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:money_management/record/service/record_service.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

import '../../account/model/account.dart';

part 'record_event.dart';
part 'record_state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  RecordService recordService = RecordService();
  CategoryService categoryService = CategoryService();
  AccountService accountService = AccountService();
  DateTime dateTime = DateTime.now();

  RecordBloc()
      : super(RecordManagementInitial(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
          viewMode: ViewMode.monthly,
          startDateTime: DateTime.now(),
          endDateTime: DateTime.now(),
          dateTimeText: '',
        )) {
    on<RecordEventFetch>(recordEventFetch);

    on<RecordEventInsert>(recordEventInsert);

    on<RecordEventDelete>(recordEventDelete);

    on<RecordEventViewMode>(recordEventViewMode);
    on<RecordEventNext>(recordEventNext);
    on<RecordEventPrevious>(recordEventPrevious);
    on<RecordEventUpdate>(recordEventUpdate);
  }

  FutureOr<void> recordEventFetch(
    RecordEventFetch event,
    Emitter<RecordState> emit,
  ) async {
    emit(RecordStateLoading(
      isDeleteOperation: event.isDeleteOperation,
      isDeleted: event.isDeleted,
      isUpdateOperation: event.isUpdateOperation,
      isUpdated: event.isUpdated,
      viewMode: event.viewMode,
      startDateTime: event.startDateTime,
      endDateTime: event.endDateTime,
      dateTimeText: event.dateTimeText,
    ));
    try {
      List<rc.Record> records = await recordService.getAllRecordsByRange(
        startDateTime: event.startDateTime,
        endDateTime: event.endDateTime,
      );
      Map<String, ct.Category> categoryMap =
          await categoryService.getCategoryMap();
      Map<String, Account> accountMap = await accountService.getAccountMap();
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
      emit(RecordStateFetched(
        records: records,
        categoryMap: categoryMap,
        accountMap: accountMap,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        totalBalance: totalBalance,
        isDeleteOperation: event.isDeleteOperation,
        isDeleted: event.isDeleted,
        isUpdateOperation: event.isUpdateOperation,
        isUpdated: event.isUpdated,
        viewMode: event.viewMode,
        startDateTime: event.startDateTime,
        endDateTime: event.endDateTime,
        dateTimeText: event.dateTimeText,
      ));
    } on CouldNotFindRecord {
      emit(RecordStateEmptyFetch(
        isDeleteOperation: event.isDeleteOperation,
        isDeleted: event.isDeleted,
        isUpdateOperation: event.isUpdateOperation,
        isUpdated: event.isUpdated,
        viewMode: event.viewMode,
        startDateTime: event.startDateTime,
        endDateTime: event.endDateTime,
        dateTimeText: event.dateTimeText,
      ));
    }
  }

  FutureOr<void> recordEventInsert(
    RecordEventInsert event,
    Emitter<RecordState> emit,
  ) async {
    rc.Record record = event.record;
    await recordService.createNewRecord(
      record: record,
      fromAccount: record.fromAccount,
      toAccount: record.toAccount,
      amount: record.amount,
    );
    add(RecordEventViewMode(
      viewMode: event.viewMode,
      isDeleteOperation: false,
      isDeleted: false,
      isUpdateOperation: false,
      isUpdated: false,
    ));
  }

  FutureOr<void> recordEventDelete(
    RecordEventDelete event,
    Emitter<RecordState> emit,
  ) async {
    rc.Record record = event.record;
    try {
      await recordService.deleteRecord(record: record);
      add(RecordEventViewMode(
        isDeleteOperation: true,
        isDeleted: true,
        isUpdateOperation: false,
        isUpdated: false,
        viewMode: event.viewMode,
      ));
    } catch (_) {
      add(RecordEventViewMode(
        isDeleteOperation: true,
        isDeleted: false,
        isUpdateOperation: false,
        isUpdated: false,
        viewMode: event.viewMode,
      ));
    }
  }

  FutureOr<void> recordEventViewMode(
    RecordEventViewMode event,
    Emitter<RecordState> emit,
  ) {
    String text = '';
    DateTime startDatetime = dateTime;
    DateTime endDatetime = dateTime;
    if (ViewMode.daily == event.viewMode) {
      text =
          '${CommonUtil.resolveMonth(dateTime).substring(0, 3)} ${dateTime.day}, ${dateTime.year}';
      startDatetime = DateTime(dateTime.year, dateTime.month, dateTime.day);
      endDatetime =
          DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
    } else if (ViewMode.weekly == event.viewMode) {
      DateTime weekBack = dateTime.subtract(const Duration(days: 6));
      text =
          '${CommonUtil.resolveMonth(weekBack).substring(0, 3)} ${weekBack.day} - ${CommonUtil.resolveMonth(dateTime).substring(0, 3)} ${dateTime.day}';
      startDatetime = DateTime(weekBack.year, weekBack.month, weekBack.day);
      endDatetime =
          DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
    } else if (ViewMode.monthly == event.viewMode) {
      text = '${CommonUtil.resolveMonth(dateTime)}, ${dateTime.year}';
      startDatetime = DateTime(dateTime.year, dateTime.month, 1);
      endDatetime = DateTime(dateTime.year, dateTime.month + 1, 0, 23, 59, 59);
    } else if (ViewMode.yearly == event.viewMode) {
      text = '${dateTime.year}';
      startDatetime = DateTime(dateTime.year, 01);
      endDatetime = DateTime(dateTime.year, 12, 31, 23, 59, 59);
    }
    add(RecordEventFetch(
      startDateTime: startDatetime,
      endDateTime: endDatetime,
      viewMode: event.viewMode,
      dateTimeText: text,
      isDeleteOperation: event.isDeleteOperation,
      isDeleted: event.isDeleted,
      isUpdateOperation: event.isUpdateOperation,
      isUpdated: event.isUpdated,
    ));
  }

  FutureOr<void> recordEventNext(
    RecordEventNext event,
    Emitter<RecordState> emit,
  ) {
    DateTime oldStartDateTime = event.startDateTime;
    DateTime oldEndDateTime = event.endDateTime;
    DateTime newStartDateTime = event.startDateTime;
    DateTime newEndDateTime = event.endDateTime;
    String text = '';
    if (ViewMode.daily == event.viewMode) {
      oldStartDateTime = oldStartDateTime.add(const Duration(days: 1));
      oldEndDateTime = oldEndDateTime.add(const Duration(days: 1));
      text =
          '${CommonUtil.resolveMonth(oldStartDateTime).substring(0, 3)} ${oldStartDateTime.day}, ${oldStartDateTime.year}';
      newStartDateTime = DateTime(
          oldStartDateTime.year, oldStartDateTime.month, oldStartDateTime.day);
      newEndDateTime = DateTime(oldEndDateTime.year, oldEndDateTime.month,
          oldEndDateTime.day, 23, 59, 59);
    } else if (ViewMode.weekly == event.viewMode) {
      oldStartDateTime = oldStartDateTime.add(const Duration(days: 7));
      oldEndDateTime = oldEndDateTime.add(const Duration(days: 7));
      text =
          '${CommonUtil.resolveMonth(oldStartDateTime).substring(0, 3)} ${oldStartDateTime.day} - ${CommonUtil.resolveMonth(oldEndDateTime).substring(0, 3)} ${oldEndDateTime.day}';
      newStartDateTime = DateTime(
          oldStartDateTime.year, oldStartDateTime.month, oldStartDateTime.day);
      newEndDateTime = DateTime(oldEndDateTime.year, oldEndDateTime.month,
          oldEndDateTime.day, 23, 59, 59);
    } else if (ViewMode.monthly == event.viewMode) {
      int year = oldStartDateTime.month == 12
          ? oldStartDateTime.year + 1
          : oldStartDateTime.year;
      int month =
          oldStartDateTime.month % 12 == 0 ? 1 : oldStartDateTime.month + 1;
      newStartDateTime = DateTime(year, month, 1);
      newEndDateTime = DateTime(year, month + 1, 0, 23, 59, 59);
      text =
          '${CommonUtil.resolveMonth(newStartDateTime)}, ${newStartDateTime.year}';
    } else if (ViewMode.yearly == event.viewMode) {
      newStartDateTime = DateTime(oldStartDateTime.year + 1, 01);
      newEndDateTime = DateTime(oldStartDateTime.year + 1, 12, 31, 23, 59, 59);
      text = '${newStartDateTime.year}';
    }

    add(RecordEventFetch(
      startDateTime: newStartDateTime,
      endDateTime: newEndDateTime,
      viewMode: event.viewMode,
      dateTimeText: text,
      isDeleteOperation: false,
      isDeleted: false,
      isUpdateOperation: false,
      isUpdated: false,
    ));
  }

  FutureOr<void> recordEventPrevious(
    RecordEventPrevious event,
    Emitter<RecordState> emit,
  ) {
    DateTime oldStartDateTime = event.startDateTime;
    DateTime oldEndDateTime = event.endDateTime;
    DateTime newStartDateTime = event.startDateTime;
    DateTime newEndDateTime = event.endDateTime;
    String text = '';
    if (ViewMode.daily == event.viewMode) {
      oldStartDateTime = oldStartDateTime.subtract(const Duration(days: 1));
      oldEndDateTime = oldEndDateTime.subtract(const Duration(days: 1));
      text =
          '${CommonUtil.resolveMonth(oldStartDateTime).substring(0, 3)} ${oldStartDateTime.day}, ${oldStartDateTime.year}';
      newStartDateTime = DateTime(
          oldStartDateTime.year, oldStartDateTime.month, oldStartDateTime.day);
      newEndDateTime = DateTime(oldEndDateTime.year, oldEndDateTime.month,
          oldEndDateTime.day, 23, 59, 59);
    } else if (ViewMode.weekly == event.viewMode) {
      oldStartDateTime = oldStartDateTime.subtract(const Duration(days: 7));
      oldEndDateTime = oldEndDateTime.subtract(const Duration(days: 7));
      text =
          '${CommonUtil.resolveMonth(oldStartDateTime).substring(0, 3)} ${oldStartDateTime.day} - ${CommonUtil.resolveMonth(oldEndDateTime).substring(0, 3)} ${oldEndDateTime.day}';
      newStartDateTime = DateTime(
          oldStartDateTime.year, oldStartDateTime.month, oldStartDateTime.day);
      newEndDateTime = DateTime(oldEndDateTime.year, oldEndDateTime.month,
          oldEndDateTime.day, 23, 59, 59);
    } else if (ViewMode.monthly == event.viewMode) {
      int year = oldStartDateTime.month == 1
          ? oldStartDateTime.year - 1
          : oldStartDateTime.year;
      int month = oldStartDateTime.month == 1 ? 12 : oldStartDateTime.month - 1;
      newStartDateTime = DateTime(year, month, 1);
      newEndDateTime = DateTime(year, month + 1, 0, 23, 59, 59);
      text =
          '${CommonUtil.resolveMonth(newStartDateTime)}, ${newStartDateTime.year}';
    } else if (ViewMode.yearly == event.viewMode) {
      newStartDateTime = DateTime(oldStartDateTime.year - 1, 01);
      newEndDateTime = DateTime(oldStartDateTime.year - 1, 12, 31, 23, 59, 59);
      text = '${newStartDateTime.year}';
    }

    add(RecordEventFetch(
      startDateTime: newStartDateTime,
      endDateTime: newEndDateTime,
      viewMode: event.viewMode,
      dateTimeText: text,
      isDeleteOperation: false,
      isDeleted: false,
      isUpdateOperation: false,
      isUpdated: false,
    ));
  }

  FutureOr<void> recordEventUpdate(
    RecordEventUpdate event,
    Emitter<RecordState> emit,
  ) async {
    rc.Record newRecord = event.newRecord;
    rc.Record oldRecord = event.oldRecord;
    try {
      await recordService.updateRecord(
        newRecord: newRecord,
        oldRecord: oldRecord,
      );
      add(RecordEventViewMode(
        viewMode: event.viewMode,
        isDeleteOperation: false,
        isDeleted: false,
        isUpdateOperation: true,
        isUpdated: true,
      ));
    } catch (_) {
      add(RecordEventViewMode(
        viewMode: event.viewMode,
        isDeleteOperation: false,
        isDeleted: false,
        isUpdateOperation: true,
        isUpdated: false,
      ));
    }
  }
}
