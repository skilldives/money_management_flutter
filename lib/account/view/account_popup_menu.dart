import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/account/view/add_account_dialog.dart';
import 'package:money_management/account/view/delete_dialog.dart';
import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

class AccountPopupMenu extends StatelessWidget {
  final Account account;
  const AccountPopupMenu({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return PopupMenuButton<MenuAction>(
      icon: const Icon(Icons.more_horiz),
      onSelected: (value) async {
        switch (value) {
          case MenuAction.edit:
            showAddAccountDialog(
              context: context,
              passedAccount: account,
            );
            break;
          case MenuAction.delete:
            final shouldDelete = await showAccountDeleteDialog(context);
            if (shouldDelete) {
              // ignore: use_build_context_synchronously
              context
                  .read<AccountBloc>()
                  .add(AccountEventDelete(account: account));
              // ignore: use_build_context_synchronously
              context
                  .read<BackupBloc>()
                  .add(const BackupEventNeedCloudBackup());
            }
            break;
          case MenuAction.ignore:
            CommonUtil.showSnackBarMessage(
              'Coming soon...!',
              context,
            );
            break;
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: MenuAction.edit,
            child: Text(
              'Edit',
              style: TextStyle(
                fontSize: textTheme.titleMedium?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PopupMenuItem(
            value: MenuAction.delete,
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: textTheme.titleMedium?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PopupMenuItem(
            enabled: false,
            value: MenuAction.ignore,
            child: Text(
              'Ignore',
              style: TextStyle(
                fontSize: textTheme.titleMedium?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      },
    );
  }
}
