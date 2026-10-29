import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_start/import_start_state.dart';

/// Entry of the import flow: the history and the Filmow start (F3.6).
class ImportStartCubit extends Cubit<ImportStartState> {
  final GetImports _getImports;
  final StartImport _startImport;

  ImportStartCubit({
    required GetImports getImports,
    required StartImport startImport,
  }) : _getImports = getImports,
       _startImport = startImport,
       super(const ImportStartLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const ImportStartLoading());
    final result = await _getImports(1);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => ImportStartSuccess(history: data.jobs),
      Failure(:final error) => ImportStartError(error.message),
    });
  }

  /// [username] and [cookies] come from the Filmow login; the cookies are only
  /// sent to the server for this read.
  Future<void> startFilmow({
    required String username,
    required String cookies,
  }) async {
    final current = state;
    final history = current is ImportStartSuccess
        ? current.history
        : const <ImportJob>[];
    emit(ImportStartSuccess(history: history, starting: true));
    final result = await _startImport(
      StartImportParams(
        source: ImportSource.filmow,
        username: username,
        cookies: cookies,
      ),
    );
    if (isClosed) return;
    if (result is Success) {
      Telemetry.analytics.logEvent('import_started', {'source': 'filmow'});
    }
    emit(switch (result) {
      Success(:final data) => ImportStartSuccess(
        history: [data, ...history],
        started: data,
      ),
      Failure(:final error) => ImportStartSuccess(
        history: history,
        failure: error == AppError.conflict
            ? ImportStartFailure.inProgress
            : ImportStartFailure.other,
      ),
    });
  }
}
