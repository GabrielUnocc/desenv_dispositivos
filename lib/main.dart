import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/tasks/domain/entities/category.dart';
import 'features/tasks/domain/repositories/category_repository.dart';
import 'features/tasks/domain/usecases/create_category.dart';
import 'features/tasks/domain/usecases/create_task.dart';
import 'features/tasks/domain/usecases/delete_category.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/domain/usecases/get_categories.dart';
import 'features/tasks/domain/usecases/get_task_by_id.dart';
import 'features/tasks/domain/usecases/get_tasks.dart';
import 'features/tasks/domain/usecases/toggle_task_completed.dart';
import 'features/tasks/domain/usecases/toggle_task_favorite.dart';
import 'features/tasks/domain/usecases/update_category.dart';
import 'features/tasks/domain/usecases/update_task.dart';
import 'features/tasks/presentation/controllers/category_controller.dart';
import 'features/tasks/presentation/controllers/task_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  // Popula o banco com as categorias padrão na primeira execução.
  await _seedDefaultCategories();

  final themeController = ThemeController();
  await themeController.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider(
          create: (_) => TaskController(
            getTasks: getIt<GetTasks>(),
            createTask: getIt<CreateTask>(),
            updateTask: getIt<UpdateTask>(),
            deleteTask: getIt<DeleteTask>(),
            getTaskById: getIt<GetTaskById>(),
            toggleCompleted: getIt<ToggleTaskCompleted>(),
            toggleFavorite: getIt<ToggleTaskFavorite>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryController(
            getCategories: getIt<GetCategories>(),
            createCategory: getIt<CreateCategory>(),
            updateCategory: getIt<UpdateCategory>(),
            deleteCategory: getIt<DeleteCategory>(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}

/// Insere as 5 categorias padrão se o banco estiver vazio.
Future<void> _seedDefaultCategories() async {
  final repo = getIt<CategoryRepository>();
  final existing = await repo.getCategories();
  if (existing.isNotEmpty) return;

  final create = getIt<CreateCategory>();
  final defaults = [
    Category(
        id: 0,
        name: AppStrings.categoryWork,
        color: AppColors.categoryWork.toARGB32()),
    Category(
        id: 0,
        name: AppStrings.categoryStudy,
        color: AppColors.categoryStudy.toARGB32()),
    Category(
        id: 0,
        name: AppStrings.categoryPersonal,
        color: AppColors.categoryPersonal.toARGB32()),
    Category(
        id: 0,
        name: AppStrings.categoryShopping,
        color: AppColors.categoryShopping.toARGB32()),
    Category(
        id: 0,
        name: AppStrings.categoryHealth,
        color: AppColors.categoryHealth.toARGB32()),
  ];

  for (final cat in defaults) {
    await create(cat);
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
