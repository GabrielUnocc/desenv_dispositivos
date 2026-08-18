import 'package:injectable/injectable.dart';

import '../database/app_database.dart';

/// Módulo injectable para dependências de terceiros que não podem ser
/// anotadas diretamente (ex.: AppDatabase não é nossa classe).
@module
abstract class AppModule {
  @lazySingleton
  AppDatabase get database => AppDatabase();
}
