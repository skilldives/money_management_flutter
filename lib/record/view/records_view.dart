import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/account/model/account.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/record/model/edit_record.dart';
import 'package:money_management/record/model/record.dart' as rc;
import 'package:money_management/record/bloc/record_bloc.dart';
import 'package:money_management/record/view/record_bottom_view.dart';
import 'package:money_management/record/view/record_list_view.dart';
import 'package:money_management/record/view/record_title_view.dart';
import 'package:money_management/util/constants/money_enum.dart';
import 'package:money_management/util/constants/routes.dart';

class RecordsView extends StatefulWidget {
  const RecordsView({super.key});

  @override
  State<RecordsView> createState() => _RecordsViewState();
}

class _RecordsViewState extends State<RecordsView>
    with SingleTickerProviderStateMixin {
  ViewMode viewMode = ViewMode.monthly;

  @override
  void initState() {
    super.initState();
    context.read<RecordBloc>().add(RecordEventViewMode(
          viewMode: viewMode,
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 1;
        },
        scrolledUnderElevation: 4.0,
        shadowColor: Theme.of(context).shadowColor,
        title: RecordTitleView(
          viewMode: viewMode,
        ),
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, kBottomNavigationBarHeight),
          child: RecordBottomView(),
        ),
      ),
      body: BlocBuilder<RecordBloc, RecordState>(
        builder: (context, state) {
          viewMode = state.viewMode;
          if (state is RecordStateFetched) {
            List<rc.Record> records = state.records;
            Map<String, Category> categoryMap = state.categoryMap;
            Map<String, Account> accountMap = state.accountMap;
            return RecordListView(
              records: records,
              categoryMap: categoryMap,
              accountMap: accountMap,
              viewMode: viewMode,
            );
          } else if (state is RecordStateEmptyFetch) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wysiwyg_outlined,
                    size: 70,
                    color: colorScheme.outline,
                  ),
                  const Text('No record, Tap + to add new expense or income')
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await HapticFeedback.mediumImpact();
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushNamed(
            createRecordRoute,
            // ignore: use_build_context_synchronously
            arguments: EditRecord(
              context: context,
              recordData: null,
              viewMode: viewMode,
            ),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
