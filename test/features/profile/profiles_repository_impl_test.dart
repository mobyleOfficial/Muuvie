import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile/profile.dart';

import '../../helpers/fake_http_client.dart';

const _profileJson = {
  'id': 'ana-id',
  'username': 'ana',
  'handle': 'ana.cinefila',
  'displayName': 'Ana',
  'pronouns': 'ela/dela',
  'bio': 'Terror e giallo',
  'avatarUrl': null,
  'bannerUrl': 'https://img.example/banner.jpg',
  'accentColor': '#FF5500',
  'links': ['https://ana.example'],
  'featured': false,
  'stats': {
    'shelves': 4,
    'locadoras': 1,
    'watchLogs': 12,
    'watched': 30,
    'maratonas': 0,
    'cineclubes': 0,
    'participations': 0,
    'followers': 5,
    'following': 2,
  },
  'isFollowing': true,
  'followsMe': true,
  'mutual': true,
  'self': false,
  'isScraping': false,
};

void main() {
  late FakeHttpClient http;
  late ProfilesRepositoryImpl repository;

  setUp(() {
    http = FakeHttpClient();
    repository = ProfilesRepositoryImpl(ProfilesRemoteDataSourceImpl(http));
  });

  test(
    'a profile opens by @handle and maps the counters and the relation',
    () async {
      http.response = const Success(_profileJson);

      final result = await GetProfileDetails(repository)('@ana.cinefila');

      final profile = (result as Success<ProfileDetails>).data;
      expect(http.calls.single.path, '/api/v1/users/@ana.cinefila');
      expect(profile.name, 'Ana');
      expect(profile.handle, 'ana.cinefila');
      expect(profile.links, ['https://ana.example']);
      expect(profile.stats.watchLogs, 12);
      expect(profile.stats.followers, 5);
      expect(profile.mutual, true);
      expect(profile.isSelf, false);
    },
  );

  test('without a display name the username is the name', () {
    const profile = ProfileDetails(
      id: 'x',
      username: 'bia',
      stats: ProfileStats(),
    );

    expect(profile.name, 'bia');
  });

  test(
    'saving sends every field and a taken handle comes back as a conflict',
    () async {
      http.response = const Failure(AppError.conflict);

      final result = await SaveMyProfile(repository)(
        const ProfileDraft(
          displayName: 'Ana',
          handle: 'ana.cinefila',
          links: ['https://a.example'],
        ),
      );

      expect((result as Failure).error, AppError.conflict);
      expect(http.calls.single.method, 'PUT');
      expect(http.calls.single.path, '/api/v1/users/me');
      expect(http.calls.single.body, {
        'displayName': 'Ana',
        'handle': 'ana.cinefila',
        'pronouns': null,
        'bio': null,
        'links': ['https://a.example'],
        'accentColor': null,
        'avatarUrl': null,
        'bannerUrl': null,
      });
    },
  );

  test(
    'a handle in the wrong format is answered without the backend',
    () async {
      final result = await CheckHandleAvailability(repository)('@Ab');

      final availability = (result as Success<HandleAvailability>).data;
      expect(availability.available, false);
      expect(availability.problem, HandleProblem.invalid);
      expect(http.calls, isEmpty);
    },
  );

  test('the backend says when a handle is taken', () async {
    http.response = const Success({
      'handle': 'ana.cinefila',
      'available': false,
      'reason': 'taken',
    });

    final result = await CheckHandleAvailability(repository)('@Ana.Cinefila');

    expect(http.calls.single.path, '/api/v1/handles/ana.cinefila/available');
    expect(
      (result as Success<HandleAvailability>).data.problem,
      HandleProblem.taken,
    );
  });

  test(
    'highlights map the movies and the shelf, and unknown types are skipped',
    () async {
      http.response = const Success([
        {
          'type': 'top4',
          'position': 0,
          'enabled': true,
          'movieIds': [10],
          'movies': [
            {
              'movieId': 10,
              'tmdbId': 100,
              'title': 'Halloween',
              'posterPath': '/h.jpg',
              'year': 1978,
            },
          ],
        },
        {
          'type': 'shelf',
          'position': 1,
          'enabled': false,
          'shelfId': 7,
          'shelf': {
            'id': 7,
            'ownerId': 'ana-id',
            'name': 'Giallo',
            'visibility': 'public',
            'sortMode': 'manual',
            'pinned': false,
            'totalMovies': 3,
            'totalWatched': 1,
            'posterPaths': [],
            'self': true,
          },
        },
        {'type': 'pet', 'position': 2, 'enabled': true},
      ]);

      final result = await GetProfileHighlights(repository)('me');

      final highlights = (result as Success<List<ProfileHighlight>>).data;
      expect(highlights.map((h) => h.type), [
        HighlightType.top4,
        HighlightType.shelf,
      ]);
      expect(highlights.first.movies.single.title, 'Halloween');
      expect(highlights.last.enabled, false);
      expect(highlights.last.shelf?.name, 'Giallo');
    },
  );

  test(
    'saving highlights sends them in order with their configuration',
    () async {
      http.response = const Success([]);

      await SaveProfileHighlights(repository)(const [
        ProfileHighlight(
          type: HighlightType.soundtrack,
          soundtrackUrl: 'https://open.spotify.com/track/1',
        ),
        ProfileHighlight(
          type: HighlightType.top4,
          enabled: false,
          movieIds: [10, 11],
        ),
      ]);

      expect(http.calls.single.path, '/api/v1/users/me/highlights');
      final sent = (http.calls.single.body! as Map)['highlights'] as List;
      expect(sent.map((h) => (h as Map)['type']), ['soundtrack', 'top4']);
      expect((sent.last as Map)['movieIds'], [10, 11]);
      expect((sent.last as Map)['enabled'], false);
    },
  );
}
