// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:gerenciador_tarefas/core/database/app_database.dart' as _i318;
import 'package:gerenciador_tarefas/core/di/app_module.dart' as _i557;
import 'package:gerenciador_tarefas/features/tasks/data/datasource/category_local_datasource.dart'
    as _i537;
import 'package:gerenciador_tarefas/features/tasks/data/datasource/task_local_datasource.dart'
    as _i1049;
import 'package:gerenciador_tarefas/features/tasks/data/repositories/category_repository_impl.dart'
    as _i748;
import 'package:gerenciador_tarefas/features/tasks/data/repositories/task_repository_impl.dart'
    as _i1048;
import 'package:gerenciador_tarefas/features/tasks/domain/repositories/category_repository.dart'
    as _i432;
import 'package:gerenciador_tarefas/features/tasks/domain/repositories/task_repository.dart'
    as _i310;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/create_category.dart'
    as _i674;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/create_task.dart'
    as _i183;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/delete_category.dart'
    as _i276;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/delete_task.dart'
    as _i951;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/get_categories.dart'
    as _i377;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/get_task_by_id.dart'
    as _i220;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/get_tasks.dart'
    as _i173;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/toggle_task_completed.dart'
    as _i423;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/toggle_task_favorite.dart'
    as _i307;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/update_category.dart'
    as _i608;
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/update_task.dart'
    as _i254;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i318.AppDatabase>(() => appModule.database);
    gh.lazySingleton<_i537.CategoryLocalDatasource>(
      () => _i537.CategoryLocalDatasourceImpl(gh<_i318.AppDatabase>()),
    );
    gh.lazySingleton<_i1049.TaskLocalDatasource>(
      () => _i1049.TaskLocalDatasourceImpl(gh<_i318.AppDatabase>()),
    );
    gh.lazySingleton<_i432.CategoryRepository>(
      () => _i748.CategoryRepositoryImpl(gh<_i537.CategoryLocalDatasource>()),
    );
    gh.lazySingleton<_i674.CreateCategory>(
      () => _i674.CreateCategory(gh<_i432.CategoryRepository>()),
    );
    gh.lazySingleton<_i276.DeleteCategory>(
      () => _i276.DeleteCategory(gh<_i432.CategoryRepository>()),
    );
    gh.lazySingleton<_i377.GetCategories>(
      () => _i377.GetCategories(gh<_i432.CategoryRepository>()),
    );
    gh.lazySingleton<_i608.UpdateCategory>(
      () => _i608.UpdateCategory(gh<_i432.CategoryRepository>()),
    );
    gh.lazySingleton<_i310.TaskRepository>(
      () => _i1048.TaskRepositoryImpl(gh<_i1049.TaskLocalDatasource>()),
    );
    gh.lazySingleton<_i183.CreateTask>(
      () => _i183.CreateTask(gh<_i310.TaskRepository>()),
    );
    gh.lazySingleton<_i951.DeleteTask>(
      () => _i951.DeleteTask(gh<_i310.TaskRepository>()),
    );
    gh.lazySingleton<_i220.GetTaskById>(
      () => _i220.GetTaskById(gh<_i310.TaskRepository>()),
    );
    gh.lazySingleton<_i173.GetTasks>(
      () => _i173.GetTasks(gh<_i310.TaskRepository>()),
    );
    gh.lazySingleton<_i423.ToggleTaskCompleted>(
      () => _i423.ToggleTaskCompleted(gh<_i310.TaskRepository>()),
    );
    gh.lazySingleton<_i307.ToggleTaskFavorite>(
      () => _i307.ToggleTaskFavorite(gh<_i310.TaskRepository>()),
    );
    gh.lazySingleton<_i254.UpdateTask>(
      () => _i254.UpdateTask(gh<_i310.TaskRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i557.AppModule {}
