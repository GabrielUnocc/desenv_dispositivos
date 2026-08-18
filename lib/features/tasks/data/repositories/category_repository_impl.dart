import 'package:injectable/injectable.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasource/category_local_datasource.dart';
import '../models/category_model.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._datasource);
  final CategoryLocalDatasource _datasource;

  @override
  Stream<List<Category>> watchAllCategories() =>
      _datasource.watchAll().map((rows) => rows.map(CategoryModel.fromData).toList());

  @override
  Future<List<Category>> getCategories() async {
    final rows = await _datasource.getAll();
    return rows.map(CategoryModel.fromData).toList();
  }

  @override
  Future<int> createCategory(Category category) =>
      _datasource.insert(CategoryModel.toInsertCompanion(category));

  @override
  Future<void> updateCategory(Category category) =>
      _datasource.update(CategoryModel.toCompanion(category));

  @override
  Future<void> deleteCategory(int id) => _datasource.delete(id);
}
