# Roteiro do Seminário — Gerenciador de Tarefas Inteligente

**Disciplina:** Explorando Tecnologias Móveis — UNOCHAPECÓ
**Tecnologia:** Flutter (Dart)
**Duração:** 20–30 minutos

---

## A. Introdução ao Flutter (5 min)

### O que é Flutter?
Flutter é um framework open-source do Google para criar aplicativos compilados nativamente
para Android, iOS, web e desktop a partir de um **único código-fonte** em Dart.

### Características principais
- **Linguagem Dart**: tipagem forte, orientada a objetos, compilada para ARM nativo (AOT)
- **Widget-based**: tudo é um widget — botão, texto, layout, animação
- **Motor próprio de renderização** (Skia / Impeller): não depende de componentes nativos
  da plataforma, o que garante aparência idêntica em todos os dispositivos
- **Hot reload**: alterações de código aparecem no emulador em menos de 1 segundo sem
  perder o estado da aplicação

### Vantagens
| Vantagem | Detalhe |
|---|---|
| Um código, várias plataformas | Android, iOS, Linux, Windows, macOS, Web |
| Performance | Compilado para código nativo, sem ponte JavaScript |
| UI consistente | Renderização própria → mesma aparência em qualquer dispositivo |
| Material 3 | Componentes modernos prontos para usar |
| Dart fácil de aprender | Sintaxe próxima a Java/Kotlin/C# |

### Desvantagens
- Dart tem comunidade menor que JavaScript/Kotlin
- APK gerado é maior que apps nativos puros (~20–60 MB)
- Acesso a APIs nativas específicas exige plugins ou código nativo adicional
- Curva de aprendizado para o paradigma reativo de widgets

### Casos de uso ideais
- Apps que precisam de UI consistente em iOS e Android
- Startups que querem um único time para todas as plataformas
- MVPs e protótipos rápidos com qualidade de produção

---

## B. Demonstração do Processo de Desenvolvimento (10 min)

### 1. Configuração do ambiente
```bash
# instalar Flutter SDK (flutter.dev/get-started)
flutter doctor          # verifica dependências
flutter create meu_app  # cria projeto
flutter run -d linux    # roda no desktop para desenvolvimento rápido
```

Ferramentas usadas: VS Code + extensão Flutter, Android Studio para emulador Android.

### 2. Estrutura de arquivos do projeto
```
lib/
  domain/       → entidades e interfaces (puro Dart, sem Flutter)
  data/         → banco de dados Drift + repositório
  presentation/ → telas, widgets, providers
  main.dart     → ponto de entrada
```

A **Clean Architecture** divide o projeto em camadas:
- `domain`: o que o app faz (regras, entidades)
- `data`: como persiste (SQLite via Drift)
- `presentation`: como exibe (Flutter UI + Provider)

Cada camada conhece apenas a camada abaixo — fácil de testar e manter.

### 3. Componentes e widgets mais importantes

**Widgets de layout usados:**
```dart
Scaffold → estrutura básica de tela (AppBar, body, FAB)
Column / ListView → organização vertical e listas roláveis
Card → container elevado para cada tarefa
SingleChildScrollView → barra de filtros com scroll horizontal
```

**Widgets de UI específicos:**
```dart
// Seletor de categoria/prioridade — Material 3
SegmentedButton<Category>(
  segments: [...],
  selected: {_category},
  onSelectionChanged: (set) => setState(() => _category = set.first),
)

// Chip de filtro
FilterChip(
  label: Text('Trabalho'),
  selected: provider.categoryFilter == Category.work,
  onSelected: (selected) => provider.setCategoryFilter(...),
)
```

### 4. Gerenciamento de estado e dados

**Provider (ChangeNotifier):**
```dart
class TaskProvider extends ChangeNotifier {
  List<Task> _allTasks = [];

  List<Task> get filteredTasks {
    // filtra em memória — sem nova consulta ao banco
    return _allTasks.where((t) { ... }).toList();
  }

  Future<void> createTask(Task task) async {
    await _repository.createTask(task);
    await loadTasks(); // recarrega e notifica a UI
  }
}
```

