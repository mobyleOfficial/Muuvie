enum AppFlavor { dev, staging, prod }

class AppConfig {
  final AppFlavor flavor;
  final String backendUrl;

  const AppConfig({required this.flavor, required this.backendUrl});

  static late AppConfig instance;

  static const _flavorName = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static AppFlavor get _flavorFromEnv => switch (_flavorName) {
    'staging' => AppFlavor.staging,
    'prod' => AppFlavor.prod,
    _ => AppFlavor.dev,
  };

  static String get _backendUrlFromEnv => switch (_flavorFromEnv) {
    AppFlavor.dev => const String.fromEnvironment('DEV_BACKEND_URL'),
    AppFlavor.staging => const String.fromEnvironment('STG_BACKEND_URL'),
    AppFlavor.prod => const String.fromEnvironment('PROD_BACKEND_URL'),
  };

  static AppConfig fromEnvironment() =>
      AppConfig(flavor: _flavorFromEnv, backendUrl: _backendUrlFromEnv);

  String get appName => switch (_flavorFromEnv) {
    AppFlavor.dev => 'MuuvieDev',
    AppFlavor.staging => 'MuuvieStg',
    AppFlavor.prod => 'Muuvie',
  };
}
