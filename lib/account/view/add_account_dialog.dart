import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/account/service/account_icon_list.dart';
import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:uuid/uuid.dart';

class AddAccountDialog extends StatefulWidget {
  final Account? passedAccount;
  const AddAccountDialog({
    required this.passedAccount,
    super.key,
  });

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  late final TextEditingController _name;
  late final TextEditingController _initialAmount;
  late IconData selectedIcon;
  late Account? passedAccount;

  @override
  void initState() {
    _name = TextEditingController();
    _initialAmount = TextEditingController();
    selectedIcon = allIcons[0].iconData;
    passedAccount = widget.passedAccount;
    if (passedAccount != null) {
      setData(passedAccount!);
    }
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _initialAmount.dispose();
    passedAccount = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Center(child: Text('Add new account')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Initial amount')),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _initialAmount,
                    decoration: const InputDecoration(
                      hintText: '0',
                    ),
                  ),
                ),
              ],
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
                try {
                  num.parse(_initialAmount.text);
                } catch (e) {
                  _initialAmount.text = '0.0';
                }
                if (_initialAmount.text.isEmpty) {
                  _initialAmount.text = '0.0';
                }
                if (_name.text.isEmpty) {
                  _name.text = 'Untitled';
                }
                String id = (passedAccount != null)
                    ? passedAccount!.id
                    : const Uuid().v4();

                Account account = Account(
                  id: id,
                  initialAmount: num.parse(_initialAmount.text),
                  name: _name.text,
                  iconDataCodePoint: selectedIcon.codePoint,
                  isIgnored: false,
                );
                if (passedAccount == null) {
                  // Create new accounnt
                  context.read<AccountBloc>().add(
                        AccountEventInsert(account: account),
                      );
                } else {
                  // Update existing account
                  context
                      .read<AccountBloc>()
                      .add(AccountEventUpdate(account: account));
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

  void setData(Account passedAccount) {
    _initialAmount.text = passedAccount.initialAmount.toString();
    _name.text = passedAccount.name;
    for (var element in allIcons) {
      if (element.iconData.codePoint == passedAccount.iconDataCodePoint) {
        element.isSelected = true;
        selectedIcon = element.iconData;
      } else {
        element.isSelected = false;
      }
    }
  }
}

void showAddAccountDialog({
  required BuildContext context,
  required Account? passedAccount,
}) {
  showDialog(
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
        child: AddAccountDialog(
          passedAccount: passedAccount,
        ),
      );
    },
  );
}
