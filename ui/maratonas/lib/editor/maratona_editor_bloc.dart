import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';

sealed class MaratonaEditorState {
  const MaratonaEditorState();
}

class MaratonaEditorLoading extends MaratonaEditorState {
  const MaratonaEditorLoading();
}

class MaratonaEditorError extends MaratonaEditorState {
  const MaratonaEditorError();
}

/// Ready to edit. [maratona] is null when creating; [templates] are offered
/// before starting a new one (F7.9).
class MaratonaEditorReady extends MaratonaEditorState {
  final Maratona? maratona;
  final List<MaratonaTemplate> templates;
  final bool saving;

  const MaratonaEditorReady({
    this.maratona,
    this.templates = const [],
    this.saving = false,
  });

  /// After the start only the texts, logo, color, link and prizes change.
  bool get started => maratona?.status == MaratonaStatus.active;

  MaratonaEditorReady copyWith({bool? saving}) => MaratonaEditorReady(
    maratona: maratona,
    templates: templates,
    saving: saving ?? this.saving,
  );
}

/// Loads what the editor (F7.7) starts from and saves the maratona.
class MaratonaEditorCubit extends Cubit<MaratonaEditorState> {
  /// Null to create a new maratona.
  final String? slug;
  final GetMaratona _getMaratona;
  final GetMaratonaTemplates _getTemplates;
  final CheckMaratonaSlug _checkSlug;
  final SaveMaratona _saveMaratona;

  MaratonaEditorCubit({
    this.slug,
    required GetMaratona getMaratona,
    required GetMaratonaTemplates getTemplates,
    required CheckMaratonaSlug checkSlug,
    required SaveMaratona saveMaratona,
  }) : _getMaratona = getMaratona,
       _getTemplates = getTemplates,
       _checkSlug = checkSlug,
       _saveMaratona = saveMaratona,
       super(const MaratonaEditorLoading());

  Future<void> load() async {
    emit(const MaratonaEditorLoading());
    final current = slug;
    if (current != null) {
      final result = await _getMaratona(current);
      if (isClosed) return;
      emit(switch (result) {
        Success(:final data) => MaratonaEditorReady(maratona: data),
        Failure() => const MaratonaEditorError(),
      });
      return;
    }
    // Templates are a shortcut: without them the editor still starts empty.
    final templates = await _getTemplates();
    if (isClosed) return;
    emit(
      MaratonaEditorReady(
        templates: switch (templates) {
          Success(:final data) => data,
          Failure() => const [],
        },
      ),
    );
  }

  Future<SlugAvailability?> checkSlug(String value) async {
    final result = await _checkSlug(value);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  /// Saves the form; answers the saved maratona.
  Future<Result<Maratona>> save(MaratonaForm form) async {
    final current = state;
    if (current is MaratonaEditorReady) emit(current.copyWith(saving: true));
    final result = await _saveMaratona(
      SaveMaratonaParams(slug: slug, form: form),
    );
    final latest = state;
    if (!isClosed && latest is MaratonaEditorReady) {
      emit(latest.copyWith(saving: false));
    }
    return result;
  }
}
