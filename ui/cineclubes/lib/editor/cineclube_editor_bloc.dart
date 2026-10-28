import 'package:cineclubes/cineclubes.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CineClubeEditorState {
  const CineClubeEditorState();
}

class CineClubeEditorLoading extends CineClubeEditorState {
  const CineClubeEditorLoading();
}

class CineClubeEditorError extends CineClubeEditorState {
  const CineClubeEditorError();
}

/// Ready to edit. [cineclube] is null when creating.
class CineClubeEditorReady extends CineClubeEditorState {
  final CineClube? cineclube;
  final bool saving;

  const CineClubeEditorReady({this.cineclube, this.saving = false});

  CineClubeEditorReady copyWith({bool? saving}) =>
      CineClubeEditorReady(cineclube: cineclube, saving: saving ?? this.saving);
}

/// Loads the CineClube to edit (F8.5) and saves it.
class CineClubeEditorCubit extends Cubit<CineClubeEditorState> {
  /// Null to create a new CineClube.
  final String? slug;
  final GetCineClube _getCineClube;
  final CheckCineClubeSlug _checkSlug;
  final SaveCineClube _saveCineClube;

  CineClubeEditorCubit({
    this.slug,
    required GetCineClube getCineClube,
    required CheckCineClubeSlug checkSlug,
    required SaveCineClube saveCineClube,
  }) : _getCineClube = getCineClube,
       _checkSlug = checkSlug,
       _saveCineClube = saveCineClube,
       super(const CineClubeEditorLoading());

  Future<void> load() async {
    final current = slug;
    if (current == null) {
      emit(const CineClubeEditorReady());
      return;
    }
    emit(const CineClubeEditorLoading());
    final result = await _getCineClube(current);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => CineClubeEditorReady(cineclube: data),
      Failure() => const CineClubeEditorError(),
    });
  }

  Future<CineClubeSlug?> checkSlug(String value) async {
    final result = await _checkSlug(value);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<Result<CineClube>> save(CineClubeForm form) async {
    final current = state;
    if (current is CineClubeEditorReady) emit(current.copyWith(saving: true));
    final result = await _saveCineClube(
      SaveCineClubeParams(slug: slug, form: form),
    );
    final latest = state;
    if (!isClosed && latest is CineClubeEditorReady) {
      emit(latest.copyWith(saving: false));
    }
    return result;
  }
}
