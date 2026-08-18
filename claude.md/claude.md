# CLAUDE.md — Gerenciador de Tarefas Inteligente

> Manual do projeto para o Claude Code. Leia este arquivo por completo antes de
> executar qualquer tarefa. Ele define a arquitetura, as convenções, os comandos
> e — o mais importante — o **fluxo de trabalho por etapas com aprovação**.

---

## 1. Visão geral

Aplicativo mobile chamado **Gerenciador de Tarefas Inteligente**, desenvolvido em
**Flutter**. É um trabalho universitário (disciplina "Explorando Tecnologias
Móveis"), então o código deve parecer um **projeto real e profissional**, e não um
protótipo "só para funcionar".

Prioridades inegociáveis: código limpo, escalável, organizado, com componentes
reutilizáveis, arquitetura bem definida e documentado.

---

## 2. Stack técnica

- **Flutter** (canal stable) + **Dart**
- **Material Design 3** (usar `useMaterial3: true`)
- **Clean Architecture** + Repository Pattern + MVVM + SOLID + Injeção de Dependência
- Persistência local com **Drift** (banco SQL). Se ficar complexo demais em alguma
  etapa, migrar para **Hive**. **Nunca** usar apenas armazenamento em memória.
- Navegação com **GoRouter**
- Injeção de dependência com **get_it** (+ `injectable` opcional)
- Gerência de estado: **ChangeNotifier / Provider** via controllers (ViewModels).
  Manter simples e alinhado com MVVM.

> Antes de adicionar qualquer pacote, confirmar a versão estável mais recente
> compatível com o Flutter instalado. Rodar `flutter pub get` após cada mudança
> no `pubspec.yaml`.

---

## 3. Comandos essenciais

```bash
flutter pub get                    # baixar/atualizar dependências
flutter run -d linux               # rodar o app (janela nativa Linux, dia a dia)
flutter run -d chrome              # rodar no navegador (alternativa)
flutter analyze                    # verificar erros e avisos no código
flutter test                       # rodar os testes
dart run build_runner build --delete-conflicting-outputs   # gerar código do Drift
flutter build apk --release        # gerar o APK para entrega/demonstração
```

**Ambiente de teste principal:** janela nativa do Linux (`flutter run -d linux`).
O emulador Android fica reservado para a demonstração final e o APK.

Sempre que gerar ou alterar código, rodar `flutter analyze` e garantir **zero erros**
antes de encerrar a etapa.

---

## 4. Arquitetura (Clean Architecture)

Três camadas, com dependências apontando **sempre para dentro** (presentation →
domain ← data). O `domain` não conhece Flutter nem o banco.

- **domain/** — regras de negócio puras (Dart puro, sem Flutter):
  - `entities/` — objetos de negócio (ex.: `Task`, `Category`)
  - `repositories/` — contratos (interfaces abstratas)
  - `usecases/` — casos de uso, uma ação por classe (ex.: `CreateTask`, `GetTasks`)
- **data/** — implementação de acesso a dados:
  - `datasource/` — acesso ao banco local (Drift)
  - `models/` — modelos que convertem de/para a entidade (`toEntity`/`fromEntity`)
  - `repositories/` — implementação concreta dos contratos do domain
- **presentation/** — interface e estado:
  - `pages/` — telas
  - `widgets/` — widgets específicos da feature
  - `controllers/` — ViewModels (estado + lógica de tela, sem regra de negócio)

Regras:
- **Nenhuma lógica de negócio dentro das telas.** Telas só exibem estado e disparam
  ações do controller.
- Controllers chamam **use cases**, nunca o repositório direto.
- Injeção de dependência centralizada (registrar tudo no container do `get_it`).

---

## 5. Estrutura de pastas

```
lib/
  core/
    constants/      # cores, strings, valores fixos
    theme/          # tema claro/escuro, Material 3
    routes/         # configuração do GoRouter
    database/       # setup do Drift (conexão, tabelas base)
    utils/          # formatadores de data, helpers
    widgets/        # widgets reutilizáveis em todo o app
    di/             # injeção de dependência (get_it)
  features/
    tasks/
      data/
        datasource/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        pages/
        widgets/
        controllers/
  main.dart
```

---

## 6. Modelo de dados

**Task (tarefa)** — campos obrigatórios:
- `id`
- `title` (título)
- `description` (descrição)
- `categoryId` (categoria)
- `priority` (prioridade)
- `createdAt` (data de criação)
- `dueDate` (data limite)
- `isCompleted` (concluída — boolean)
- `isFavorite` (favorita — boolean; diferencial)

**Category (categoria):**
- `id`, `name`, `color`
- Padrão: Trabalho, Estudo, Pessoal, Compras, Saúde
- O usuário pode criar novas categorias, cada uma com sua cor.

**Priority (prioridade)** — enum com `icon` e `color`:
- Alta, Média, Baixa

---

## 7. Requisitos funcionais

- **CRUD completo:** criar, editar, excluir e visualizar detalhes de tarefas.
- **Lista principal:** AppBar, campo de pesquisa, filtro, lista de tarefas e FAB
  para adicionar. Cada card mostra: título, categoria, prioridade, data limite e status.
- **Busca em tempo real** por título e descrição.
- **Filtros:** por categoria, por prioridade, concluídas, pendentes, de hoje e atrasadas.
- **Ordenação:** por data, nome, prioridade e categoria.
- **Concluir tarefa** por checkbox, swipe e botão — com animação.
- **Excluir** por swipe, sempre com **diálogo de confirmação** antes.
- **Dashboard** com estatísticas: total, concluídas, pendentes, atrasadas,
  percentual de conclusão e um gráfico simples.
- **Tema claro e escuro**, com a preferência **persistida** entre sessões.

---

## 8. Interface (Material 3)

A interface deve parecer um app publicado na Play Store. Usar: Cards, Bottom Sheets,
Dialogs, Snackbars, animações suaves e Hero Animations quando fizer sentido.

**Rotas (GoRouter):** Home, Nova tarefa, Editar tarefa, Detalhes, Configurações, Dashboard.

**Validações** (com mensagens amigáveis ao usuário):
- Não permitir título vazio.
- Não permitir data inválida.
- Não permitir categoria inexistente.

---

## 9. Diferenciais (implementar se houver tempo, sem quebrar o essencial)

Favoritar tarefas · Notificações locais para tarefas próximas do vencimento ·
Indicador de progresso · Empty State · Tela de onboarding · Splash Screen.

---

## 10. Convenções de código

- **Identificadores em inglês** (classes, variáveis, métodos); **comentários em
  português**, explicativos e úteis (o quê e por quê, não o óbvio).
- Arquivos pequenos e coesos — uma responsabilidade por arquivo.
- Separar de fato: widgets reutilizáveis, services, repositories, models, entities,
  use cases e controllers.
- Preferir `const` onde possível; seguir as regras do `flutter analyze`.
- Para cada módulo importante, criar um `.md` de documentação explicando o que faz
  e como se encaixa na arquitetura.

---

## 11. Entregáveis e Git

Preparar o projeto para o GitHub:
- `.gitignore` (padrão Flutter)
- `LICENSE` (MIT)
- `README.md` completo, contendo: descrição, tecnologias, arquitetura, estrutura do
  projeto, como executar, como gerar o APK e espaços reservados para screenshots.

---

## 12. Fluxo de trabalho — LEIA COM ATENÇÃO

O projeto é desenvolvido **por etapas**. Regras obrigatórias:

1. **Nunca gerar tudo de uma vez.**
2. Trabalhar **uma etapa por vez**, na ordem abaixo.
3. Em cada etapa: (a) **explicar** o que será feito; (b) gerar **apenas** os
   arquivos daquela etapa; (c) explicar **como testar** antes de seguir.
4. Ao final de cada etapa, **parar e esperar a aprovação explícita do usuário**
   antes de começar a próxima. Não avançar sozinho.

**Ordem das entregas:**

1. Estrutura completa do projeto (pastas + `flutter create`)
2. Dependências (`pubspec.yaml`)
3. Configuração do tema (claro/escuro, Material 3)
4. Banco local (Drift)
5. Modelos
6. Arquitetura (entities, repositories, use cases, DI)
7. CRUD
8. Interface
9. Dashboard
10. Busca e filtros
11. Testes
12. README

> Observação sobre testes: nas etapas 1 a 7 ainda há pouca UI visível — validar com
> `flutter pub get` e `flutter analyze` (sem erros). A partir da etapa 8, testar
> rodando `flutter run -d linux` e interagindo com o app.
