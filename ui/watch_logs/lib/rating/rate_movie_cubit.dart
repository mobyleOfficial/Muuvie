import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_logs/watch_logs.dart';

class RateMovieState {
  /// Null until the user picks a label.
  final Rating? rating;
  final String review;
  final bool hasSpoiler;
  final Set<Emotion> emotions;
  final List<Emotion> recentEmotions;
  final bool createLog;
  final ContentVisibility visibility;
  final bool isSaving;

  const RateMovieState({
    this.rating,
    this.review = '',
    this.hasSpoiler = false,
    this.emotions = const {},
    this.recentEmotions = const [],
    this.createLog = false,
    this.visibility = ContentVisibility.defaultValue,
    this.isSaving = false,
  });

  /// Abandonei and Na geladeira never create the 100% session.
  bool get canCreateLog => rating?.isVerdict ?? true;

  bool get willCreateLog => createLog && canCreateLog;

  RateMovieState copyWith({
    Rating? rating,
    String? review,
    bool? hasSpoiler,
    Set<Emotion>? emotions,
    List<Emotion>? recentEmotions,
    bool? createLog,
    ContentVisibility? visibility,
    bool? isSaving,
  }) => RateMovieState(
    rating: rating ?? this.rating,
    review: review ?? this.review,
    hasSpoiler: hasSpoiler ?? this.hasSpoiler,
    emotions: emotions ?? this.emotions,
    recentEmotions: recentEmotions ?? this.recentEmotions,
    createLog: createLog ?? this.createLog,
    visibility: visibility ?? this.visibility,
    isSaving: isSaving ?? this.isSaving,
  );
}

/// "Qual opção melhor reflete sua avaliação final?": one label, plus the
/// emotions and visibility of the optional 100% session (phase 13).
class RateMovieCubit extends Cubit<RateMovieState> {
  final int movieId;
  final SetMovieRating _setMovieRating;
  final RemoveMovieRating _removeMovieRating;
  final GetRecentEmotions _getRecentEmotions;

  RateMovieCubit({
    required this.movieId,
    MovieRating? current,
    bool alreadyWatched = false,
    required SetMovieRating setMovieRating,
    required RemoveMovieRating removeMovieRating,
    required GetRecentEmotions getRecentEmotions,
  }) : _setMovieRating = setMovieRating,
       _removeMovieRating = removeMovieRating,
       _getRecentEmotions = getRecentEmotions,
       super(
         RateMovieState(
           rating: current?.rating,
           review: current?.review ?? '',
           hasSpoiler: current?.hasSpoiler ?? false,
           // On by default, as in the Maratona, unless the movie is watched already.
           createLog: !alreadyWatched,
         ),
       ) {
    _loadRecentEmotions();
  }

  Future<void> _loadRecentEmotions() async {
    final result = await _getRecentEmotions();
    if (isClosed) return;
    if (result case Success(:final data)) {
      emit(state.copyWith(recentEmotions: data));
    }
  }

  void setRating(Rating value) => emit(state.copyWith(rating: value));

  void setReview(String value) => emit(state.copyWith(review: value));

  void setSpoiler(bool value) => emit(state.copyWith(hasSpoiler: value));

  void setEmotions(Set<Emotion> value) => emit(state.copyWith(emotions: value));

  void setCreateLog(bool value) => emit(state.copyWith(createLog: value));

  void setVisibility(ContentVisibility value) =>
      emit(state.copyWith(visibility: value));

  /// Returns false when saving failed.
  Future<bool> save() async {
    final rating = state.rating;
    if (rating == null || state.isSaving) return false;
    emit(state.copyWith(isSaving: true));
    final review = state.review.trim();
    final createLog = state.willCreateLog;
    final result = await _setMovieRating(
      SetMovieRatingParams(
        movieId: movieId,
        draft: RatingDraft(
          rating: rating,
          review: review.isEmpty ? null : review,
          hasSpoiler: state.hasSpoiler,
          emotions: createLog ? state.emotions.toList() : const [],
          createLog: createLog,
          visibility: state.visibility,
        ),
      ),
    );
    if (isClosed) return false;
    emit(state.copyWith(isSaving: false));
    return result is Success<MovieRating>;
  }

  Future<bool> remove() async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true));
    final result = await _removeMovieRating(movieId);
    if (isClosed) return false;
    emit(state.copyWith(isSaving: false));
    return result is Success;
  }
}
