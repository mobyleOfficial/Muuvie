import 'package:core/core.dart';
import 'package:imports_domain/models/models.dart';
import 'package:imports_domain/repositories/imports_repository.dart';

class StartFileImportParams {
  final ImportSource source;
  final List<ImportUploadFile> files;

  const StartFileImportParams({required this.source, required this.files});
}

/// Imports from files instead of the Filmow login: the user picks the origin,
/// because a Filmow CSV and a Letterboxd import CSV look the same.
class StartFileImport
    extends UseCase<StartFileImportParams, Result<ImportJob>> {
  final ImportsRepository _repository;

  StartFileImport(this._repository);

  @override
  Future<Result<ImportJob>> call([StartFileImportParams? params]) async {
    final value = params!;
    if (value.files.isEmpty) return const Failure(AppError.badRequest);
    return _repository.startFileImport(
      source: value.source,
      files: value.files,
    );
  }
}
