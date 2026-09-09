import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  // Database — registered when Drift tables and DAOs are scaffolded
  // Repositories — registered per feature as they are built
  // Blocs — registered as factories when features are built
}