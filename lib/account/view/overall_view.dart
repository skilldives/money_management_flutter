import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

class OverallView extends StatelessWidget {
  const OverallView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        color: colorScheme.secondaryContainer,
      ),
      padding: const EdgeInsets.all(5),
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountStateFetched) {
            Color totalIncomeColor = CommonUtil.getColorByRecordType(
              RecordType.income,
              colorScheme,
            );
            Color totalExpenseColor = CommonUtil.getColorByRecordType(
              RecordType.expense,
              colorScheme,
            );
            Color totalBalanceColor = CommonUtil.getColorByRecordType(
              state.totalBalance.contains('-')
                  ? RecordType.expense
                  : RecordType.income,
              colorScheme,
            );
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'EXPENSE SO FAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.totalExpense,
                          style: TextStyle(
                            fontSize: textTheme.titleMedium?.fontSize,
                            fontWeight: FontWeight.bold,
                            color: totalExpenseColor,
                          ),
                        ),
                      ],
                    ),
                    const VerticalDivider(),
                    Column(
                      children: [
                        const Text(
                          'INCOME SO FAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.totalIncome,
                          style: TextStyle(
                              fontSize: textTheme.titleMedium?.fontSize,
                              fontWeight: FontWeight.bold,
                              color: totalIncomeColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(
                  indent: 34,
                  endIndent: 34,
                ),
                const Text(
                  'TOTAL BALANCE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.totalBalance,
                  style: TextStyle(
                    fontSize: textTheme.titleMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                    color: totalBalanceColor,
                  ),
                ),
              ],
            );
          } else if (state is AccountStateEmptyFetch) {
            return Container();
          } else {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
        },
      ),
    );
  }
}
