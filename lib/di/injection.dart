import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:objectbox/objectbox.dart';

import 'package:muuvie/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies({
  required Store store,
  PushMessaging pushMessaging = const NoopPushMessaging(),
}) {
  getIt.registerSingleton<Store>(store);
  // Firebase or the no-op version, from FirebaseBootstrap (fase 15).
  getIt.registerSingleton<PushMessaging>(pushMessaging);
  getIt.init();
}
