import 'package:core/core.dart';
import 'package:watch_logs_domain/models/models.dart';
import 'package:watch_logs_domain/repositories/watch_logs_repository.dart';

/// Emotions picked last, shown first in the picker (F2.2).
class GetRecentEmotions extends UseCase<void, Result<List<Emotion>>> {
  final WatchLogsRepository _repository;

  GetRecentEmotions(this._repository);

  @override
  Future<Result<List<Emotion>>> call([void params]) =>
      _repository.getRecentEmotions();
}

/// GIFs picked last (F2.2).
class GetRecentGifs extends UseCase<void, Result<List<Gif>>> {
  final WatchLogsRepository _repository;

  GetRecentGifs(this._repository);

  @override
  Future<Result<List<Gif>>> call([void params]) => _repository.getRecentGifs();
}

class SearchGifsParams {
  final String query;
  final String? cursor;

  const SearchGifsParams({required this.query, this.cursor});
}

/// GIF search through the server, which holds the provider key (F2.2).
class SearchGifs extends UseCase<SearchGifsParams, Result<GifPage>> {
  final WatchLogsRepository _repository;

  SearchGifs(this._repository);

  @override
  Future<Result<GifPage>> call([SearchGifsParams? params]) async {
    final query = params!.query.trim();
    if (query.isEmpty) return const Success(GifPage(gifs: []));
    return _repository.searchGifs(query, cursor: params.cursor);
  }
}
