import 'package:money_management/category/model/category.dart';
import 'package:money_management/service/storage_service_sql.dart';
import 'package:money_management/util/constants/money_enum.dart';

class CategoryService {
  static final CategoryService _shared = CategoryService._sharedInstance();

  CategoryService._sharedInstance();

  factory CategoryService() => _shared;

  StorageService storageService = StorageService();

  Future<Map<String, Category>> getCategoryMap() async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    List<Category> categories = await CategoryProvider(db).getAllCategories();
    Map<String, Category> categoryMap = {};
    for (var element in categories) {
      categoryMap[element.id] = element;
    }
    return categoryMap;
  }

  Future<Map<String, List<Category>>> getCategoryList(
      {required RecordType recordType}) async {
    recordType = recordType;
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    Map<String, List<Category>> categories =
        await CategoryProvider(db).geAllCategoriesByRecordType(recordType);
    return categories;
  }

  Future<List<Category>> getCategoriesListByRecordAndCategoryType(
      {required RecordType recordType,
      required bool isSubCategorySelected}) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    List<Category> categoryList = [];
    try {
      categoryList = await CategoryProvider(db)
          .getCategoriesListByRecordAndCategoryType(
              recordType, isSubCategorySelected);
    } catch (_) {}
    return categoryList;
  }

  createNewCategory(Category category) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await CategoryProvider(db).insert(category);
  }

  deleteCategory({
    required Category category,
  }) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await CategoryProvider(db).delete(category);
  }

  updateCategory(Category category) async {
    await storageService.initializeDatabase();
    final db = storageService.getDatabaseOrThrow();
    await CategoryProvider(db).update(category);
  }
}
