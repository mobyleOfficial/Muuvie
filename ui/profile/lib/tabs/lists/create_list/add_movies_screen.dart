import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';

class AddMoviesScreen extends StatefulWidget {
  final SearchMovies searchMovies;
  final List<Movie> alreadySelected;

  const AddMoviesScreen({
    super.key,
    required this.searchMovies,
    required this.alreadySelected,
  });

  @override
  State<AddMoviesScreen> createState() => _AddMoviesScreenState();
}

class _AddMoviesScreenState extends State<AddMoviesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late List<Movie> _selected = List.of(widget.alreadySelected);
  List<Movie> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  static const _debounceDuration = Duration(milliseconds: 300);
  static const _minQueryLength = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < _minQueryLength) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounceTimer = Timer(_debounceDuration, () => _search(query));
  }

  Future<void> _search(String query) async {
    final result =
        await widget.searchMovies(SearchMoviesParams(query: query));
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _searchResults = data.movies;
          _isSearching = false;
        });
      case Failure():
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
    }
  }

  void _toggleMovie(Movie movie) {
    setState(() {
      if (_selected.any((m) => m.id == movie.id)) {
        _selected = _selected.where((m) => m.id != movie.id).toList();
      } else {
        _selected = [..._selected, movie];
      }
    });
  }

  void _pop() => Navigator.of(context).pop(_selected);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pop();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _pop,
            ),
            title: MuuvieEditText(
              controller: _searchController,
              focusNode: _searchFocusNode,
              placeholder: 'Search movies...',
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, _) => value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: _pop,
                child: Text(
                  'Done (${_selected.length})',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isNotEmpty
                  ? ListView.separated(
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, _) => Divider(
                        indent: 72,
                        height: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      itemBuilder: (context, index) {
                        final movie = _searchResults[index];
                        final isSelected =
                            _selected.any((m) => m.id == movie.id);
                        return _MovieResultTile(
                          movie: movie,
                          isSelected: isSelected,
                          onTap: () => _toggleMovie(movie),
                        );
                      },
                    )
                  : _selected.isNotEmpty
                      ? _SelectedList(
                          movies: _selected,
                          onRemove: (id) => setState(() {
                            _selected = _selected
                                .where((m) => m.id != id)
                                .toList();
                          }),
                        )
                      : Center(
                          child: Text(
                            'Search for movies to add',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
        ),
      ),
    );
  }
}

class _SelectedList extends StatelessWidget {
  final List<Movie> movies;
  final ValueChanged<int> onRemove;

  const _SelectedList({required this.movies, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'SELECTED (${movies.length})',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _MovieResultTile(
              movie: movie,
              isSelected: true,
              onTap: () => onRemove(movie.id),
            );
          },
        ),
      ],
    );
  }
}

class _MovieResultTile extends StatelessWidget {
  final Movie movie;
  final bool isSelected;
  final VoidCallback? onTap;

  const _MovieResultTile({
    required this.movie,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 44,
                height: 64,
                child: movie.posterPath.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl:
                            TmdbImageUrl.buildPosterSmall(movie.posterPath),
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                            color: colorScheme.surfaceContainerHighest),
                        errorWidget: (_, _, _) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.movie,
                              size: 20,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.movie,
                            size: 20, color: colorScheme.onSurfaceVariant),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.info?.releaseDate.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(
                      movie.info!.releaseDate.length >= 4
                          ? movie.info!.releaseDate.substring(0, 4)
                          : movie.info!.releaseDate,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(Icons.check_circle,
                      key: const ValueKey('check'),
                      size: 24,
                      color: colorScheme.primary)
                  : Icon(Icons.add_circle_outline,
                      key: const ValueKey('add'),
                      size: 24,
                      color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
