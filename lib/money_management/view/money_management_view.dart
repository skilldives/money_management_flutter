import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/bloc/account_bloc.dart';
import 'package:money_management/analysis/bloc/analysis_bloc.dart';
import 'package:money_management/auth/bloc/auth_bloc.dart';
import 'package:money_management/auth/bloc/auth_event.dart';

import 'package:money_management/backup/bloc/bloc/backup_bloc.dart';
import 'package:money_management/category/bloc/category_bloc.dart';
import 'package:money_management/main.dart';
import 'package:money_management/money_management/bloc/bloc/money_management_bloc.dart';
import 'package:money_management/record/bloc/record_bloc.dart';
import 'package:money_management/record/view/records_view.dart';
import 'package:money_management/auth/service/login_service.dart';
import 'package:money_management/auth/view/auth_dialog.dart';
import 'package:money_management/account/view/accounts_view.dart';
import 'package:money_management/analysis/view/analysis_view.dart';
import 'package:money_management/budget/view/budgets_view.dart';
import 'package:money_management/category/view/categories_view.dart';
import 'package:money_management/util/common_util.dart';
import 'package:money_management/util/constants/money_enum.dart';

class MoneyManagementView extends StatefulWidget {
  const MoneyManagementView({super.key});

  @override
  State<MoneyManagementView> createState() => _MoneyManagementViewState();
}

class _MoneyManagementViewState extends State<MoneyManagementView> {
  int currentPageIndex = 0;
  final LoginService loginService = LoginService();
  late bool isDarkMode;
  Currency cur = CurrencyService().findByCode('INR')!;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    context.read<MoneyManagementBloc>().add(const MMEventFetchCurrency());
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecordBloc>(
          create: (context) => RecordBloc(),
        ),
        BlocProvider(
          create: (context) => AccountBloc(),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(),
        ),
        BlocProvider(
          create: (context) => AnalysisBloc(),
        ),
      ],
      child: Scaffold(
        drawer: NavigationDrawer(
          children: [
            Center(
              child: Text(
                loginService.currentUser?.displayName ?? '',
                style: TextStyle(
                  fontSize: textTheme.titleMedium?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await HapticFeedback.mediumImpact();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                final shouldLogout = await showAuthDialog(
                  context: context,
                  isLogin: loginService.currentUser == null,
                );
                if (shouldLogout) {
                  // ignore: use_build_context_synchronously
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }
              },
              child:
                  Text(loginService.currentUser == null ? 'Login' : 'Logout'),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: textTheme.titleMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (bool value) {
                    setState(() {
                      isDarkMode = value;
                      if (isDarkMode) {
                        MyApp.of(context).changeTheme(ThemeMode.dark);
                      } else {
                        MyApp.of(context).changeTheme(ThemeMode.light);
                      }
                    });
                  },
                ),
              ],
            ),
            BlocConsumer<MoneyManagementBloc, MoneyManagementState>(
              listener: (context, state) {
                if (state is MMCurrencyUpdated) {
                  if (currentPageIndex == 0) {
                    context.read<RecordBloc>().add(const RecordEventViewMode(
                          viewMode: ViewMode.monthly,
                          isDeleteOperation: false,
                          isDeleted: false,
                          isUpdateOperation: false,
                          isUpdated: false,
                        ));
                  } else if (currentPageIndex == 1) {
                    context.read<AccountBloc>().add(const AccountEventFetch(
                          isDeleteOperation: false,
                          isDeleted: false,
                          isUpdateOperation: false,
                          isUpdated: false,
                        ));
                  }
                }
              },
              builder: (context, state) {
                if (state is MMCurrencyFetched) {
                  cur =
                      CurrencyService().findByCode(state.others.currencyCode)!;
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await HapticFeedback.mediumImpact();
                      // ignore: use_build_context_synchronously
                      context
                          .read<BackupBloc>()
                          .add(const BackupEventNeedCloudBackup());
                      // ignore: use_build_context_synchronously
                      showCurrencyPicker(
                        context: context,
                        onSelect: (Currency currency) {
                          context
                              .read<MoneyManagementBloc>()
                              .add(MMEventUpdateCurrency(currency: currency));

                          setState(() {});
                        },
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: Text('${cur.symbol}  ${cur.name}'),
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) async {
            await HapticFeedback.mediumImpact();
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.receipt),
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Records',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.account_balance_wallet),
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Accounts',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.category),
              icon: Icon(Icons.category_outlined),
              label: 'Categories',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.data_exploration),
              icon: Icon(Icons.data_exploration_outlined),
              label: 'Analysis',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.cases_rounded),
              icon: Icon(Icons.cases_outlined),
              label: 'Budgets',
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Center(
                  child: Text(
                    'Money Management',
                    style: TextStyle(
                      fontSize: textTheme.titleMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                backgroundColor: colorScheme.inversePrimary,
                actions: [
                  IconButton(
                    onPressed: () async {
                      context
                          .read<BackupBloc>()
                          .add(const BackupEventCloudBackup());
                    },
                    icon: BlocConsumer<BackupBloc, BackupState>(
                      listener: (context, state) {
                        if (state is BackupStateCloudBackupFailed) {
                          CommonUtil.showSnackBarMessage(
                            'Backup Failed!, Check your Internet',
                            context,
                          );
                        } else if (state is BackupStateCloudBackupCompleted) {
                          CommonUtil.showSnackBarMessage(
                            'Backup Completed!',
                            context,
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is BackupStateCloudBackupLoading) {
                          return const CircularProgressIndicator.adaptive();
                        } else if (state is BackupStateCloudBackupCompleted) {
                          return const Icon(Icons.cloud_done);
                        } else if (state is BackupStateNeedCloudBackup) {
                          return Icon(
                            Icons.cloud_upload,
                            color: colorScheme.error,
                          );
                        } else {
                          return const Icon(Icons.cloud_upload);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ];
          },
          body: <Widget>[
            const RecordsView(),
            const AccountsView(),
            const CategoriesView(),
            const AnalysisView(),
            const BudgetsView(),
          ][currentPageIndex],
        ),
      ),
    );
  }
}
