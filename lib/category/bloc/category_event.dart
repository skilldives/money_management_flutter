part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent {
  const CategoryEvent();
}

class CategoryEventUpdateIncome extends CategoryEvent {
  final ct.Category category;

  const CategoryEventUpdateIncome({required this.category});
}

class CategoryEventUpdateExpense extends CategoryEvent {
  final ct.Category category;

  const CategoryEventUpdateExpense({required this.category});
}

class CategoryEventFetch extends CategoryEvent {
  final RecordType recordType;
  final bool isDeleteOperation;
  final bool isDeleted;
  final bool isUpdateOperation;
  final bool isUpdated;
  const CategoryEventFetch({
    required this.isDeleteOperation,
    required this.isDeleted,
    required this.isUpdateOperation,
    required this.isUpdated,
    required this.recordType,
  });
}

class CategoryEventInsert extends CategoryEvent {
  final ct.Category category;

  const CategoryEventInsert({required this.category});
}

class CategoryEventDelete extends CategoryEvent {
  final ct.Category category;

  const CategoryEventDelete({required this.category});
}

class CategoryEventUpdate extends CategoryEvent {
  final ct.Category category;

  const CategoryEventUpdate({required this.category});
}
