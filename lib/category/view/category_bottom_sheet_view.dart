import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:money_management/category/bloc/category_bloc.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:money_management/category/view/add_category_dialog.dart';

class CategoryBottomSheet extends StatefulWidget {
  final RecordType recordType;

  const CategoryBottomSheet({required this.recordType, super.key});

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  late Map<String, List<Category>> categoriesMap;
  late RecordType recordType;

  @override
  void initState() {
    recordType = widget.recordType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<CategoryBloc>().add(CategoryEventFetch(
          recordType: recordType,
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        ));
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryStateFetched) {
          Map<String, List<Category>> categoriesMap = state.categoriesMap;
          return ListView.builder(
            itemCount: categoriesMap.keys.length + 1,
            itemBuilder: (context, index) {
              if (index == categoriesMap.keys.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showAddCategoryDialog(
                        context: context,
                        passedCategory: null,
                      );
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('ADD NEW CATEGORY'),
                  ),
                );
              } else {
                final categories = categoriesMap.values.elementAt(index);
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        if (recordType == RecordType.income) {
                          context.read<CategoryBloc>().add(
                              CategoryEventUpdateIncome(
                                  category: categories.first));
                        }
                        if (recordType == RecordType.expense) {
                          context.read<CategoryBloc>().add(
                              CategoryEventUpdateExpense(
                                  category: categories.first));
                        }

                        Navigator.of(context).pop();
                      },
                      title: Text(
                        categories.first.name,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Icon(IconData(
                        categories.first.iconDataCodePoint,
                        fontFamily: 'MaterialIcons',
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ListView.builder(
                        itemCount: categories.length - 1,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              if (recordType == RecordType.income) {
                                context.read<CategoryBloc>().add(
                                    CategoryEventUpdateIncome(
                                        category: categories[index + 1]));
                              }
                              if (recordType == RecordType.expense) {
                                context.read<CategoryBloc>().add(
                                    CategoryEventUpdateExpense(
                                        category: categories[index + 1]));
                              }

                              Navigator.of(context).pop();
                            },
                            title: Text(
                              categories[index + 1].name,
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: Icon(IconData(
                              categories[index + 1].iconDataCodePoint,
                              fontFamily: 'MaterialIcons',
                            )),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 0),
                  ],
                );
              }
            },
          );
        } else if (state is CategoryStateEmptyFetch) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Center(
                child: Text('No categories, Tap + to add new categories'),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showAddCategoryDialog(
                      context: context,
                      passedCategory: null,
                    );
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('ADD NEW CATEGORY'),
                ),
              )
            ],
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
      },
    );
  }
}

void showCategoryBottomSheet(BuildContext context, RecordType recordType) {
  showModalBottomSheet(
    context: context,
    builder: (context2) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: BlocProvider.of<CategoryBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<BackupBloc>(context),
          ),
        ],
        child: CategoryBottomSheet(
          recordType: recordType,
        ),
      );
    },
  );
}
