part of 'category_bloc.dart';

@immutable
abstract class CategoryState {
  final bool isDeleteOperation;
  final bool isDeleted;
  final bool isUpdateOperation;
  final bool isUpdated;
  const CategoryState({
    required this.isDeleteOperation,
    required this.isDeleted,
    required this.isUpdateOperation,
    required this.isUpdated,
  });
}

class CategoryInitial extends CategoryState {
  const CategoryInitial(
      {required super.isDeleteOperation,
      required super.isDeleted,
      required super.isUpdateOperation,
      required super.isUpdated});
}

class CategoryStateUpdateIncome extends CategoryState {
  final ct.Category category;

  const CategoryStateUpdateIncome({required this.category})
      : super(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        );
}

class CategoryStateUpdateExpense extends CategoryState {
  final ct.Category category;

  const CategoryStateUpdateExpense({required this.category})
      : super(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        );
}

class CategoryStateLoading extends CategoryState {
  const CategoryStateLoading({
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
  });
}

class CategoryStateEmptyFetch extends CategoryState {
  const CategoryStateEmptyFetch({
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
  });
}

class CategoryStateFetched extends CategoryState {
  final Map<String, List<ct.Category>> categoriesMap;

  const CategoryStateFetched({
    required this.categoriesMap,
    required super.isDeleteOperation,
    required super.isDeleted,
    required super.isUpdateOperation,
    required super.isUpdated,
  });
}
