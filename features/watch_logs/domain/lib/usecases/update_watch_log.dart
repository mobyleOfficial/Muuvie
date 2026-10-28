import 'package:core/core.dart';
import 'package:watch_logs_domain/models/models.dart';
import 'package:watch_logs_domain/repositories/watch_logs_repository.dart';
import 'package:watch_logs_domain/usecases/log_watch_session.dart';

class UpdateWatchLogParams {
  final int logId;
  final int? runtime;
  final WatchLogDraft draft;

  const UpdateWatchLogParams({
    required this.logId,
    this.runtime,
    required this.draft,
  });
}

/// Edits a session; it stays in its cycle (F2.3).
class UpdateWatchLog extends UseCase<UpdateWatchLogParams, Result<WatchLog>> {
  final WatchLogsRepository _repository;

  UpdateWatchLog(this._repository);

  @override
  Future<Result<WatchLog>> call([UpdateWatchLogParams? params]) async {
    final value = params!;
    if (!isValidWatchLogDraft(value.draft, value.runtime)) {
      return const Failure(AppError.badRequest);
    }
    return _repository.updateLog(value.logId, value.draft);
  }
}

/// Deletes a session; the server recomputes the progress and keeps the movie
/// on Já assisti (F2.3).
class DeleteWatchLog extends UseCase<int, Result<void>> {
  final WatchLogsRepository _repository;

  DeleteWatchLog(this._repository);

  @override
  Future<Result<void>> call([int? logId]) => _repository.deleteLog(logId!);
}
