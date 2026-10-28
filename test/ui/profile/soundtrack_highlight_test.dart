import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/member/highlights/highlights_tab.dart';

class _Profiles implements ProfilesRepository {
  final List<ProfileHighlight> highlights;

  _Profiles(this.highlights);

  @override
  Future<Result<List<ProfileHighlight>>> getHighlights(String userId) async =>
      Success(highlights);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

void main() {
  tearDown(() => GetIt.I.reset());

  test('the soundtrack service comes from the https host of the link', () {
    expect(
      SoundtrackService.of('https://open.spotify.com/track/1'),
      SoundtrackService.spotify,
    );
    expect(
      SoundtrackService.of('https://music.youtube.com/playlist?list=PL1'),
      SoundtrackService.youtubeMusic,
    );
    expect(SoundtrackService.of('https://www.youtube.com/watch?v=1'), isNull);
    expect(SoundtrackService.of('http://music.youtube.com/watch?v=1'), isNull);
    expect(SoundtrackService.of('https://music.youtube.com/'), isNull);
    expect(SoundtrackService.of(null), isNull);
  });

  for (final (url, label) in [
    ('https://open.spotify.com/track/1', 'Ouvir no Spotify'),
    ('https://music.youtube.com/watch?v=1', 'Ouvir no YouTube Music'),
  ]) {
    testWidgets('the Destaques tab offers "$label"', (tester) async {
      GetIt.I.registerFactory(
        () => GetProfileHighlights(
          _Profiles([
            ProfileHighlight(
              type: HighlightType.soundtrack,
              soundtrackUrl: url,
            ),
          ]),
        ),
      );

      await tester.pumpWidget(_app(const HighlightsTab(userId: 'ana')));
      await tester.pumpAndSettle();

      expect(find.text(label), findsOneWidget);
    });
  }
}
