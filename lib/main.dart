import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:muuvie/app_initializer.dart';
import 'package:muuvie/config/app_config.dart';
import 'package:muuvie/di/injection.dart';
import 'package:muuvie/routes/app_router.dart';
import 'package:muuvie/routes/app_movie_detail_links.dart';
import 'package:movies_ui/movie_detail/movie_detail_links.dart';
import 'package:profile/profile.dart';
import 'package:movies/movies.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  AppConfig.instance = AppConfig.fromEnvironment();
  mainApp();
}

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  final store = openStore(directory: '${appDir.path}/objectbox');
  configureDependencies(store: store);

  GetIt.I.registerSingleton<MovieDetailLinks>(const AppMovieDetailLinks());

  final appInitializer = AppInitializer(
    webSocketClient: GetIt.I<WebSocketClient>(),
    getUserProfile: GetIt.I<ObserveUserProfile>(),
  );

  AuthGate.configure(loginRoute: const AuthFlowRoute());
  runApp(MyApp(appInitializer: appInitializer));
}

class MyApp extends StatefulWidget {
  final AppInitializer appInitializer;

  const MyApp({super.key, required this.appInitializer});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    widget.appInitializer.initialize();
  }

  @override
  void dispose() {
    widget.appInitializer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.instance.appName,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: MuuvieTheme.light,
      darkTheme: MuuvieTheme.dark,
      routerConfig: _appRouter.config(deepLinkBuilder: profileDeepLink),
      // DateFormat without an explicit locale follows the app language.
      builder: (context, child) {
        Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
