import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/account/view/account_list_tile.dart';

class AccountListView extends StatelessWidget {
  const AccountListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountStateFetched) {
          List<Account> accounts = state.accounts;

          return Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: accounts.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                    color: colorScheme.secondaryContainer,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: AccountListTile(
                    account: account,
                    amount: state.amountMap[account.id]!,
                  ),
                );
              },
            ),
          );
        } else if (state is AccountStateEmptyFetch) {
          return const Center(
            child: Text('No accounts, Tap + to add new account'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
      },
    );
  }
}
