import 'package:flutter/widgets.dart';
import 'package:money_management/util/dialogs/generic_dialog.dart';

Future<bool> showNotNowDialog({
  required BuildContext context,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Important Data Loss Alert!',
    content:
        'Are you sure? By proceeding, you will lose all data stored in your cloud drive',
    optionBuilder: () => {
      'No': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}
