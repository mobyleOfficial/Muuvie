import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_job/import_job_cubit.dart';
import 'package:imports_ui/import_job/import_job_state.dart';

/// Answers the job with the current [job] and records the confirm and cancel calls.
class _FakeImportsRepository implements ImportsRepository {
  final progress = StreamController<ImportProgress>.broadcast();
  late ImportJob job;
  int gets = 0;
  ({List<String>? lists, ContentVisibility visibility})? confirmed;
  bool cancelled = false;

  @override
  Future<Result<ImportJob>> getImport(int jobId) async {
    gets++;
    return Success(job);
  }

  @override
  Future<Result<ImportJob>> confirmImport(
    int jobId, {
    List<String>? listsToImport,
    required ContentVisibility visibility,
  }) async {
    confirmed = (lists: listsToImport, visibility: visibility);
    return Success(_job(ImportStatus.importing));
  }

  @override
  Future<Result<ImportJob>> cancelImport(int jobId) async {
    cancelled = true;
    return Success(_job(ImportStatus.cancelled));
  }

  @override
  Stream<ImportProgress> watchProgress() => progress.stream;

  Future<void> dispose() => progress.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ImportJob _job(ImportStatus status, {bool withPreview = true}) => ImportJob(
  id: 7,
  source: ImportSource.filmow,
  status: status,
  inputRef: 'ana',
  preview: withPreview
      ? const ImportPreview(
          watched: 10,
          watchlist: 2,
          favorites: 0,
          logs: 1,
          lists: [
            ImportPreviewList(externalId: 'L1', title: 'Noir', movieCount: 3),
            ImportPreviewList(
              externalId: 'L2',
              title: 'Hitchcock',
              movieCount: 5,
            ),
          ],
        )
      : null,
  createdAt: DateTime(2026, 10, 26),
);

void main() {
  late _FakeImportsRepository repository;

  ImportJobCubit build() => ImportJobCubit(
    jobId: 7,
    getImport: GetImport(repository),
    confirmImport: ConfirmImport(repository),
    cancelImport: CancelImport(repository),
    watchImportProgress: WatchImportProgress(repository),
  );

  setUp(() => repository = _FakeImportsRepository());
  tearDown(() => repository.dispose());

  test('every list starts selected once the preview arrives', () async {
    repository.job = _job(ImportStatus.reading, withPreview: false);
    final cubit = build();
    await Future<void>.delayed(Duration.zero);
    expect((cubit.state as ImportJobSuccess).selectedLists, isEmpty);

    repository.job = _job(ImportStatus.preview);
    repository.progress.add(
      const ImportProgress(jobId: 7, status: ImportStatus.preview),
    );
    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as ImportJobSuccess).selectedLists, {'L1', 'L2'});
    await cubit.close();
  });

  test('confirm sends the lists left selected and the visibility', () async {
    repository.job = _job(ImportStatus.preview);
    final cubit = build();
    await Future<void>.delayed(Duration.zero);

    cubit
      ..toggleList('L2')
      ..setVisibility(ContentVisibility.mutual);
    await cubit.confirm();

    expect(repository.confirmed?.lists, ['L1']);
    expect(repository.confirmed?.visibility, ContentVisibility.mutual);
    expect(
      (cubit.state as ImportJobSuccess).job.status,
      ImportStatus.importing,
    );
    await cubit.close();
  });

  test('cancel moves the job to cancelled', () async {
    repository.job = _job(ImportStatus.preview);
    final cubit = build();
    await Future<void>.delayed(Duration.zero);

    await cubit.cancel();

    expect(repository.cancelled, isTrue);
    expect(
      (cubit.state as ImportJobSuccess).job.status,
      ImportStatus.cancelled,
    );
    await cubit.close();
  });

  test('pushes for other jobs are ignored', () async {
    repository.job = _job(ImportStatus.done);
    final cubit = build();
    await Future<void>.delayed(Duration.zero);
    final loads = repository.gets;

    repository.progress.add(
      const ImportProgress(jobId: 8, status: ImportStatus.done),
    );
    await Future<void>.delayed(Duration.zero);

    expect(repository.gets, loads);
    await cubit.close();
  });
}
