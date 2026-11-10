import 'dart:async';
import 'dart:typed_data';

import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_job/import_job_cubit.dart';
import 'package:imports_ui/import_job/import_job_screen.dart';
import 'package:imports_ui/import_start/import_start_cubit.dart';
import 'package:imports_ui/import_start/import_start_screen.dart';

/// Answers the history and the job with what each test sets. A file import
/// reports half its upload and then waits on [upload], so the screen can be
/// seen mid-upload.
class _FakeImportsRepository implements ImportsRepository {
  final progress = StreamController<ImportProgress>.broadcast();
  final upload = Completer<Result<ImportJob>>();
  ImportJob? job;

  @override
  Future<Result<ImportJobPage>> getImports({required int page}) async =>
      const Success(ImportJobPage(jobs: [], page: 1, hasNext: false));

  @override
  Future<Result<ImportJob>> getImport(int jobId) async => Success(job!);

  @override
  Future<Result<ImportJob>> startFileImport({
    required ImportSource source,
    required List<ImportUploadFile> files,
    void Function(double progress)? onProgress,
  }) {
    onProgress?.call(0.5);
    return upload.future;
  }

  @override
  Stream<ImportProgress> watchProgress() => progress.stream;

  Future<void> dispose() => progress.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget child) => MaterialApp(
  theme: MuuvieTheme.light,
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

ImportJob _preview(ImportPreview preview) => ImportJob(
  id: 7,
  source: ImportSource.letterboxd,
  status: ImportStatus.preview,
  inputRef: 'letterboxd-ana.zip',
  preview: preview,
  createdAt: DateTime(2026, 11, 10),
);

void main() {
  late _FakeImportsRepository repository;

  setUp(() => repository = _FakeImportsRepository());
  tearDown(() => repository.dispose());

  ImportStartCubit startCubit() => ImportStartCubit(
    getImports: GetImports(repository),
    startImport: StartImport(repository),
    startFileImport: StartFileImport(repository),
  );

  ImportJobCubit jobCubit() => ImportJobCubit(
    jobId: 7,
    getImport: GetImport(repository),
    confirmImport: ConfirmImport(repository),
    cancelImport: CancelImport(repository),
    watchImportProgress: WatchImportProgress(repository),
  );

  group('start', () {
    testWidgets('offers a file from each source, and says which was tapped', (
      tester,
    ) async {
      final tapped = <ImportSource>[];
      final cubit = startCubit();
      await tester.pumpWidget(
        _app(
          ImportStartScreen(
            cubit: cubit,
            onStartFilmow: () {},
            onStartFromFile: tapped.add,
            onOpenJob: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enviar arquivo do Filmow'));
      await tester.tap(find.text('Enviar arquivo do Letterboxd'));

      expect(tapped, [ImportSource.filmow, ImportSource.letterboxd]);
      // Material's minimum: the file buttons are at least 48 dp tall.
      final button = tester.getSize(
        find.widgetWithText(OutlinedButton, 'Enviar arquivo do Letterboxd'),
      );
      expect(button.height, greaterThanOrEqualTo(48));
      await cubit.close();
    });

    testWidgets('shows the upload progress and locks the buttons meanwhile', (
      tester,
    ) async {
      final cubit = startCubit();
      await tester.pumpWidget(
        _app(
          ImportStartScreen(
            cubit: cubit,
            onStartFilmow: () {},
            onStartFromFile: (_) {},
            onOpenJob: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      unawaited(
        cubit.startFromFiles(
          source: ImportSource.letterboxd,
          files: [ImportUploadFile(name: 'export.zip', bytes: Uint8List(4))],
        ),
      );
      // One pump delivers the cubit's states, the next draws them.
      await tester.pump();
      await tester.pump();

      expect(find.text('Enviando arquivos…'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.5);
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Enviar arquivo do Filmow'),
      );
      expect(button.onPressed, isNull);

      repository.upload.complete(const Failure(AppError.badRequest));
      // The upload's future completes in the real event loop.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await cubit.close();
    });
  });

  group('preview', () {
    testWidgets('a Filmow file shows only what it brings', (tester) async {
      repository.job = _preview(
        const ImportPreview(watched: 120, watchlist: 0, favorites: 0, logs: 0),
      );
      final cubit = jobCubit();
      await tester.pumpWidget(
        _app(
          ImportJobScreen(
            cubit: cubit,
            onReviewUnmatched: () {},
            onImportAgain: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('120'), findsOneWidget);
      expect(find.textContaining('Quero ver'), findsNothing);
      expect(find.text('Listas → estantes'), findsNothing);
      await cubit.close();
    });

    testWidgets('tags come unchecked, with a hint, and lists checked', (
      tester,
    ) async {
      repository.job = _preview(
        const ImportPreview(
          watched: 3,
          watchlist: 1,
          favorites: 0,
          logs: 4,
          reviews: 2,
          lists: [
            ImportPreviewList(
              externalId: 'https://letterboxd.com/ana/list/best/',
              title: 'Best of 2023',
              movieCount: 2,
            ),
            ImportPreviewList(
              externalId: 'tag:cinema',
              title: '#cinema',
              movieCount: 2,
              optional: true,
            ),
          ],
        ),
      );
      final cubit = jobCubit();
      await tester.pumpWidget(
        _app(
          ImportJobScreen(
            cubit: cubit,
            onReviewUnmatched: () {},
            onImportAgain: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('As tags do Letterboxd só viram estantes se você marcar.'),
        findsOneWidget,
      );
      expect(find.text('2 resenhas'), findsOneWidget);
      CheckboxListTile tile(String title) =>
          tester.widget(find.widgetWithText(CheckboxListTile, title));
      expect(tile('Best of 2023').value, isTrue);
      expect(tile('#cinema').value, isFalse);
      await cubit.close();
    });
  });
}
