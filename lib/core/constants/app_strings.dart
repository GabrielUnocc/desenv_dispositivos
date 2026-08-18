/// Strings centralizadas do aplicativo (textos de UI em português).
class AppStrings {
  AppStrings._();

  static const String appName = 'Gerenciador de Tarefas';

  // Rotas / títulos de tela
  static const String screenHome = 'Minhas Tarefas';
  static const String screenNewTask = 'Nova Tarefa';
  static const String screenEditTask = 'Editar Tarefa';
  static const String screenTaskDetail = 'Detalhes da Tarefa';
  static const String screenDashboard = 'Dashboard';
  static const String screenSettings = 'Configurações';

  // Categorias padrão
  static const String categoryWork = 'Trabalho';
  static const String categoryStudy = 'Estudo';
  static const String categoryPersonal = 'Pessoal';
  static const String categoryShopping = 'Compras';
  static const String categoryHealth = 'Saúde';

  // Prioridades
  static const String priorityHigh = 'Alta';
  static const String priorityMedium = 'Média';
  static const String priorityLow = 'Baixa';

  // Tema
  static const String themeLight = 'Tema Claro';
  static const String themeDark = 'Tema Escuro';
  static const String themeSystem = 'Seguir Sistema';
  static const String settingsTheme = 'Aparência';

  // Ações comuns
  static const String actionSave = 'Salvar';
  static const String actionCancel = 'Cancelar';
  static const String actionDelete = 'Excluir';
  static const String actionEdit = 'Editar';
  static const String actionConfirm = 'Confirmar';
  static const String actionClose = 'Fechar';

  // Mensagens de validação
  static const String validationTitleEmpty = 'O título não pode estar vazio.';
  static const String validationInvalidDate = 'Data inválida.';
  static const String validationCategoryRequired = 'Selecione uma categoria.';

  // Mensagens de confirmação
  static const String confirmDeleteTitle = 'Excluir tarefa?';
  static const String confirmDeleteMessage =
      'Esta ação não pode ser desfeita.';

  // Snackbars
  static const String taskCreated = 'Tarefa criada com sucesso!';
  static const String taskUpdated = 'Tarefa atualizada!';
  static const String taskDeleted = 'Tarefa excluída.';
  static const String taskCompleted = 'Tarefa concluída!';

  // Estados vazios
  static const String emptyTaskList = 'Nenhuma tarefa encontrada.';
  static const String emptySearch = 'Nenhum resultado para sua busca.';
}
