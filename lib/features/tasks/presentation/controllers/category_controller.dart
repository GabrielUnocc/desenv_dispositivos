import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';

/// ViewModel responsável pela lista de categorias.
/// Escuta o stream reativo do Drift e notifica a UI a cada mudança.
class CategoryController extends ChangeNotifier {
  CategoryController({
    required GetCategories getCategories,
    required this._createCategory,
    required this._updateCategory,
    required this._deleteCategory,
  }) {
    _sub = getCategories().listen(
      (list) {
        _categories = list;
        notifyListeners();
      },
    );
  }

  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  StreamSubscription<List<Category>>? _sub;
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Category? findById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> createCategory(Category category) => _createCategory(category);

  Future<void> updateCategory(Category category) => _updateCategory(category);

  Future<void> deleteCategory(int id) => _deleteCategory(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
