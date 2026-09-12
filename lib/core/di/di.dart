import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:productive_muslim/core/router/app_router.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  // Router — singleton, created eagerly
  getIt.registerSingleton<GoRouter>(AppRouter.router);

  // Repositories — registered per feature as they are built
  // Blocs — registered as factories when features are built
}
