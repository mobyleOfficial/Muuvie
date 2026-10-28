import 'dart:async';

import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/widgets/cineclube_labels.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';

/// Picks the movie of a session (F8.5) with the Catálogo search.
class MovieSearchSheet extends StatefulWidget {
  final SearchMovies searchMovies;

  const MovieSearchSheet({super.key, required this.searchMovies});

  static Future<CineClubeMovie?> show(
    BuildContext context,
    SearchMovies searchMovies,
  ) => MuuvieBottomSheet.show<CineClubeMovie>(
    context: context,
    builder: (_) => MovieSearchSheet(searchMovies: searchMovies),
  );

  @override
  State<MovieSearchSheet> createState() => _MovieSearchSheetState();
}

class _MovieSearchSheetState extends State<MovieSearchSheet> {
  Timer? _debounce;
  var _query = '';
  bool _loading = false;
  bool _failed = false;
  List<Movie> _movies = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _query = value.trim();
    if (_query.length < 2) {
      setState(() => _movies = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final query = _query;
      setState(() {
        _loading = true;
        _failed = false;
      });
      final result = await widget.searchMovies(
        SearchMoviesParams(query: query),
      );
      if (!mounted || query != _query) return;
      setState(() {
        _loading = false;
        switch (result) {
          case Success(:final data):
            _movies = data.movies;
          case Failure():
            _failed = true;
        }
      });
    });
  }

  static int? _year(Movie movie) {
    final date = movie.info?.releaseDate ?? '';
    return date.length < 4 ? null : int.tryParse(date.substring(0, 4));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    autofocus: true,
                    onChanged: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n?.cineclubeSearchMovie,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                if (_loading) const LinearProgressIndicator(),
                Expanded(
                  child: _failed
                      ? MuuvieEmptyState(
                          illustration: null,
                          title: l10n?.emptyStateErrorTitle ?? '',
                          message: l10n?.emptyStateErrorMessage ?? '',
                        )
                      : ListView.builder(
                          itemCount: _movies.length,
                          itemBuilder: (context, index) {
                            final movie = _movies[index];
                            final year = _year(movie);
                            return ListTile(
                              leading: CineClubePoster(
                                posterPath: movie.posterPath,
                                width: 36,
                              ),
                              title: Text(movie.displayTitle),
                              subtitle: year == null ? null : Text('$year'),
                              onTap: () => Navigator.of(context).pop(
                                CineClubeMovie(
                                  id: movie.id,
                                  title: movie.displayTitle,
                                  posterPath: movie.posterPath,
                                  year: year,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
