import 'package:go_router/go_router.dart';

import '../../features/tasks/presentation/pages/home_page.dart';
import '../../features/tasks/presentation/pages/settings_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';

/// Configuração central de navegação usando GoRouter.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      // Criar nova tarefa — listado antes de /tasks/:id para ter precedência
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => const TaskFormPage(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskDetailPage(taskId: id);
        },
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskFormPage(taskId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
