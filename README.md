# Gerenciador de Tarefas Inteligente

Aplicativo Flutter desenvolvido para a disciplina **Explorando Tecnologias Móveis**
— UNOCHAPECÓ | Prof. Cezar Junior de Souza.

## Funcionalidades

- Criar, editar e excluir tarefas
- Categorias: Trabalho, Estudo, Pessoal
- Prioridades: Alta, Média, Baixa
- Marcar tarefas como concluídas (texto riscado)
- Buscar e filtrar por texto, categoria, prioridade e status
- Tema claro e escuro
- Persistência local com SQLite (Drift)

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Persistência | Drift (SQLite) |
| Estado | Provider (ChangeNotifier) |
| Arquitetura | Clean Architecture (domain / data / presentation) |

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.12
- Android SDK (para gerar o APK) ou um emulador/dispositivo Android conectado
- Para rodar no Linux: dependências GTK (`libgtk-3-dev`)

Verificar instalação:

```bash
flutter doctor
```

## Como rodar

```bash
# 1. Clonar o repositório
git clone https://github.com/GabrielUnocc/gerenciadordetarefas.git
cd gerenciadordetarefas

# 2. Instalar dependências
flutter pub get

# 3. Gerar o código do banco de dados (Drift)
dart run build_runner build

# 4. Rodar no Linux (desktop)
flutter run -d linux

# 4. Ou rodar em um dispositivo/emulador Android
flutter run -d android
```

## Como gerar o APK de release

```bash
flutter build apk --release
```

O arquivo será gerado em:

```
build/app/outputs/flutter-apk/app-release.apk
```

Copie o `.apk` para o dispositivo Android e instale (habilite "Fontes desconhecidas" nas configurações).

## Estrutura do projeto

```
lib/
├── domain/                  # regras de negócio (sem dependência de Flutter)
│   ├── entities/
│   │   └── task.dart        # Task, Category (enum), Priority (enum)
│   └── repositories/
│       └── task_repository.dart   # interface de persistência
│
├── data/                    # implementação concreta
│   ├── database/
│   │   ├── app_database.dart      # Drift: tabela, DAO, conexão
│   │   └── app_database.g.dart    # gerado pelo build_runner
│   └── repositories/
│       └── task_repository_impl.dart   # mapeamento TaskRow ↔ Task
│
├── presentation/            # UI
│   ├── providers/
│   │   ├── task_provider.dart     # estado e filtros das tarefas
│   │   └── theme_provider.dart    # alternância claro/escuro
│   ├── screens/
│   │   ├── home_screen.dart       # tela principal (lista + filtros)
│   │   └── task_form_screen.dart  # criar / editar tarefa
│   └── widgets/
│       └── task_card.dart         # card de tarefa com checkbox e badge
│
└── main.dart                # ponto de entrada, injeção de dependências
```

## Testes

```bash
flutter test
```

Inclui:
- Smoke test de widget (`test/widget_test.dart`)
- Testes unitários dos filtros do `TaskProvider` (`test/task_provider_test.dart`)
