import '../entities/category.dart';

/// Contrato de acesso a dados para categorias.
abstract class CategoryRepository {
  Stream<List<Category>> watchAllCategories();
  Future<List<Category>> getCategories();

  /// Retorna o id gerado pelo banco.
  Future<int> createCategory(Category category);

  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}
