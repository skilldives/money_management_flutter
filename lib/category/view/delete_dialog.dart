import 'package:flutter/material.dart';
import 'package:money_management/util/dialogs/generic_dialog.dart';

Future<bool> showCategoryDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete this category?',
    content:
        'Deleting this category will also delete all records and budgets for this category. Are you sure?',
    optionBuilder: () => {
      'NO': false,
      'YES': true,
    },
  ).then((value) => value ?? false);
}
