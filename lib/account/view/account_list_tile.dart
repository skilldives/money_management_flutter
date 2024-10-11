import 'package:flutter/material.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/account/view/account_popup_menu.dart';
import 'package:money_management/util/common_util.dart';

class AccountListTile extends StatelessWidget {
  const AccountListTile({
    super.key,
    required this.account,
    required this.amount,
  });

  final String amount;
  final Account account;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: () {},
      title: AccountListTileTitle(
        account: account,
        amount: amount,
      ),
      trailing: AccountPopupMenu(
        account: account,
      ),
      leading: Icon(
        IconData(
          account.iconDataCodePoint,
          fontFamily: 'MaterialIcons',
        ),
        size: textTheme.headlineLarge?.fontSize,
      ),
    );
  }
}

class AccountListTileTitle extends StatelessWidget {
  const AccountListTileTitle({
    super.key,
    required this.account,
    required this.amount,
  });

  final Account account;

  final String amount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          account.name,
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Text(
              'Balance:  ',
              style: TextStyle(
                fontSize: textTheme.titleMedium?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: textTheme.titleMedium?.fontSize,
                color: CommonUtil.getColorByAmount(
                  account.initialAmount,
                  colorScheme,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
