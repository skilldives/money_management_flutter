import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:money_management/category/bloc/category_bloc.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/record/model/edit_record.dart';
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/record/bloc/record_bloc.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:money_management/util/generics/get_arguments.dart';
import 'package:money_management/account/view/account_bottom_sheet_view.dart';
import 'package:money_management/category/view/category_bottom_sheet_view.dart';
import 'package:uuid/uuid.dart';

import '../../account/model/account.dart';

class CreateRecordView extends StatefulWidget {
  const CreateRecordView({super.key});

  @override
  State<CreateRecordView> createState() => _CreateRecordViewState();
}

class _CreateRecordViewState extends State<CreateRecordView> {
  RecordType recordType = RecordType.expense;
  DateTime _dateTime = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  Account toAccount = Account(
    id: const Uuid().v4(),
    iconDataCodePoint: Icons.account_balance_wallet.codePoint,
    initialAmount: 0,
    isIgnored: false,
    name: 'Account',
  );
  bool isToAccountSelected = false;
  Account fromAccount = Account(
    id: const Uuid().v4(),
    iconDataCodePoint: Icons.account_balance_wallet.codePoint,
    initialAmount: 0,
    isIgnored: false,
    name: 'Account',
  );
  bool isFromAccountSelected = false;
  Category incomeCategory = Category(
    id: const Uuid().v4(),
    iconDataCodePoint: Icons.category.codePoint,
    recordType: RecordType.expense,
    isIgnored: false,
    name: 'Category',
    isSubCategory: false,
  );
  bool isIncomeCategorySelected = false;
  Category expenseCategory = Category(
    id: const Uuid().v4(),
    iconDataCodePoint: Icons.category.codePoint,
    recordType: RecordType.expense,
    isIgnored: false,
    name: 'Category',
    isSubCategory: false,
  );
  bool isExpenseCategorySelected = false;
  bool isEditDataAlreadySet = false;

