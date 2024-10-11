import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/account/view/add_account_dialog.dart';
import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:money_management/util/common_util.dart';

class AccountBottomSheet extends StatefulWidget {
  final String accountType;

  const AccountBottomSheet({required this.accountType, super.key});

  @override
  State<AccountBottomSheet> createState() => _AccountBottomSheetState();
}

class _AccountBottomSheetState extends State<AccountBottomSheet> {
  late List<Account> accounts;
  late String accountType;

  @override
  void initState() {
    accountType = widget.accountType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<AccountBloc>().add(const AccountEventFetch(
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        ));
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountStateFetched) {
          List<Account> accounts = state.accounts;
          return ListView.builder(
            itemCount: accounts.length + 1,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index == accounts.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showAddAccountDialog(
                        context: context,
                        passedAccount: null,
                      );
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('ADD NEW ACCOUNT'),
                  ),
                );
              } else {
                final account = accounts[index];
                String amount = state.amountMap[account.id]!;
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        if (accountType == 'from') {
                          context.read<AccountBloc>().add(
                              AccountEventUpdateFromAccount(account: account));
                        } else {
                          context.read<AccountBloc>().add(
                              AccountEventUpdateToAccount(account: account));
                        }
                        Navigator.of(context).pop();
                      },
                      title: Text(
                        account.name,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        amount,
                        style: TextStyle(
                          fontSize: textTheme.titleSmall?.fontSize,
                          color: CommonUtil.getColorByAmount(
                            account.initialAmount,
                            colorScheme,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: Icon(IconData(
                        account.iconDataCodePoint,
                        fontFamily: 'MaterialIcons',
                      )),
                    ),
                    const Divider(height: 0),
                  ],
                );
              }
            },
          );
        } else if (state is AccountStateEmptyFetch) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Center(
                child: Text('No accounts, Tap + to add new account'),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showAddAccountDialog(
                      context: context,
                      passedAccount: null,
                    );
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('ADD NEW ACCOUNT'),
                ),
              ),
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

void showAccountBottomSheet(BuildContext context, String accountType) {
  showModalBottomSheet(
    context: context,
    builder: (context2) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: BlocProvider.of<AccountBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<BackupBloc>(context),
          ),
        ],
        child: AccountBottomSheet(
          accountType: accountType,
        ),
      );
    },
  );
}
