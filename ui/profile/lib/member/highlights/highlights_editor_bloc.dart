import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/profile.dart';
import 'package:shelves/shelves.dart';

sealed class HighlightsEditorState {
  const HighlightsEditorState();
}

class HighlightsEditorLoading extends HighlightsEditorState {
  const HighlightsEditorLoading();
}

class HighlightsEditorReady extends HighlightsEditorState {
  /// One slot per type, in profile order. A slot without configuration is
  /// left out when saving.
  final List<ProfileHighlight> slots;
  final bool isSaving;

  const HighlightsEditorReady(this.slots, {this.isSaving = false});
}

class HighlightsEditorError extends HighlightsEditorState {
  final String message;

  const HighlightsEditorError(this.message);
}

/// Configures, enables and orders the Destaques of the own profile (F5.4).
class HighlightsEditorCubit extends Cubit<HighlightsEditorState> {
  final GetProfileHighlights _getHighlights;
  final SaveProfileHighlights _saveHighlights;

  HighlightsEditorCubit({
    required GetProfileHighlights getHighlights,
    required SaveProfileHighlights saveHighlights,
  }) : _getHighlights = getHighlights,
       _saveHighlights = saveHighlights,
       super(const HighlightsEditorLoading()) {
    load();
  }

  static bool isConfigured(ProfileHighlight slot) => switch (slot.type) {
    HighlightType.top4 => slot.movieIds.isNotEmpty,
    HighlightType.shelf => slot.shelfId != null,
    HighlightType.locadora => slot.locadoraId != null,
    HighlightType.soundtrack => slot.soundtrackUrl != null,
  };

  Future<void> load() async {
    emit(const HighlightsEditorLoading());
    final result = await _getHighlights('me');
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        final missing = HighlightType.values
            .where((type) => data.every((slot) => slot.type != type))
            .map((type) => ProfileHighlight(type: type, enabled: false));
        emit(HighlightsEditorReady([...data, ...missing]));
      case Failure(:final error):
        emit(HighlightsEditorError(error.message));
    }
  }

  void setEnabled(HighlightType type, bool enabled) =>
      _replace(type, (slot) => slot.copyWith(enabled: enabled));

  void move(int oldIndex, int newIndex) {
    final current = state;
    if (current is! HighlightsEditorReady) return;
    final slots = [...current.slots];
    slots.insert(newIndex, slots.removeAt(oldIndex));
    emit(HighlightsEditorReady(slots));
  }

  void setTopMovies(List<HighlightMovie> movies) => _replace(
    HighlightType.top4,
    (_) => ProfileHighlight(
      type: HighlightType.top4,
      enabled: movies.isNotEmpty,
      movieIds: movies.map((movie) => movie.movieId).toList(),
      movies: movies,
    ),
  );

  void setShelf(Shelf shelf) => _replace(
    HighlightType.shelf,
    (_) => ProfileHighlight(
      type: HighlightType.shelf,
      shelfId: shelf.id,
      shelf: shelf,
    ),
  );

  void setLocadora(Locadora locadora) => _replace(
    HighlightType.locadora,
    (_) => ProfileHighlight(
      type: HighlightType.locadora,
      locadoraId: locadora.id,
      locadora: locadora,
    ),
  );

  void setSoundtrack(String url) => _replace(
    HighlightType.soundtrack,
    (_) => ProfileHighlight(type: HighlightType.soundtrack, soundtrackUrl: url),
  );

  /// Saves the configured slots in the current order.
  Future<bool> save() async {
    final current = state;
    if (current is! HighlightsEditorReady || current.isSaving) return false;
    emit(HighlightsEditorReady(current.slots, isSaving: true));
    final result = await _saveHighlights(
      current.slots.where(isConfigured).toList(),
    );
    if (isClosed) return false;
    emit(HighlightsEditorReady(current.slots));
    return result is Success;
  }

  void _replace(
    HighlightType type,
    ProfileHighlight Function(ProfileHighlight) change,
  ) {
    final current = state;
    if (current is! HighlightsEditorReady) return;
    emit(
      HighlightsEditorReady([
        for (final slot in current.slots)
          slot.type == type ? change(slot) : slot,
      ]),
    );
  }
}
