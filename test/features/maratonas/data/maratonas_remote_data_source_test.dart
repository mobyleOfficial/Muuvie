import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maratonas/maratonas.dart';

import '../../../helpers/fake_http_client.dart';

const _owner = {'id': 'ana-id', 'username': 'ana', 'displayName': 'Ana'};

/// GET /maratonas/{slug} with a token (backend README, "Maratonas").
const _detail = {
  'id': 7,
  'slug': 'terror-70',
  'title': 'Terror dos anos 70',
  'description': 'Um mês de terror',
  'accentColor': '#E65100',
  'startsOn': '2026-10-01',
  'endsOn': '2026-10-31',
  'status': 'active',
  'hasPassword': true,
  'trusted': false,
  'owner': _owner,
  'coOwners': [],
  'categories': [
    {
      'id': 1,
      'name': 'Terror',
      'position': 0,
      'teamOnly': false,
      'challenges': [
        {
          'id': 11,
          'categoryId': 1,
          'description': 'Um terror dos anos 70',
          'type': 'criteria',
          'criteria': {
            'all': [
              {
                'field': 'genre',
                'op': 'in',
                'value': [27],
              },
              {
                'field': 'decade',
                'op': 'in',
                'value': [1970],
              },
              {
                'field': 'mood',
                'op': 'in',
                'value': ['spooky'],
              },
            ],
          },
          'position': 0,
          'daily': false,
        },
        {
          'id': 12,
          'categoryId': 1,
          'description': 'Um filme brasileiro',
          'type': 'free',
          'position': 1,
          'daily': true,
        },
      ],
    },
  ],
  'levels': [
    {'id': 5, 'name': 'Maratonista', 'minChallenges': 2},
  ],
  'teams': [
    {'id': 9, 'name': 'Azul', 'color': '#039BE5'},
  ],
  'prizes': [],
  'totalChallenges': 2,
  'totalParticipants': 4,
  'createdAt': '2026-09-20T12:00:00Z',
  'me': {
    'levelId': 5,
    'teamId': 9,
    'queueShelfId': 40,
    'completed': 1,
    'joinedAt': '2026-10-02T10:00:00Z',
  },
  'canEdit': false,
};

void main() {
  late FakeHttpClient http;
  late MaratonasRemoteDataSourceImpl dataSource;

  setUp(() {
    http = FakeHttpClient();
    dataSource = MaratonasRemoteDataSourceImpl(http);
  });

  test(
    'the detail keeps the parts, the participation and the criteria',
    () async {
      http.response = const Success(_detail);

      final result = await dataSource.getMaratona('terror-70');

      final maratona = (result as Success<Maratona>).data;
      expect(http.calls.single.path, '/api/v1/maratonas/terror-70');
      expect(maratona.status, MaratonaStatus.active);
      expect(maratona.startsOn, DateTime(2026, 10, 1));
      expect(maratona.challenges.map((c) => c.id), [11, 12]);
      final criteria = maratona.challenges.first.criteria!;
      // A field this version does not know is left out.
      expect(criteria.rules.map((r) => r.field), [
        CriteriaField.genre,
        CriteriaField.decade,
      ]);
      expect(criteria.rule(CriteriaField.decade)!.ints, [1970]);
      expect(maratona.challenges.last.criteria, isNull);
      expect(maratona.challenges.last.daily, true);
      expect(maratona.me!.queueShelfId, 40);
      expect(maratona.level(maratona.me!.levelId)!.name, 'Maratonista');
      expect(maratona.team(9)!.name, 'Azul');
    },
  );

  test('the list sends only the filters that are on', () async {
    http.response = const Success({'results': [], 'page': 1, 'hasNext': false});

    await dataSource.getMaratonas(
      const MaratonaFilter(query: ' terror ', trusted: true, participant: 'me'),
      2,
    );

    final query = http.calls.single.query!;
    expect(query['q'], 'terror');
    expect(query['trusted'], true);
    expect(query['participant'], 'me');
    expect(query['page'], 2);
    expect(query.containsKey('mine'), false);
    expect(query.containsKey('open'), false);
  });

  test('the form becomes the body of POST /maratonas', () async {
    http.response = const Success(_detail);

    await dataSource.create(
      MaratonaForm(
        slug: 'terror-70',
        title: 'Terror dos anos 70',
        startsOn: DateTime(2026, 10, 1),
        endsOn: DateTime(2026, 10, 31),
        password: 'pipoca',
        categories: const [
          CategoryForm(
            name: 'Terror',
            challenges: [
              ChallengeForm(
                description: 'Longo',
                criteria: ChallengeCriteria([
                  CriteriaRule(CriteriaField.runtimeMin, [150]),
                  CriteriaRule(CriteriaField.country, ['BR', 'AR']),
                ]),
              ),
              ChallengeForm(description: 'Livre'),
            ],
          ),
        ],
        levels: const [LevelForm(id: 5, name: 'Mestre', minChallenges: 2)],
      ),
    );

    final call = http.calls.single;
    expect(call.method, 'POST');
    expect(call.path, '/api/v1/maratonas');
    final body = call.body! as Map<String, dynamic>;
    expect(body['startsOn'], '2026-10-01');
    expect(body['password'], 'pipoca');
    final category = (body['categories'] as List).single as Map;
    final challenges = category['challenges'] as List;
    expect((challenges.first as Map)['criteria'], {
      'all': [
        {'field': 'runtime_min', 'op': 'gte', 'value': 150},
        {
          'field': 'country',
          'op': 'in',
          'value': ['BR', 'AR'],
        },
      ],
    });
    expect((challenges.last as Map).containsKey('criteria'), false);
    expect((body['levels'] as List).single, {
      'id': 5,
      'name': 'Mestre',
      'minChallenges': 2,
    });
  });

  test('linking a movie answers the challenge with its links', () async {
    http.response = const Success({
      'id': 12,
      'categoryId': 1,
      'description': 'Um filme brasileiro',
      'type': 'free',
      'completed': true,
      'links': [
        {
          'challengeId': 12,
          'movieId': 30,
          'title': 'Cidade de Deus',
          'source': 'manual',
          'completedAt': '2026-10-05T12:00:00Z',
        },
      ],
    });

    final result = await dataSource.setLink('terror-70', 12, 30, true);

    expect(http.calls.single.method, 'PUT');
    expect(
      http.calls.single.path,
      '/api/v1/maratonas/terror-70/challenges/12/links/30',
    );
    final challenge = (result as Success<MaratonaChallenge>).data;
    expect(challenge.completed, true);
    expect(challenge.links.single.title, 'Cidade de Deus');
  });

  test('the team ranking reads the page envelope', () async {
    http.response = const Success({
      'results': [
        {
          'position': 1,
          'team': {'id': 9, 'name': 'Azul'},
          'members': 2,
          'completed': 5,
        },
      ],
    });

    final result = await dataSource.getTeamRanking('terror-70');

    expect(http.calls.single.query, {'by': 'team'});
    final entry = (result as Success<List<TeamRankingEntry>>).data.single;
    expect(entry.team.name, 'Azul');
    expect(entry.completed, 5);
  });
}
