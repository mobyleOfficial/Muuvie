import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/profile.dart';

sealed class HighlightsState {
  const HighlightsState();
}

class HighlightsLoading extends HighlightsState {
  const HighlightsLoading();
}

class HighlightsSuccess extends HighlightsState {
  /// The sections to show, in order: only the enabled ones.
  final List<ProfileHighlight> highlights;

  const HighlightsSuccess(this.highlights);
}

class HighlightsError extends HighlightsState {
  final String message;

  const HighlightsError(this.message);
}

/// The Destaques tab of a profile (F5.4).
class HighlightsCubit extends Cubit<HighlightsState> {
  final String _userId;
  final GetProfileHighlights _getHighlights;

  HighlightsCubit({
    required String userId,
    required GetProfileHighlights getHighlights,
  }) : _userId = userId,
       _getHighlights = getHighlights,
       super(const HighlightsLoading()) {
    load();
  }

  Future<void> load() async {
    final result = await _getHighlights(_userId);
    if (isClosed) return;
    emit(switch (result) {
      // The owner also gets the disabled sections; the tab only shows the others.
      Success(:final data) => HighlightsSuccess(
        data.where((highlight) => highlight.enabled).toList(),
      ),
      Failure(:final error) => HighlightsError(error.message),
    });
  }
}
