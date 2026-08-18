import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Instância global do service locator.
final getIt = GetIt.instance;

/// Inicializa todas as dependências registradas via Injectable.
/// Deve ser chamado antes de [runApp] no main.dart.
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
