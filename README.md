# Gerenciador de Tarefas Inteligente

Aplicativo mobile desenvolvido em Flutter para gerenciamento inteligente de tarefas pessoais. Projeto universitário da disciplina **Explorando Tecnologias Móveis**, construído com arquitetura profissional, código limpo e boas práticas de engenharia de software.

---

## Screenshots

> _Screenshots serão adicionados após a demonstração final._

| Home | Nova Tarefa | Dashboard |
|------|-------------|-----------|
| ![Home]() | ![Nova Tarefa]() | ![Dashboard]() |

| Detalhes | Filtros | Tema Escuro |
|----------|---------|-------------|
| ![Detalhes]() | ![Filtros]() | ![Tema Escuro]() |

---

## Funcionalidades

- **CRUD completo** de tarefas — criar, visualizar, editar e excluir
- **Busca em tempo real** por título e descrição
- **Filtros** por categoria, prioridade, status (concluídas / pendentes), tarefas de hoje e atrasadas
- **Ordenação** por data, nome, prioridade e categoria
- **Concluir tarefa** via checkbox, swipe ou botão, com animação
- **Excluir** via swipe com diálogo de confirmação obrigatório
- **Favoritar tarefas** para acesso rápido
- **Categorias personalizadas** com cor — padrão: Trabalho, Estudo, Pessoal, Compras, Saúde
- **Prioridades** (Alta / Média / Baixa) com ícone e cor
- **Dashboard** com estatísticas: total, concluídas, pendentes, atrasadas, percentual de conclusão e gráfico
- **Tema claro e escuro** com preferência persistida entre sessões

---

## Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| UI | Flutter (stable) + Material Design 3 |
| Estado | Provider / ChangeNotifier |
| Navegação | GoRouter |
| Banco de dados | Drift (SQLite) |
| Injeção de dependência | get_it + injectable |
| Geração de código | build_runner + drift_dev |
| Utilitários | intl, uuid, equatable, shared_preferences |
| Testes | flutter_test |

---

## Arquitetura

O projeto segue **Clean Architecture** com padrão **MVVM** e **Repository Pattern**. As dependências apontam sempre de fora para dentro: `Presentation → Domain ← Data`.

```
┌─────────────────────────────────────────────────────┐
│                   Presentation                      │
│         Pages · Widgets · Controllers (VM)          │
└────────────────────────┬────────────────────────────┘
                         │ chama use cases
┌────────────────────────▼────────────────────────────┐
│                     Domain                          │
│         Entities · Use Cases · Repositories         │
│              (Dart puro, sem Flutter)               │
└────────────────────────┬────────────────────────────┘
                         │ implementado por
┌────────────────────────▼────────────────────────────┐
│                      Data                           │
│         DataSources (Drift) · Models · Repos        │
└─────────────────────────────────────────────────────┘
```

**Regras:**
- Nenhuma lógica de negócio dentro das telas — telas apenas exibem estado e disparam ações
- Controllers chamam use cases, nunca repositórios diretamente
- Injeção de dependência centralizada via `get_it`

---

## Estrutura de Pastas

```
lib/
├── core/
│   ├── constants/        # Cores e strings globais
│   ├── database/         # Configuração do Drift (tabelas, conexão)
│   ├── di/               # Injeção de dependência (get_it + injectable)
│   ├── routes/           # Rotas declarativas (GoRouter)
│   ├── theme/            # Tema claro/escuro, Material 3
│   └── utils/            # Formatadores de data, extensões de prioridade
└── features/
    └── tasks/
        ├── data/
        │   ├── datasource/     # Acesso direto ao banco (Drift)
        │   ├── models/         # Conversão entidade ↔ banco
        │   └── repositories/   # Implementação dos contratos do domain
        ├── domain/
        │   ├── entities/       # Task, Category, Priority
        │   ├── repositories/   # Contratos (interfaces abstratas)
        │   └── usecases/       # Uma ação por classe (CreateTask, GetTasks…)
        └── presentation/
            ├── controllers/    # TaskController, CategoryController (MVVM)
            ├── pages/          # Home, Formulário, Detalhes, Dashboard, Settings
            └── widgets/        # TaskCard e demais widgets da feature
```

---

## Como Executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal stable)
- Dart SDK incluso no Flutter
- Para Linux: dependências do GTK (`libgtk-3-dev`)
- Para Android: Android Studio + emulador ou dispositivo físico

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/GabrielUnocc/gerenciador-tarefas-inteligente.git
cd gerenciador-tarefas-inteligente

# 2. Instale as dependências
flutter pub get

# 3. Gere o código do Drift e do Injectable
dart run build_runner build --delete-conflicting-outputs

# 4. Execute o app
flutter run -d linux       # janela nativa Linux (desenvolvimento)
flutter run -d chrome      # navegador (alternativa)
flutter run                # dispositivo Android conectado ou emulador
```

### Verificar código

```bash
flutter analyze    # deve retornar zero erros
flutter test       # rodar a suíte de testes
```

---

## Como Gerar o APK

```bash
# APK de release (otimizado para entrega/demonstração)
flutter build apk --release

# O arquivo gerado estará em:
# build/app/outputs/flutter-apk/app-release.apk
```

> Para assinar o APK antes de publicar na Play Store, configure um `key.properties`
> conforme a [documentação oficial do Flutter](https://docs.flutter.dev/deployment/android).

---

## Testes

A suíte de testes cobre as camadas de domínio e apresentação:

```
test/
└── unit/
    ├── domain/
    │   ├── entities/           # Testes da entidade Task
    │   └── usecases/           # Testes dos use cases (CreateTask, GetTasks…)
    └── presentation/
        └── controllers/        # Testes do TaskController (filtros, busca, ordenação)
```

```bash
flutter test                         # rodar todos os testes
flutter test test/unit/domain/       # rodar apenas os testes de domínio
```

---

## Licença

Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

> Desenvolvido por **Gabriel Rosário** — Trabalho universitário, disciplina Explorando Tecnologias Móveis.
