import 'package:flutter/material.dart';
import 'package:money_management/category/model/category.dart';
import 'package:money_management/category/view/category_popup_menu.dart';

class CategoryListTile extends StatelessWidget {
  const CategoryListTile({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: () {},
      title: CategoryListTileTitle(
        categoryName: category.name,
      ),
      leading: Icon(
        IconData(
          category.iconDataCodePoint,
          fontFamily: 'MaterialIcons',
        ),
        size: textTheme.headlineLarge?.fontSize,
      ),
      trailing: CategoryPopupMenu(
        category: category,
      ),
    );
  }
}

class CategoryListTileTitle extends StatelessWidget {
  const CategoryListTileTitle({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      categoryName,
      maxLines: 1,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: textTheme.titleMedium?.fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
