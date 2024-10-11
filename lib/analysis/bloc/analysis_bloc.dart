import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/category/model/category.dart' as ct;
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/util/constants/money_enum.dart';

part 'analysis_event.dart';
part 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  AnalysisBloc() : super(AnalysisInitial()) {
    on<AnalysisEvent>((event, emit) {});
    on<AnalysisEventFetch>(analysisEventFetch);
    on<AnalysisEventLoading>(analysisEventLoading);
  }

  FutureOr<void> analysisEventFetch(
    AnalysisEventFetch event,
    Emitter<AnalysisState> emit,
  ) {
    final List<rc.Record> records = event.records;
    final Map<String, ct.Category> categoryMap = event.categoryMap;
    final Map<String, Account> accountMap = event.accountMap;
    emit(AnalysisStateLoading());
    if (records.isEmpty) {
      emit(AnalysisStateEmpty());
    } else {
      Map<ct.Category, ct.Category> childParent = {};
      categoryMap.forEach((key, value) {
        if (!value.isSubCategory) {
          childParent[value] = value;
        } else {
          childParent[value] = categoryMap[value.categoryGroup]!;
        }
      });

      Map<ct.Category, Map<ct.Category, num>> expenseOverview = {};
      Map<ct.Category, Map<ct.Category, num>> incomeOverview = {};
      List<rc.Record> expenseFlow = [];
      List<rc.Record> incomeFlow = [];
      Map<Account, num> accountAnalysis = {};

      for (rc.Record record in records) {
        if (RecordType.income == record.recordType) {
          ct.Category parent = childParent[categoryMap[record.category]]!;
          ct.Category child = categoryMap[record.category]!;
          incomeOverview.update(
            parent,
            (value) {
              var temp = value;
              temp.update(
                child,
                (value2) => value2 + record.amount,
                ifAbsent: () => record.amount,
              );
              return temp;
            },
            ifAbsent: () => {child: record.amount},
          );

          incomeFlow.add(record);
          accountAnalysis.update(
            accountMap[record.fromAccount]!,
            (value) => value + record.amount,
            ifAbsent: () => record.amount,
          );
        } else if (RecordType.expense == record.recordType) {
          ct.Category parent = childParent[categoryMap[record.category]]!;
          ct.Category child = categoryMap[record.category]!;
          expenseOverview.update(
            parent,
            (value) {
              var temp = value;
              temp.update(
                child,
                (value2) => value2 + record.amount,
                ifAbsent: () => record.amount,
              );
              return temp;
            },
            ifAbsent: () => {child: record.amount},
          );
          expenseFlow.add(record);
          accountAnalysis.update(
            accountMap[record.fromAccount]!,
            (value) => value + record.amount,
            ifAbsent: () => record.amount,
          );
        }
      }

      emit(AnalysisStateCompleted(
          incomeOverview: incomeOverview,
          expenseOverview: expenseOverview,
          expenseFlow: expenseFlow,
          incomeFlow: incomeFlow,
          accountAnalysis: accountAnalysis));
    }
  }

  FutureOr<void> analysisEventLoading(
    AnalysisEventLoading event,
    Emitter<AnalysisState> emit,
  ) {
    emit(AnalysisStateLoading());
  }
}
