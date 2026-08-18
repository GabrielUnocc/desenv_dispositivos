import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

@lazySingleton
class GetCategories {
  GetCategories(this._repository);
  final CategoryRepository _repository;

  Stream<List<Category>> call() => _repository.watchAllCategories();
}
