import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/category/model/category.dart' as ct;
import 'package:money_management/category/service/category_service.dart';
import 'package:money_management/service/exception/storage_service_exception.dart';
import 'package:money_management/util/constants/money_enum.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryService categoryService = CategoryService();

  CategoryBloc()
      : super(const CategoryInitial(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        )) {
    on<CategoryEventUpdateIncome>(categoryEventUpdateIncome);

    on<CategoryEventUpdateExpense>(categoryEventUpdateExpense);

    on<CategoryEventFetch>(categoryEventFetch);

    on<CategoryEventInsert>(categoryEventInsert);

    on<CategoryEventDelete>(categoryEventDelete);
    on<CategoryEventUpdate>(categoryEventUpdate);
  }

  FutureOr<void> categoryEventInsert(event, emit) async {
    ct.Category category = event.category;
    await categoryService.createNewCategory(category);
    add(CategoryEventFetch(
      recordType: category.recordType,
      isDeleteOperation: false,
      isDeleted: false,
      isUpdateOperation: false,
      isUpdated: false,
    ));
  }

  FutureOr<void> categoryEventFetch(
    CategoryEventFetch event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryStateLoading(
      isDeleteOperation: event.isDeleteOperation,
      isDeleted: event.isDeleted,
      isUpdateOperation: event.isUpdateOperation,
      isUpdated: event.isUpdated,
    ));
    try {
      Map<String, List<ct.Category>> categoriesMap =
          await categoryService.getCategoryList(recordType: event.recordType);
      emit(CategoryStateFetched(
        categoriesMap: categoriesMap,
        isDeleteOperation: event.isDeleteOperation,
        isDeleted: event.isDeleted,
        isUpdateOperation: event.isUpdateOperation,
        isUpdated: event.isUpdated,
      ));
    } on CouldNotFindCategory {
      emit(CategoryStateEmptyFetch(
        isDeleteOperation: event.isDeleteOperation,
        isDeleted: event.isDeleted,
        isUpdateOperation: event.isUpdateOperation,
        isUpdated: event.isUpdated,
      ));
    }
  }

  FutureOr<void> categoryEventUpdateExpense(event, emit) {
    emit(CategoryStateUpdateExpense(category: event.category));
  }

  FutureOr<void> categoryEventUpdateIncome(event, emit) {
    emit(CategoryStateUpdateIncome(category: event.category));
  }

  FutureOr<void> categoryEventDelete(
    CategoryEventDelete event,
    Emitter<CategoryState> emit,
  ) async {
    ct.Category category = event.category;
    try {
      await categoryService.deleteCategory(category: category);
      add(CategoryEventFetch(
        recordType: category.recordType,
        isDeleteOperation: true,
        isDeleted: true,
        isUpdateOperation: false,
        isUpdated: false,
      ));
    } catch (_) {
      add(CategoryEventFetch(
        recordType: category.recordType,
        isDeleteOperation: true,
        isDeleted: false,
        isUpdateOperation: false,
        isUpdated: false,
      ));
    }
  }

  FutureOr<void> categoryEventUpdate(
    CategoryEventUpdate event,
    Emitter<CategoryState> emit,
  ) async {
    ct.Category category = event.category;
    try {
      await categoryService.updateCategory(category);
      add(CategoryEventFetch(
        recordType: category.recordType,
        isDeleteOperation: false,
        isDeleted: false,
        isUpdateOperation: true,
        isUpdated: false,
      ));
    } catch (_) {
      add(CategoryEventFetch(
        recordType: category.recordType,
        isDeleteOperation: false,
        isDeleted: false,
        isUpdateOperation: true,
        isUpdated: true,
      ));
    }
  }
}
