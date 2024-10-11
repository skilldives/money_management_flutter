import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/category/bloc/category_bloc.dart';
import 'package:money_management/category/view/add_category_dialog.dart';
import 'package:money_management/category/view/category_list_view.dart';
import 'package:money_management/util/constants/money_enum.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<CategoryBloc>().add(const CategoryEventFetch(
          recordType: RecordType.expense,
          isDeleteOperation: false,
          isDeleted: false,
          isUpdateOperation: false,
          isUpdated: false,
        ));
    _tabController.addListener(() {
      int index = _tabController.index;
      if (index == 0) {
        context.read<CategoryBloc>().add(const CategoryEventFetch(
              recordType: RecordType.expense,
              isDeleteOperation: false,
              isDeleted: false,
              isUpdateOperation: false,
              isUpdated: false,
            ));
      } else {
        context.read<CategoryBloc>().add(const CategoryEventFetch(
              recordType: RecordType.income,
              isDeleteOperation: false,
              isDeleted: false,
              isUpdateOperation: false,
              isUpdated: false,
            ));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: TabBar(
          dividerColor: Colors.transparent,
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              child: Center(
                child: Text(
                  'Expense',
                  style: TextStyle(
                    fontSize: textTheme.titleMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Tab(
              child: Center(
                child: Text(
                  'Income',
                  style: TextStyle(
                    fontSize: textTheme.titleMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          CategoryListView(),
          CategoryListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await HapticFeedback.mediumImpact();
          // ignore: use_build_context_synchronously
          showAddCategoryDialog(
            context: context,
            passedCategory: null,
          );
        },
        shape: const CircleBorder(),
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
