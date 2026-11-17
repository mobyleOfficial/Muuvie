import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_start/import_start_cubit.dart';
import 'package:imports_ui/import_start/import_start_state.dart';

/// Answers the history and the starts with what each test sets, and records
/// what the cubit sent.
class _FakeImportsRepository implements ImportsRepository {
  Result<ImportJob> startResult = Success(_job(ImportSource.letterboxd));
  ({ImportSource source, List<ImportUploadFile> files})? uploaded;
  int fileStarts = 0;

  @override
  Future<Result<ImportJobPage>> getImports({required int page}) async =>
      const Success(ImportJobPage(jobs: [], page: 1, hasNext: false));

  @override
  Future<Result<ImportJob>> startFileImport({
    required ImportSource source,
    required List<ImportUploadFile> files,
    void Function(double progress)? onProgress,
  }) async {
    fileStarts++;
    onProgress?.call(0.5);
    onProgress?.call(1);
    uploaded = (source: source, files: files);
    return startResult;
  }

  @override
  Future<Result<ImportJob>> startImport({
    required ImportSource source,
    required String username,
    required String cookies,
  }) async => startResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ImportJob _job(ImportSource source) => ImportJob(
  id: 9,
  source: source,
  status: ImportStatus.preview,
  inputRef: 'letterboxd-ana.zip',
  createdAt: DateTime(2026, 11, 10),
);

final _zip = ImportUploadFile(
  name: 'letterboxd-ana.zip',
  bytes: Uint8List.fromList([0x50, 0x4B, 0x03, 0x04]),
);

void main() {
  late _FakeImportsRepository repository;

  ImportStartCubit build() => ImportStartCubit(
    getImports: GetImports(repository),
    startImport: StartImport(repository),
    startFileImport: StartFileImport(repository),
  );

  setUp(() => repository = _FakeImportsRepository());

  test(
    'uploads the files with the origin the user picked and opens the job',
    () async {
      final cubit = build();
      await cubit.load();

      await cubit.startFromFiles(
        source: ImportSource.letterboxd,
        files: [_zip],
      );

      expect(repository.uploaded?.source, ImportSource.letterboxd);
      expect(repository.uploaded?.files.single.name, 'letterboxd-ana.zip');
      final state = cubit.state as ImportStartSuccess;
      expect(state.started?.id, 9);
      expect(state.history.first.id, 9);
      await cubit.close();
    },
  );

  test('the upload reports its progress until the job opens', () async {
    final cubit = build();
    await cubit.load();
    final progress = <double?>[];
    final subscription = cubit.stream.listen(
      (state) => progress.add((state as ImportStartSuccess).uploadProgress),
    );

    await cubit.startFromFiles(source: ImportSource.letterboxd, files: [_zip]);
    // The cubit's stream delivers asynchronously.
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(progress, [0, 0.5, 1, null]);
    await cubit.close();
  });

  test('a file the server cannot read, or too large, says so', () async {
    final cubit = build();
    await cubit.load();

    repository.startResult = const Failure(AppError.badRequest);
    await cubit.startFromFiles(source: ImportSource.filmow, files: [_zip]);
    expect(
      (cubit.state as ImportStartSuccess).failure,
      ImportStartFailure.unreadableFile,
    );

    repository.startResult = const Failure(AppError.payloadTooLarge);
    await cubit.startFromFiles(source: ImportSource.filmow, files: [_zip]);
    expect(
      (cubit.state as ImportStartSuccess).failure,
      ImportStartFailure.tooLarge,
    );

    repository.startResult = const Failure(AppError.conflict);
    await cubit.startFromFiles(source: ImportSource.filmow, files: [_zip]);
    expect(
      (cubit.state as ImportStartSuccess).failure,
      ImportStartFailure.inProgress,
    );
    await cubit.close();
  });

  test('the server code tells the file errors apart', () async {
    final cubit = build();
    await cubit.load();

    Future<ImportStartFailure?> failureFor(String code) async {
      repository.startResult = Failure(AppError.badRequest, code: code);
      await cubit.startFromFiles(
        source: ImportSource.letterboxd,
        files: [_zip],
      );
      return (cubit.state as ImportStartSuccess).failure;
    }

    expect(
      await failureFor('ambiguous_file'),
      ImportStartFailure.ambiguousFile,
    );
    expect(await failureFor('empty_file'), ImportStartFailure.emptyFile);
    expect(
      await failureFor('unsupported_file'),
      ImportStartFailure.unreadableFile,
    );
    await cubit.close();
  });

  test('a 400 from the Filmow login is not blamed on a file', () async {
    final cubit = build();
    await cubit.load();
    repository.startResult = const Failure(AppError.badRequest);

    await cubit.startFilmow(username: 'ana', cookies: '');

    expect(
      (cubit.state as ImportStartSuccess).failure,
      ImportStartFailure.other,
    );
    await cubit.close();
  });

  test('no files never reach the server', () async {
    final result = await StartFileImport(repository)(
      const StartFileImportParams(source: ImportSource.filmow, files: []),
    );

    expect(result, isA<Failure<ImportJob>>());
    expect(repository.fileStarts, 0);
  });
}
