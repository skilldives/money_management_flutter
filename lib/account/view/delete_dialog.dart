import 'package:flutter/material.dart';
import 'package:money_management/util/dialogs/generic_dialog.dart';

Future<bool> showAccountDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete this account?',
    content:
        'Deleting this account will also delete all records with this account. Are you sure?',
    optionBuilder: () => {
      'NO': false,
      'YES': true,
    },
  ).then((value) => value ?? false);
}
