import 'package:flutter/widgets.dart';
import 'package:money_management/util/dialogs/generic_dialog.dart';

Future<bool> showAuthDialog({
  required BuildContext context,
  required bool isLogin,
}) {
  String btn = isLogin ? 'Login' : 'Log out';
  return showGenericDialog<bool>(
    context: context,
    title: isLogin ? 'Login' : 'Log out',
    content: isLogin
        ? 'Are you sure you want to log in?'
        : 'Are you sure you want to log out?',
    optionBuilder: () => {
      'Cancel': false,
      btn: true,
    },
  ).then((value) => value ?? false);
}
