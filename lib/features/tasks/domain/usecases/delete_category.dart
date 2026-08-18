import 'package:injectable/injectable.dart';

import '../repositories/category_repository.dart';

@lazySingleton
class DeleteCategory {
  DeleteCategory(this._repository);
  final CategoryRepository _repository;

  Future<void> call(int id) => _repository.deleteCategory(id);
}
