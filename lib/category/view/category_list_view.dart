import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management/category/bloc/category_bloc.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/category/view/category_list_tile.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryStateFetched) {
          Map<String, List<Category>> categoriesMap = state.categoriesMap;
          return ListView.builder(
            itemCount: categoriesMap.keys.length,
            itemBuilder: (context, index) {
              final categories = categoriesMap.values.elementAt(index);
              return Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                  color: colorScheme.secondaryContainer,
                ),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    CategoryListTile(
                      category: categories.first,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ListView.builder(
                        itemCount: categories.length - 1,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              const Divider(
                                indent: 20,
                              ),
                              CategoryListTile(
                                category: categories[index + 1],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else if (state is CategoryStateEmptyFetch) {
          return const Center(
            child: Text('No categories, Tap + to add new categories'),
          );
        } else {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
      },
    );
  }
}
