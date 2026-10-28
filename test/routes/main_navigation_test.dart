import 'package:flutter_test/flutter_test.dart';
import 'package:muuvie/routes/app_router.dart';
import 'package:muuvie/routes/main_navigation.dart';
import 'package:news_ui/news_list/news_list_router.dart';
import 'package:programacao/programacao_router.dart';

void main() {
  group('MainNavigation', () {
    final navigation = MainNavigation();

    test(
      'has the five tabs: Perfil · Atts · Programação · Catálogo · Notícias',
      () {
        expect(navigation.tabs.map((tab) => tab.routeName), [
          ProfileTab.name,
          SocialTab.name,
          ProgramacaoTab.name,
          SearchTab.name,
          NoticiasTab.name,
        ]);
      },
    );

    test('only Programação and Notícias work logged out', () {
      final publicTabs = navigation.tabs
          .where((tab) => !tab.requiresLogin)
          .map((tab) => tab.routeName);

      expect(publicTabs, [ProgramacaoTab.name, NoticiasTab.name]);
    });

    test('opens Perfil when logged in and Programação when logged out', () {
      expect(
        navigation.tabs[navigation.initialIndex(isLoggedIn: true)].routeName,
        ProfileTab.name,
      );
      expect(
        navigation.tabs[navigation.initialIndex(isLoggedIn: false)].routeName,
        ProgramacaoTab.name,
      );
    });

    test('falls back to a public tab when the session ends', () {
      expect(
        navigation.tabs[navigation.publicFallbackIndex].requiresLogin,
        false,
      );
    });

    test('Atts has the Sussurros action in its app bar', () {
      expect(navigation.tabs[1].actions, isNotNull);
    });
  });

  group('AppRouter', () {
    final mainRoute = AppRouter().routes.firstWhere(
      (route) => route.name == MainRoute.name,
    );
    final tabRoutes = {
      for (final route in mainRoute.children!) route.name: route,
    };

    test('registers exactly the tabs of the navigation under MainRoute', () {
      expect(
        tabRoutes.keys.toSet(),
        MainNavigation().tabs.map((tab) => tab.routeName).toSet(),
      );
    });

    test('tabs open on their root page', () {
      String initialChild(String tabName) => tabRoutes[tabName]!.children!
          .firstWhere((route) => route.initial)
          .name;

      expect(initialChild(ProgramacaoTab.name), ProgramacaoRoute.name);
      expect(initialChild(NoticiasTab.name), NewsListRoute.name);
    });
  });
}
