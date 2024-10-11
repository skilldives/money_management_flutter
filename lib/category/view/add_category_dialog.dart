import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:money_management/category/bloc/category_bloc.dart';
import 'package:money_management/category/service/category_icon_list.dart';
import 'package:money_management/category/service/category_service.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:uuid/uuid.dart';

import '../model/category.dart';

class AddCategoryDialog extends StatefulWidget {
  final Category? passedCategory;
  const AddCategoryDialog({
    required this.passedCategory,
    super.key,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  RecordType recordType = RecordType.expense;
  late final CategoryService _categoryService;
  late final TextEditingController _name;
  late IconData selectedIcon;
  bool isSubCategorySelected = false;
  List<Category> categoryList = [];
  Category? selectedCategory;
  late Category? passedCategory;

  @override
  void initState() {
    _categoryService = CategoryService();
    _name = TextEditingController();
    selectedIcon = allIcons[0].iconData;
    passedCategory = widget.passedCategory;
    if (passedCategory != null) {
      setData(passedCategory!);
    }
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    passedCategory = null;
    isSubCategorySelected = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Center(child: Text('Add new category')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: passedCategory == null,
              child: SegmentedButton<RecordType>(
                segments: const <ButtonSegment<RecordType>>[
                  ButtonSegment<RecordType>(
                    value: RecordType.income,
                    label: Text('INCOME'),
                  ),
                  ButtonSegment<RecordType>(
                    value: RecordType.expense,
                    label: Text('EXPENSE'),
                  ),
                ],
                selected: <RecordType>{recordType},
                onSelectionChanged: (Set<RecordType> newSelection) {
                  setState(() {
                    recordType = newSelection.first;
                    isSubCategorySelected = false;
                    selectedCategory = null;
                  });
                },
              ),
            ),
            Visibility(
              visible: passedCategory == null,
              child: Row(
                children: [
                  Checkbox(
                    value: isSubCategorySelected,
                    onChanged: (bool? value) async {
                      var categories = await _categoryService
                          .getCategoriesListByRecordAndCategoryType(
                        recordType: recordType,
                        isSubCategorySelected: !value!,
                      );
                      setState(() {
                        if (categories.isEmpty) {
                          isSubCategorySelected = false;
                        } else {
                          isSubCategorySelected = value;
                        }
                        categoryList = categories;
                      });
                    },
                  ),
                  const Text('Is Sub Category?'),
                ],
              ),
            ),
            Visibility(
              visible: isSubCategorySelected && passedCategory == null,
              child: DropdownButton<Category>(
                value: selectedCategory,
                hint: const Text('Select Category'),
                onChanged: (Category? category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                items: categoryList.map<DropdownMenuItem<Category>>((e) {
                  return DropdownMenuItem<Category>(
                    value: e,
                    child: Text(e.name),
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                const Expanded(child: Text('Name')),
                Expanded(
                  child: TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      hintText: 'Untitled',
                    ),
                  ),
                ),
              ],
            ),
            const Text('Icon'),
            Container(
              color: colorScheme.tertiaryContainer,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allIcons.map((iconData) {
                    return IconButton.outlined(
                      isSelected: iconData.isSelected,
                      onPressed: () {
                        selectedIcon = iconData.iconData;
                        setState(() {
                          for (var element in allIcons) {
                            if (element.iconData == iconData.iconData) {
                              element.isSelected = true;
                            } else {
                              element.isSelected = false;
                            }
                          }
                        });
                      },
                      icon: Icon(iconData.iconData),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            OutlinedButton(
              onPressed: () {
                if (isSubCategorySelected && selectedCategory == null) {
                  selectedCategory = categoryList.first;
                }
                if (_name.text.isEmpty) {
                  _name.text = 'Untitled';
                }
                if (passedCategory == null) {
                  context.read<CategoryBloc>().add(
                        CategoryEventInsert(
                          category: Category(
                            id: const Uuid().v4(),
                            recordType: recordType,
                            name: _name.text,
                            iconDataCodePoint: selectedIcon.codePoint,
                            isIgnored: false,
                            isSubCategory: isSubCategorySelected,
                            categoryGroup: isSubCategorySelected
                                ? selectedCategory!.id
                                : null,
                          ),
                        ),
                      );
                } else {
                  context.read<CategoryBloc>().add(
                        CategoryEventUpdate(
                          category: Category(
                            id: passedCategory!.id,
                            recordType: passedCategory!.recordType,
                            name: _name.text,
                            iconDataCodePoint: selectedIcon.codePoint,
                            isIgnored: passedCategory!.isIgnored,
                            isSubCategory: passedCategory!.isSubCategory,
                            categoryGroup: passedCategory!.categoryGroup,
                          ),
                        ),
                      );
                }
                context
                    .read<BackupBloc>()
                    .add(const BackupEventNeedCloudBackup());
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ],
    );
  }

  void setData(Category passedCategory) {
    _name.text = passedCategory.name;

    for (var element in allIcons) {
      if (element.iconData.codePoint == passedCategory.iconDataCodePoint) {
        selectedIcon = element.iconData;
        element.isSelected = true;
      } else {
        element.isSelected = false;
      }
    }
  }
}

void showAddCategoryDialog({
  required BuildContext context,
  required Category? passedCategory,
}) {
  showDialog(
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
        child: AddCategoryDialog(
          passedCategory: passedCategory,
        ),
      );
    },
  );
}
