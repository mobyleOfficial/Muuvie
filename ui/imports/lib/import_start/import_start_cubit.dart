import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_start/import_start_state.dart';

/// Entry of the import flow: the history, the Filmow login start (F3.6) and
/// the start from files (Filmow CSV or Letterboxd export).
class ImportStartCubit extends Cubit<ImportStartState> {
  final GetImports _getImports;
  final StartImport _startImport;
  final StartFileImport _startFileImport;

  ImportStartCubit({
    required GetImports getImports,
    required StartImport startImport,
    required StartFileImport startFileImport,
  }) : _getImports = getImports,
       _startImport = startImport,
       _startFileImport = startFileImport,
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
  }) => _start(
    source: ImportSource.filmow,
    method: 'login',
    request: () => _startImport(
      StartImportParams(
        source: ImportSource.filmow,
        username: username,
        cookies: cookies,
      ),
    ),
  );

  /// [source] is what the user picked: the files cannot tell a Filmow CSV
  /// from a Letterboxd one. The server reads them right away.
  Future<void> startFromFiles({
    required ImportSource source,
    required List<ImportUploadFile> files,
  }) => _start(
    source: source,
    method: 'file',
    request: () =>
        _startFileImport(StartFileImportParams(source: source, files: files)),
  );

  Future<void> _start({
    required ImportSource source,
    required String method,
    required Future<Result<ImportJob>> Function() request,
  }) async {
    final current = state;
    final history = current is ImportStartSuccess
        ? current.history
        : const <ImportJob>[];
    emit(ImportStartSuccess(history: history, starting: true));
    final result = await request();
    if (isClosed) return;
    if (result is Success) {
      Telemetry.analytics.logEvent('import_started', {
        'source': source.wireValue,
        'method': method,
      });
    }
    emit(switch (result) {
      Success(:final data) => ImportStartSuccess(
        history: [data, ...history],
        started: data,
      ),
      Failure(:final error, :final code) => ImportStartSuccess(
        history: history,
        // The server's code first: several file errors share the 400.
        failure: switch ((error, code)) {
          (_, 'ambiguous_file') => ImportStartFailure.ambiguousFile,
          (_, 'empty_file') => ImportStartFailure.emptyFile,
          (_, 'file_too_large') => ImportStartFailure.tooLarge,
          (AppError.conflict, _) => ImportStartFailure.inProgress,
          // From the login, a 400 is a bad username, not a file.
          (AppError.badRequest, _) when method == 'file' =>
            ImportStartFailure.unreadableFile,
          (AppError.payloadTooLarge, _) => ImportStartFailure.tooLarge,
          _ => ImportStartFailure.other,
        },
      ),
    });
  }
}
