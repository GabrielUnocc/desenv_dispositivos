import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

@lazySingleton
class CreateCategory {
  CreateCategory(this._repository);
  final CategoryRepository _repository;

  Future<int> call(Category category) => _repository.createCategory(category);
}
