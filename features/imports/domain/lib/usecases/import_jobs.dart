import 'package:core/core.dart';
import 'package:imports_domain/models/models.dart';
import 'package:imports_domain/repositories/imports_repository.dart';

class StartImportParams {
  final ImportSource source;
  final String username;
  final String cookies;

  const StartImportParams({
    required this.source,
    required this.username,
    this.cookies = '',
  });
}

/// Starts reading the source (F3.1). The server answers 409 while another
/// import from the same source is running.
class StartImport extends UseCase<StartImportParams, Result<ImportJob>> {
  final ImportsRepository _repository;

  StartImport(this._repository);

  @override
  Future<Result<ImportJob>> call([StartImportParams? params]) async {
    final value = params!;
    final username = value.username.trim();
    if (username.isEmpty) return const Failure(AppError.badRequest);
    return _repository.startImport(
      source: value.source,
      username: username,
      cookies: value.cookies,
    );
  }
}

class GetImport extends UseCase<int, Result<ImportJob>> {
  final ImportsRepository _repository;

  GetImport(this._repository);

  @override
  Future<Result<ImportJob>> call([int? jobId]) => _repository.getImport(jobId!);
}

/// The user's imports, newest first (F3.6).
class GetImports extends UseCase<int, Result<ImportJobPage>> {
  final ImportsRepository _repository;

  GetImports(this._repository);

  @override
  Future<Result<ImportJobPage>> call([int? page]) =>
      _repository.getImports(page: page ?? 1);
}

class ConfirmImportParams {
  final int jobId;

  /// External ids of the lists to bring; null brings all of them.
  final List<String>? listsToImport;
  final ContentVisibility visibility;

  const ConfirmImportParams({
    required this.jobId,
    this.listsToImport,
    this.visibility = ContentVisibility.defaultValue,
  });
}

/// Accepts the preview (F3.5); writing goes on in the background.
class ConfirmImport extends UseCase<ConfirmImportParams, Result<ImportJob>> {
  final ImportsRepository _repository;

  ConfirmImport(this._repository);

  @override
  Future<Result<ImportJob>> call([ConfirmImportParams? params]) {
    final value = params!;
    return _repository.confirmImport(
      value.jobId,
      listsToImport: value.listsToImport,
      visibility: value.visibility,
    );
  }
}

/// Cancels before anything is written: cancelling on the preview writes nothing.
class CancelImport extends UseCase<int, Result<ImportJob>> {
  final ImportsRepository _repository;

  CancelImport(this._repository);

  @override
  Future<Result<ImportJob>> call([int? jobId]) =>
      _repository.cancelImport(jobId!);
}

/// Server pushes for running jobs.
class WatchImportProgress {
  final ImportsRepository _repository;

  WatchImportProgress(this._repository);

  Stream<ImportProgress> call() => _repository.watchProgress();
}
