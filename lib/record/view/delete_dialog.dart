import 'package:flutter/widgets.dart';
import 'package:money_management/util/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete this record?',
    content: 'Are you sure?',
    optionBuilder: () => {
      'NO': false,
      'YES': true,
    },
  ).then((value) => value ?? false);
}
