import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/record/bloc/record_bloc.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

class RecordBottomView extends StatelessWidget {
  const RecordBottomView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Text(
              'EXPENSE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            BlocBuilder<RecordBloc, RecordState>(
              builder: (context, state) {
                Color totalExpenseColor = CommonUtil.getColorByRecordType(
                  RecordType.expense,
                  colorScheme,
                );
                if (state is RecordStateFetched) {
                  return Text(
                    state.totalExpense,
                    style: TextStyle(
                      fontSize: textTheme.titleMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: totalExpenseColor,
                    ),
                  );
                } else {
                  return Text(
                    '0',
                    style: TextStyle(
                      fontSize: textTheme.titleMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: totalExpenseColor,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'INCOME',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            BlocBuilder<RecordBloc, RecordState>(builder: (context, state) {
              Color totalIncomeColor = CommonUtil.getColorByRecordType(
                RecordType.income,
                colorScheme,
              );
              if (state is RecordStateFetched) {
                return Text(
                  state.totalIncome,
                  style: TextStyle(
                    fontSize: textTheme.titleMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                    color: totalIncomeColor,
                  ),
                );
              } else {
                return Text(
                  '0',
                  style: TextStyle(
                    fontSize: textTheme.titleMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                    color: totalIncomeColor,
                  ),
                );
              }
            }),
          ],
        ),
        Column(
          children: [
            const Text(
              'TOTAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            BlocBuilder<RecordBloc, RecordState>(
              builder: (context, state) {
                Color totalBalanceColor = colorScheme.primary;
                if (state is RecordStateFetched) {
                  totalBalanceColor = CommonUtil.getColorByRecordType(
                    state.totalBalance.contains('-')
                        ? RecordType.expense
                        : RecordType.income,
                    colorScheme,
                  );
                  return Text(
                    state.totalBalance,
                    style: TextStyle(
                      fontSize: textTheme.titleMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: totalBalanceColor,
                    ),
                  );
                } else {
                  return Text(
                    '0',
                    style: TextStyle(
                      fontSize: textTheme.titleMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: totalBalanceColor,
                    ),
                  );
                }
              },
            ),
          ],
        )
      ],
    );
  }
}
