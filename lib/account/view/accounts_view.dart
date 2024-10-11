import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/account/view/account_list_view.dart';
import 'package:money_management/account/view/add_account_dialog.dart';
import 'package:money_management/account/view/overall_view.dart';

class AccountsView extends StatefulWidget {
  const AccountsView({super.key});

  @override
  State<AccountsView> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(const AccountEventFetch(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Overall',
              style: TextStyle(
                fontSize: textTheme.titleMedium?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const OverallView(),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Accounts',
              style: TextStyle(
                fontSize: textTheme.titleMedium?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const AccountListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await HapticFeedback.mediumImpact();
          // ignore: use_build_context_synchronously
          showAddAccountDialog(
            context: context,
            passedAccount: null,
          );
        },
        shape: const CircleBorder(),
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