A UI ouve com `context.watch<TaskProvider>()` e reconstrói automaticamente.

**Drift (SQLite):**
```dart
// Define a tabela como uma classe Dart
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get category => intEnum<Category>()(); // enum → int no banco
  ...
}

// DAO com operações tipadas
Future<List<TaskRow>> getAllTasks() => select(tasks).get();
Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);
```

O `build_runner` gera o código boilerplate automaticamente (`app_database.g.dart`).

### 5. Hot reload em ação
> **Demonstrar ao vivo:**
> 1. Rodar o app com `flutter run -d linux`
> 2. Mudar a cor seed do tema (`Colors.indigo` → `Colors.teal`)
> 3. Salvar o arquivo → a UI muda em ~1 segundo sem reiniciar o app
> 4. O estado (tarefas na lista) é preservado

---

## C. Build e Deploy (5 min)

### Processo de build
```bash
# Debug (desenvolvimento)
flutter run -d android

# Release APK (entrega)
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

### O que acontece no build release?
1. **AOT compilation**: Dart é compilado diretamente para ARM/ARM64/x64 — sem interpretador em runtime
2. **Tree-shaking de ícones**: `MaterialIcons-Regular.otf` foi de **1.6 MB → 3.3 KB** (redução de 99.8%)
3. **Minificação**: código Dart ofuscado e comprimido
4. **Resultado**: APK de **56 MB** (inclui o motor Flutter + biblioteca SQLite)

### Distribuição
- **Android**: copiar o `.apk` para o dispositivo e instalar (habilitar "Fontes desconhecidas")
- **Google Play**: usar `flutter build appbundle --release` (gera `.aab`)
- **iOS**: requer conta Apple Developer e `flutter build ipa`

### Considerações de performance
- Apps Flutter têm performance comparável a apps nativos na maioria dos casos
- O motor de renderização (Impeller no iOS, em migração no Android) elimina o jank de compilação de shaders
- Para listas longas: usar `ListView.builder` (criação sob demanda) — já implementado

---

## D. Comparativo com React Native (5 min)

| Aspecto | Flutter | React Native |
|---|---|---|
| **Linguagem** | Dart | JavaScript / TypeScript |
| **Renderização** | Motor próprio (Skia/Impeller) | Componentes nativos via bridge |
| **Performance** | Alta — sem bridge | Boa, mas bridge pode ser gargalo |
| **UI** | Idêntica em todas as plataformas | Usa componentes nativos de cada plataforma |
| **Hot Reload** | Sim (muito rápido) | Sim (Fast Refresh) |
| **Ecossistema** | Crescendo rapidamente | Maior, mais maduro |
| **Familiaridade** | Novo (Dart + widgets) | Familiar para devs web (React) |
| **Tamanho do APK** | ~50–80 MB | ~15–30 MB |
| **Empresas** | Google, Alibaba, BMW | Facebook, Microsoft, Shopify |

### Diferenças no fluxo de desenvolvimento
- **React Native**: `<View>`, `<Text>`, `<FlatList>` mapeiam para componentes nativos da plataforma. Estilização com StyleSheet (similar ao CSS). Estado com hooks (`useState`, `useReducer`) ou Redux.
- **Flutter**: tudo é widget Dart. Não há HTML/CSS. Layouts com `Row`, `Column`, `Stack`. Estado com `setState`, Provider, Riverpod, Bloc.
- **Debugging**: ambos têm DevTools. Flutter tem o "Widget Inspector" que permite inspecionar a árvore de widgets visualmente.
- **Na prática**: React Native é mais fácil para quem já conhece React/web. Flutter tem curva inicial maior, mas o código fica muito consistente e previsível.

### Quando escolher Flutter?
- UI customizada que não deve variar entre plataformas
- App desktop + mobile com mesmo código
- Time sem experiência prévia em React

### Quando escolher React Native?
- Time já domina JavaScript/React
- App precisa de aparência nativa de cada plataforma
- Integração intensa com código nativo existente
