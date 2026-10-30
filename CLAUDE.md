# CLAUDE.md — Gerenciador de Tarefas Inteligente

## Contexto do Projeto

App Flutter para a disciplina **Explorando Tecnologias Móveis** — UNOCHAPECÓ
Professor: Cezar Junior de Souza
Entrega: **13/11/2026** | Seminário: **13/11/2026** e **27/11/2026**

## Funcionalidades obrigatórias

- Criar, editar e excluir tarefas
- Categorias: Trabalho, Estudo, Pessoal
- Prioridades: Alta, Média, Baixa
- Marcar tarefa como concluída (checkbox + texto riscado)
- Buscar e filtrar (por texto, categoria, prioridade e status)
- Persistência local dos dados

## Artefatos de entrega

- Código-fonte completo no GitHub
- APK de release (`flutter build apk --release`)
- README.md (como rodar e gerar APK)
- SEMINARIO.md (roteiro da apresentação)
- Slides de apresentação

---

## Convenções

### Commits — Conventional Commits em português
```
feat: adiciona tela de criação de tarefas
fix: corrige filtro por prioridade
refactor: reorganiza camada de domínio
chore: configura dependências do pubspec
test: adiciona testes do TaskRepository
```

### Código
- Todo código em **inglês** (variáveis, funções, classes, arquivos)
- Comentários curtos e apenas quando o "porquê" não é óbvio

### Arquitetura
```
lib/
  domain/          # entidades + interface do repositório
  data/            # banco Drift + implementação do repositório
  presentation/    # providers, screens, widgets
  main.dart
```

- **State management:** Provider (ChangeNotifier)
- **Persistência:** Drift (SQLite)
- **Use cases:** classes finas; se só repassam ao repositório, o provider chama o repositório direto

### A cada etapa concluída

1. Rodar `flutter analyze`
2. Explicar as decisões em poucas linhas
3. Sugerir a mensagem de commit (Conventional Commits em português) para o usuário executar
4. Parar para validação do usuário

---

## Plano de Etapas

### Etapa 1 — Setup e estrutura
- Inicializar projeto Flutter
- Configurar `pubspec.yaml` (drift, provider, sqlite3_flutter_libs, path_provider, build_runner)
- Criar estrutura de pastas
- Definir entidades de domínio: `Task`, enum `Category`, enum `Priority`

### Etapa 2 — Persistência local (Drift)
- `AppDatabase` com tabela `tasks`
- `TaskDao`: inserir, atualizar, deletar, listar, buscar por texto

### Etapa 3 — Repositório
- Interface `TaskRepository` no domínio
- `TaskRepositoryImpl` na camada data
- Use cases apenas para operações com lógica real; demais chamadas direto no provider

### Etapa 4 — Gerenciamento de estado
- `TaskProvider` (ChangeNotifier)
- Filtros combináveis: busca por texto, categoria, prioridade e status (todas / pendentes / concluídas)

### Etapa 5 — Tela principal
- `HomeScreen`: lista com `TaskCard`
- Checkbox para marcar concluída (texto riscado)
- Barra de busca + chips de filtro
- Mensagem de lista vazia / filtro sem resultado
- FAB para criar tarefa

### Etapa 6 — Tela de criar/editar
- `TaskFormScreen` reutilizada para criar e editar
- Campos: título, descrição, categoria, prioridade
- Validação de formulário

### Etapa 7 — Polimento, tema e APK
- Cores por prioridade, ícones por categoria
- Snackbars + diálogo de confirmação de exclusão
- Tema claro/escuro (Material 3)
- Ícone do app
- Testes básicos
- Gerar APK release: `flutter build apk --release`

### Etapa 8 — Documentação
- `README.md`: como clonar, rodar (`flutter run`) e gerar APK
- `SEMINARIO.md`: roteiro do seminário
  - A. Introdução ao Flutter (5 min): características, vantagens/desvantagens, casos de uso
  - B. Processo de desenvolvimento (10 min): ambiente, estrutura de pastas, widgets, estado e dados, hot reload
  - C. Build e deploy (5 min): geração de APK, considerações de performance
  - D. Comparativo com React Native (5 min): diferenças no fluxo de desenvolvimento
