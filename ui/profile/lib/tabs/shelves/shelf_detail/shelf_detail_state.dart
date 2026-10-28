import 'package:shelves/shelves.dart';

sealed class ShelfDetailState {
  const ShelfDetailState();
}

class ShelfDetailLoading extends ShelfDetailState {
  const ShelfDetailLoading();
}

class ShelfDetailSuccess extends ShelfDetailState {
  final Shelf shelf;
  final List<ShelfMovie> movies;
  final ShelfMovieFilter filter;

  /// Movies matching [filter], across all pages.
  final int totalResults;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  /// Drag-to-reorder mode of the manual order (F1.6).
  final bool isReordering;
  final bool isGridView;

  const ShelfDetailSuccess({
    required this.shelf,
    required this.movies,
    required this.filter,
    required this.totalResults,
    required this.page,
    required this.hasNext,
    this.isLoadingMore = false,
    this.isReordering = false,
    this.isGridView = true,
  });

  ShelfDetailSuccess copyWith({
    Shelf? shelf,
    List<ShelfMovie>? movies,
    ShelfMovieFilter? filter,
    int? totalResults,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
    bool? isReordering,
    bool? isGridView,
  }) => ShelfDetailSuccess(
    shelf: shelf ?? this.shelf,
    movies: movies ?? this.movies,
    filter: filter ?? this.filter,
    totalResults: totalResults ?? this.totalResults,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isReordering: isReordering ?? this.isReordering,
    isGridView: isGridView ?? this.isGridView,
  );
}

class ShelfDetailError extends ShelfDetailState {
  final String message;

  const ShelfDetailError(this.message);
}
