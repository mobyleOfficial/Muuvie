import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_start/import_start_cubit.dart';
import 'package:imports_ui/import_start/import_start_screen.dart';
import 'package:imports_ui/import_start/import_start_state.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:imports_ui/widgets/filmow_login_webview.dart';

/// Entry of the import flow (F3.6): from the edit profile and the empty
/// "Já assisti". Filmow comes from its login or from the CSV of
/// filmow_to_letterboxd; Letterboxd from its export (zip or CSVs).
@RoutePage()
class ImportStartPage extends StatefulWidget {
  const ImportStartPage({super.key});

  @override
  State<ImportStartPage> createState() => _ImportStartPageState();
}

class _ImportStartPageState extends State<ImportStartPage> {
  late final ImportStartCubit _cubit = ImportStartCubit(
    getImports: GetIt.I<GetImports>(),
    startImport: GetIt.I<StartImport>(),
    startFileImport: GetIt.I<StartFileImport>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _startFilmow() async {
    final l10n = AppLocalizations.of(context);
    await MuuvieDialog.show<void>(
      context: context,
      title: l10n?.importFilmowWaitTitle ?? '',
      content: l10n?.importFilmowWaitMessage ?? '',
      confirmText: l10n?.importFilmowWaitConfirm ?? 'OK',
    );
    if (!mounted) return;
    final login = await Navigator.of(context).push<FilmowLoginResult>(
      MaterialPageRoute(builder: (_) => const FilmowLoginWebview()),
    );
    if (login == null || !mounted) return;
    await _cubit.startFilmow(username: login.username, cookies: login.cookies);
  }

  /// Explains where the file comes from, then opens the picker. The bytes are
  /// read in memory (`withData`), which works the same on mobile and web.
  Future<void> _startFromFile(ImportSource source) async {
    final l10n = AppLocalizations.of(context);
    final isFilmow = source == ImportSource.filmow;
    var choose = false;
    await MuuvieDialog.show<void>(
      context: context,
      title: isFilmow
          ? l10n?.importFilmowFileTitle ?? ''
          : l10n?.importLetterboxdFileTitle ?? '',
      content: isFilmow
          ? l10n?.importFilmowFileMessage
          : l10n?.importLetterboxdFileMessage,
      confirmText: l10n?.importChooseFile ?? 'OK',
      cancelText: l10n?.cancel,
      onConfirm: () => choose = true,
    );
    if (!choose || !mounted) return;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: isFilmow ? const ['csv'] : const ['csv', 'zip'],
      withData: true,
    );
    if (picked == null || !mounted) return;
    final files = [
      for (final file in picked.files)
        if (file.bytes case final bytes?)
          ImportUploadFile(name: file.name, bytes: bytes),
    ];
    if (files.isEmpty) return;
    await _cubit.startFromFiles(source: source, files: files);
  }

  void _openJob(ImportJob job) =>
      context.router.replace(ImportJobRoute(jobId: job.id));

  @override
  Widget build(BuildContext context) =>
      BlocListener<ImportStartCubit, ImportStartState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is! ImportStartSuccess) return;
          final started = state.started;
          if (started != null) {
            _openJob(started);
            return;
          }
          final failure = state.failure;
          if (failure == null) return;
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(switch (failure) {
                ImportStartFailure.inProgress => l10n?.importInProgress ?? '',
                ImportStartFailure.unreadableFile =>
                  l10n?.importFileUnreadable ?? '',
                ImportStartFailure.tooLarge => l10n?.importFileTooLarge ?? '',
                ImportStartFailure.other => l10n?.importStartError ?? '',
              }),
            ),
          );
          if (failure == ImportStartFailure.inProgress) _cubit.load();
        },
        child: ImportStartScreen(
          cubit: _cubit,
          onStartFilmow: _startFilmow,
          onStartFromFile: _startFromFile,
          onOpenJob: _openJob,
        ),
      );
}
