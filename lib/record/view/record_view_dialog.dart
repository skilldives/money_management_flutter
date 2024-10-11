import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:money_management/category/bloc/category_bloc.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/record/bloc/record_bloc.dart';
import 'package:money_management/record/model/edit_record.dart';
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/record/view/delete_dialog.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:money_management/util/constants/routes.dart';

class RecordViewDialog extends StatefulWidget {
  final String transAmount;
  final rc.Record record;
  final Account fromAccount;
  final Account? toAccount;
  final Category? category;
  final ViewMode viewMode;
  const RecordViewDialog({
    required this.transAmount,
    required this.record,
    required this.fromAccount,
    super.key,
    required this.toAccount,
    required this.category,
    required this.viewMode,
  });

  @override
  State<RecordViewDialog> createState() => _RecordViewDialogState();
}

class _RecordViewDialogState extends State<RecordViewDialog> {
  late String amount;
  late rc.Record record;
  late Account fromAccount;
  late Account? toAccount;
  late Category? category;
  late ViewMode viewMode;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    amount = widget.transAmount;
    record = widget.record;
    fromAccount = widget.fromAccount;
    toAccount = widget.toAccount;
    category = widget.category;
    viewMode = widget.viewMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(kRadialReactionRadius),
            topRight: Radius.circular(kRadialReactionRadius),
          ),
          color: CommonUtil.getColorByRecordType(
            record.recordType,
            colorScheme,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: colorScheme.background,
                      size: textTheme.headlineMedium?.fontSize,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final shouldDelete = await showDeleteDialog(context);
                          if (shouldDelete) {
                            // ignore: use_build_context_synchronously
                            context.read<RecordBloc>().add(RecordEventDelete(
                                  record: record,
                                  viewMode: viewMode,
                                ));
                            // ignore: use_build_context_synchronously
                            context
                                .read<BackupBloc>()
                                .add(const BackupEventNeedCloudBackup());
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          }
                        },
                        icon: Icon(
                          Icons.delete_outlined,
                          color: colorScheme.background,
                          size: textTheme.headlineMedium?.fontSize,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Navigator.of(context).pushNamed(
                            createRecordRoute,
                            // ignore: use_build_context_synchronously
                            arguments: EditRecord(
                              context: context,
                              recordData: RecordData(
                                record: record,
                                fromAccount: fromAccount,
                                toAccount: toAccount,
                                category: category,
                              ),
                              viewMode: viewMode,
                            ),
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          color: colorScheme.background,
                          size: textTheme.headlineMedium?.fontSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                record.recordType.name.toUpperCase(),
                style: TextStyle(
                  color: colorScheme.background,
                  fontSize: textTheme.titleMedium?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                amount,
                style: TextStyle(
                  color: colorScheme.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: Text(
                  CommonUtil.getRecordDialogDateTime(record.dateTime),
                  style: TextStyle(
                    color: colorScheme.background,
                    fontSize: textTheme.titleSmall?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.recordType == RecordType.transfer ? 'From' : 'Account',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: textTheme.titleMedium?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Icon(
                      IconData(
                        fromAccount.iconDataCodePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                    ),
                    Text(
                      fromAccount.name,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.recordType == RecordType.transfer ? 'To' : 'Category',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: textTheme.titleMedium?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Icon(
                      IconData(
                        record.recordType == RecordType.transfer
                            ? toAccount!.iconDataCodePoint
                            : category!.iconDataCodePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        record.recordType == RecordType.transfer
                            ? toAccount!.name
                            : category!.name,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(record.note),
        ],
      ),
    );
  }
}

void showRecordViewDialog(
  BuildContext context, {
  required String transAmount,
  required rc.Record record,
  required Account fromAccount,
  required Account? toAccount,
  required Category? category,
  required ViewMode viewMode,
}) {
  showDialog(
    context: context,
    builder: (context2) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: BlocProvider.of<RecordBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<BackupBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<AccountBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<CategoryBloc>(context),
          ),
        ],
        child: RecordViewDialog(
          transAmount: transAmount,
          record: record,
          fromAccount: fromAccount,
          toAccount: toAccount,
          category: category,
          viewMode: viewMode,
        ),
      );
    },
  );
}
