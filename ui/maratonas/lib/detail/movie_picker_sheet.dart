import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shelves/shelves.dart';

/// Picks a movie from the maratona queue or from Já assisti to mark a
/// challenge with (F7.5). Answers the movie database id.
class MoviePickerSheet extends StatefulWidget {
  final int? queueShelfId;

  const MoviePickerSheet({super.key, this.queueShelfId});

  static Future<int?> show(BuildContext context, {int? queueShelfId}) =>
      MuuvieBottomSheet.show<int>(
        context: context,
        builder: (_) => MoviePickerSheet(queueShelfId: queueShelfId),
      );

  @override
  State<MoviePickerSheet> createState() => _MoviePickerSheetState();
}

enum _Source { queue, watched }

class _MoviePickerSheetState extends State<MoviePickerSheet> {
  final _getShelfMovies = GetIt.I<GetShelfMovies>();
  final _getUserShelves = GetIt.I<GetUserShelves>();

  late _Source _source = widget.queueShelfId != null
      ? _Source.queue
      : _Source.watched;
  int? _watchedShelfId;
  List<ShelfMovie> _movies = const [];
  int _page = 1;
  bool _hasNext = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<int?> _shelfId() async {
    if (_source == _Source.queue) return widget.queueShelfId;
    if (_watchedShelfId != null) return _watchedShelfId;
    final result = await _getUserShelves(const GetUserShelvesParams());
    if (result case Success(:final data)) {
      _watchedShelfId = data.items
          .where((shelf) => shelf.systemType == SystemShelfType.watched)
          .firstOrNull
          ?.id;
    }
    return _watchedShelfId;
  }

  Future<void> _load({bool more = false}) async {
    setState(() => _loading = true);
    final shelfId = await _shelfId();
    if (shelfId == null) {
      if (mounted) {
        setState(() {
          _movies = const [];
          _loading = false;
        });
      }
      return;
    }
    final page = more ? _page + 1 : 1;
    final result = await _getShelfMovies(
      GetShelfMoviesParams(shelfId: shelfId, page: page),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result case Success(:final data)) {
        _movies = more ? [..._movies, ...data.items] : data.items;
        _page = page;
        _hasNext = data.hasNext;
      }
    });
  }

  void _select(_Source source) {
    if (_source == source) return;
    _source = source;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<_Source>(
                  segments: [
                    if (widget.queueShelfId != null)
                      ButtonSegment(
                        value: _Source.queue,
                        label: Text(l10n?.maratonaLinkFromQueue ?? ''),
                      ),
                    ButtonSegment(
                      value: _Source.watched,
                      label: Text(l10n?.maratonaLinkFromWatched ?? ''),
                    ),
                  ],
                  selected: {_source},
                  onSelectionChanged: (selection) => _select(selection.first),
                ),
              ),
              Expanded(
                child: _loading && _movies.isEmpty
                    ? const Center(child: MuuvieActivityIndicator())
                    : _movies.isEmpty
                    ? Center(child: Text(l10n?.maratonaPickerEmpty ?? ''))
                    : ListView.builder(
                        itemCount: _movies.length + (_hasNext ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _movies.length) {
                            return Center(
                              child: _loading
                                  ? const MuuvieActivityIndicator()
                                  : TextButton(
                                      onPressed: () => _load(more: true),
                                      child: Text(l10n?.maratonaLoadMore ?? ''),
                                    ),
                            );
                          }
                          final movie = _movies[index];
                          return ListTile(
                            onTap: () =>
                                Navigator.of(context).pop(movie.movieId),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                width: 36,
                                height: 54,
                                child: movie.posterPath == null
                                    ? const Icon(Icons.movie_outlined)
                                    : CachedNetworkImage(
                                        imageUrl: TmdbImageUrl.buildPosterSmall(
                                          movie.posterPath!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            title: Text(movie.title),
                            subtitle: movie.year == null
                                ? null
                                : Text('${movie.year}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