  late final TextEditingController _noteController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    _noteController = TextEditingController();
    _amountController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    isEditDataAlreadySet = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BuildContext recordViewContext =
        context.getArgument<EditRecord>()!.context;
    final ViewMode viewMode = context.getArgument<EditRecord>()!.viewMode;
    if ((context.getArgument<EditRecord>()!.recordData) != null &&
        !isEditDataAlreadySet) {
      setData(context.getArgument<EditRecord>()!.recordData!);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: kToolbarHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: colorScheme.onErrorContainer,
                    ),
                    label: Text(
                      'Cancel',
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      num amount;
                      try {
                        amount = num.parse(_amountController.text);
                        if (!isFromAccountSelected) {
                          CommonUtil.showSnackBarMessage(
                            'Select Account!',
                            context,
                          );
                        } else if (amount <= 0) {
                          CommonUtil.showSnackBarMessage(
                            'Enter Amount!',
                            context,
                          );
                        } else if (recordType == RecordType.transfer &&
                            !isToAccountSelected) {
                          CommonUtil.showSnackBarMessage(
                            'Select Destination Account!',
                            context,
                          );
                        } else if (recordType == RecordType.transfer &&
                            fromAccount.id == toAccount.id) {
                          CommonUtil.showSnackBarMessage(
                            'Transfer Accounts are same, choose different accounts!',
                            context,
                          );
                        } else if (recordType == RecordType.income &&
                            !isIncomeCategorySelected) {
                          CommonUtil.showSnackBarMessage(
                            'Select Income Category!',
                            context,
                          );
                        } else if (recordType == RecordType.expense &&
                            !isExpenseCategorySelected) {
                          CommonUtil.showSnackBarMessage(
                            'Select Expense Category!',
                            context,
                          );
                        } else {
                          if (_noteController.text.isEmpty) {
                            _noteController.text = '';
                          }
                          Category? category;
                          if (isIncomeCategorySelected) {
                            category = incomeCategory;
                          } else if (isExpenseCategorySelected) {
                            category = expenseCategory;
                          } else {
                            category = null;
                          }
                          String id =
                              (context.getArgument<EditRecord>()!.recordData) ==
                                      null
                                  ? const Uuid().v4()
                                  : context
                                      .getArgument<EditRecord>()!
                                      .recordData!
                                      .record
                                      .id;

                          rc.Record newRecord = rc.Record(
                            id: id,
                            recordType: recordType,
                            note: _noteController.text,
                            amount: amount,
                            dateTime: DateTime(
                              _dateTime.year,
                              _dateTime.month,
                              _dateTime.day,
                              _time.hour,
                              _time.minute,
                            ),
                            fromAccount: fromAccount.id,
                            toAccount:
                                isToAccountSelected ? toAccount.id : null,
                            category: category?.id,
                          );
                          if ((context.getArgument<EditRecord>()!.recordData) !=
                              null) {
                            rc.Record oldRecord = context
                                .getArgument<EditRecord>()!
                                .recordData!
                                .record;

                            recordViewContext.read<RecordBloc>().add(
                                  RecordEventUpdate(
                                    newRecord: newRecord,
                                    oldRecord: oldRecord,
                                    viewMode: viewMode,
                                  ),
                                );
                          } else {
                            recordViewContext.read<RecordBloc>().add(
                                  RecordEventInsert(
                                    record: newRecord,
                                    viewMode: viewMode,
                                  ),
                                );
                          }
                          recordViewContext
                              .read<BackupBloc>()
                              .add(const BackupEventNeedCloudBackup());

                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        CommonUtil.showSnackBarMessage(
                          'Enter Valid Amount!',
                          context,
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save  '),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SegmentedButton<RecordType>(
                segments: const <ButtonSegment<RecordType>>[
                  ButtonSegment<RecordType>(
                    value: RecordType.income,
                    label: Text('INCOME'),
                  ),
                  ButtonSegment<RecordType>(
                    value: RecordType.expense,
                    label: Text('EXPENSE'),
                  ),
                  ButtonSegment<RecordType>(
                    value: RecordType.transfer,
                    label: Text('TRANSFER'),
                  ),
                ],
                selected: <RecordType>{recordType},
                onSelectionChanged: (Set<RecordType> newSelection) {
                  setState(() {
                    recordType = newSelection.first;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Visibility(
                    visible: recordType == RecordType.income ||
                        recordType == RecordType.expense,
                    child: const Text(
                      'Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: recordType == RecordType.income ||
                        recordType == RecordType.expense,
                    child: const Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Visibility(
                    visible: recordType == RecordType.transfer,
                    child: const Text(
                      'From',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: recordType == RecordType.transfer,
                    child: const Text(
                      'To',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: BlocProvider.of<AccountBloc>(recordViewContext),
                      ),
                      BlocProvider.value(
                        value: BlocProvider.of<BackupBloc>(recordViewContext),
                      ),
                    ],
                    child: BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, state) {
                        if (state is AccountStateUpdateFromAccount) {
                          fromAccount = state.account;
                          isFromAccountSelected = true;
                        }
                        return Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showAccountBottomSheet(context, 'from');
                            },
                            icon: Icon(IconData(fromAccount.iconDataCodePoint,
                                fontFamily: 'MaterialIcons')),
                            label: Text(fromAccount.name),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Visibility(
                    visible: recordType == RecordType.income,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value:
                              BlocProvider.of<CategoryBloc>(recordViewContext),
                        ),
                        BlocProvider.value(
                          value: BlocProvider.of<BackupBloc>(recordViewContext),
                        ),
                      ],
                      child: BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryStateUpdateIncome) {
                            incomeCategory = state.category;
                            isIncomeCategorySelected = true;
                          }
                          return Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showCategoryBottomSheet(context, recordType);
                              },
                              icon: Icon(IconData(
                                  incomeCategory.iconDataCodePoint,
                                  fontFamily: 'MaterialIcons')),
                              label: Text(incomeCategory.name),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: recordType == RecordType.expense,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value:
                              BlocProvider.of<CategoryBloc>(recordViewContext),
                        ),
                        BlocProvider.value(
                          value: BlocProvider.of<BackupBloc>(recordViewContext),
                        ),
                      ],
                      child: BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryStateUpdateExpense) {
                            expenseCategory = state.category;
                            isExpenseCategorySelected = true;
                          }
                          return Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showCategoryBottomSheet(context, recordType);
                              },
                              icon: Icon(IconData(
                                  expenseCategory.iconDataCodePoint,
                                  fontFamily: 'MaterialIcons')),
                              label: Text(expenseCategory.name),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: recordType == RecordType.transfer,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value:
                              BlocProvider.of<AccountBloc>(recordViewContext),
                        ),
                        BlocProvider.value(
                          value: BlocProvider.of<BackupBloc>(recordViewContext),
                        ),
                      ],
                      child: BlocBuilder<AccountBloc, AccountState>(
                        builder: (context, state) {
                          if (state is AccountStateUpdateToAccount) {
                            toAccount = state.account;
                            isToAccountSelected = true;
                          }
                          return Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showAccountBottomSheet(context, 'to');
                              },
                              icon: Icon(IconData(toAccount.iconDataCodePoint,
                                  fontFamily: 'MaterialIcons')),
                              label: Text(toAccount.name),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add notes',
                ),
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 3,
                controller: _noteController,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                decoration: const InputDecoration(
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(),
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                controller: _amountController,
              ),
              const SizedBox(
                height: 10,
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2070),
                        );
                        setState(() {
                          if (date != null) {
                            _dateTime = date;
                          }
                        });
                      },
                      child: Text(
                        '${_dateTime.month}/${_dateTime.day}/${_dateTime.year}',
                        style: TextStyle(
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: colorScheme.secondary,
                    ),
                    TextButton(
                      onPressed: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setState(() {
                          if (time != null) {
                            _time = time;
                          }
                        });
                      },
                      child: Text(
                        '${_time.hourOfPeriod}:${_time.minute} ${_time.period.name}',
                        style: TextStyle(
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setData(RecordData recordData) {
    rc.Record record = recordData.record;
    _amountController.text = record.amount.toString();
    _noteController.text = record.note;
    _dateTime = record.dateTime;
    _time = TimeOfDay.fromDateTime(record.dateTime);
    isFromAccountSelected = true;
    fromAccount = recordData.fromAccount;
    recordType = record.recordType;
    if (RecordType.transfer == record.recordType) {
      isToAccountSelected = true;
      toAccount = recordData.toAccount!;
    }

    if (RecordType.expense == record.recordType) {
      isExpenseCategorySelected = true;
      expenseCategory = recordData.category!;
    }

    if (RecordType.income == record.recordType) {
      isIncomeCategorySelected = true;
      incomeCategory = recordData.category!;
    }
    isEditDataAlreadySet = true;
  }
}
