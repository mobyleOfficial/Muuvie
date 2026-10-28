import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watch_logs/watch_logs.dart';

WatchLog _log() => WatchLog(
  id: 1,
  userId: 'ana',
  movieId: 10,
  watchedOn: DateTime(2026, 10, 1),
  cycle: 1,
  mode: WatchMode.watched,
  completed: true,
  createdAt: DateTime(2026, 10, 1),
);

/// Only the calls the use cases under test make; anything else fails the test.
class _FakeRepository implements WatchLogsRepository {
  final calls = <String>[];

  @override
  Future<Result<WatchLog>> logSession({
    required int movieId,
    required WatchLogDraft draft,
  }) async {
    calls.add('log $movieId');
    return Success(_log());
  }

  @override
  Future<Result<WatchLog>> logSessionByTmdbId({
    required int tmdbId,
    required String title,
    required WatchLogDraft draft,
  }) async {
    calls.add('log tmdb $tmdbId $title');
    return Success(_log());
  }

  @override
  Future<Result<MovieRating>> rate(int movieId, RatingDraft draft) async {
    calls.add('rate ${draft.rating.wireValue} log=${draft.createLog}');
    return Success(MovieRating(id: 1, rating: draft.rating));
  }

  @override
  Future<Result<ThreadComment>> postComment({
    required CommentTarget target,
    required int targetId,
    required String body,
    bool hasSpoiler = false,
    int? parentId,
  }) async {
    calls.add('comment "$body"');
    return Success(
      ThreadComment(
        id: 1,
        authorId: 'ana',
        authorName: 'ana',
        body: body,
        createdAt: DateTime(2026),
      ),
    );
  }

  @override
  Future<Result<GifPage>> searchGifs(String query, {String? cursor}) async {
    calls.add('gifs $query');
    return const Success(GifPage(gifs: []));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  group('LogWatchSession', () {
    test(
      'logs by database id, or by TMDB id when that is all there is',
      () async {
        final logSession = LogWatchSession(repository);
        final draft = WatchLogDraft.watchedOn(DateTime(2026, 10, 1));

        await logSession(LogWatchSessionParams(movieId: 10, draft: draft));
        await logSession(
          LogWatchSessionParams(tmdbId: 603, title: 'Matrix', draft: draft),
        );

        expect(repository.calls, ['log 10', 'log tmdb 603 Matrix']);
      },
    );

    test('rejects minutes past the runtime and too many emotions', () async {
      final logSession = LogWatchSession(repository);

      final overRuntime = await logSession(
        LogWatchSessionParams(
          movieId: 10,
          runtime: 100,
          draft: WatchLogDraft(
            watchedOn: DateTime(2026),
            mode: WatchMode.minutes,
            minutesWatched: 101,
          ),
        ),
      );
      final sevenEmotions = await logSession(
        LogWatchSessionParams(
          movieId: 10,
          draft: WatchLogDraft(
            watchedOn: DateTime(2026),
            emotions: Emotion.values.take(7).toList(),
          ),
        ),
      );

      expect((overRuntime as Failure).error, AppError.badRequest);
      expect((sevenEmotions as Failure).error, AppError.badRequest);
      expect(repository.calls, isEmpty);
    });

    test('without a runtime any non-negative minutes go to the server', () {
      final draft = WatchLogDraft(
        watchedOn: DateTime(2026),
        mode: WatchMode.minutes,
        minutesWatched: 300,
      );
      expect(isValidWatchLogDraft(draft, null), isTrue);
      expect(isValidWatchLogDraft(draft, 0), isTrue);
      expect(
        isValidWatchLogDraft(
          WatchLogDraft(watchedOn: DateTime(2026), mode: WatchMode.percent),
          null,
        ),
        isFalse,
      );
    });
  });

  test('abandoned and on hold cannot create the 100% session', () async {
    final setRating = SetMovieRating(repository);

    final abandoned = await setRating(
      const SetMovieRatingParams(
        movieId: 10,
        draft: RatingDraft(rating: Rating.abandoned, createLog: true),
      ),
    );
    await setRating(
      const SetMovieRatingParams(
        movieId: 10,
        draft: RatingDraft(rating: Rating.onHold),
      ),
    );
    await setRating(
      const SetMovieRatingParams(
        movieId: 10,
        draft: RatingDraft(rating: Rating.favorite, createLog: true),
      ),
    );

    expect((abandoned as Failure).error, AppError.badRequest);
    expect(repository.calls, [
      'rate on_hold log=false',
      'rate favorite log=true',
    ]);
  });

  test('comments are trimmed and empty ones are not sent', () async {
    final postComment = PostThreadComment(repository);

    final empty = await postComment(
      const PostThreadCommentParams(
        target: CommentTarget.watchLog,
        targetId: 5,
        body: '   ',
      ),
    );
    await postComment(
      const PostThreadCommentParams(
        target: CommentTarget.rating,
        targetId: 3,
        body: '  Que filme  ',
      ),
    );

    expect((empty as Failure).error, AppError.badRequest);
    expect(repository.calls, ['comment "Que filme"']);
  });

  test('an empty GIF query answers empty without a request', () async {
    final searchGifs = SearchGifs(repository);

    final empty = await searchGifs(const SearchGifsParams(query: ' '));
    await searchGifs(const SearchGifsParams(query: ' cinema '));

    expect((empty as Success<GifPage>).data.gifs, isEmpty);
    expect(repository.calls, ['gifs cinema']);
  });

  test('rewatch is offered only once the current cycle is done', () {
    const unfinished = MovieUserState(
      status: WatchStatus.watched,
      progress: WatchProgress(cycle: 2, percent: 30, completed: false),
    );
    const done = MovieUserState(
      status: WatchStatus.watched,
      progress: WatchProgress(cycle: 1, percent: 100, completed: true),
    );

    expect(unfinished.canRewatch, isFalse);
    expect(done.canRewatch, isTrue);
  });
}
