import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_job/import_job_state.dart';

/// One import job: reading, preview, writing and the final report (F3.5, F3.6).
/// It reloads on each WebSocket push and also polls while the job runs, in case
/// the socket is down.
class ImportJobCubit extends Cubit<ImportJobState> {
  static const pollInterval = Duration(seconds: 4);

  final int jobId;
  final GetImport _getImport;
  final ConfirmImport _confirmImport;
  final CancelImport _cancelImport;

  StreamSubscription<ImportProgress>? _progressSubscription;
  Timer? _pollTimer;

  ImportJobCubit({
    required this.jobId,
    required GetImport getImport,
    required ConfirmImport confirmImport,
    required CancelImport cancelImport,
    required WatchImportProgress watchImportProgress,
  }) : _getImport = getImport,
       _confirmImport = confirmImport,
       _cancelImport = cancelImport,
       super(const ImportJobLoading()) {
    _progressSubscription = watchImportProgress()
        .where((progress) => progress.jobId == jobId)
        .listen((_) => refresh());
    load();
  }

  Future<void> load() async {
    emit(const ImportJobLoading());
    await refresh();
  }

  /// Reloads the job, keeping the choices made on the preview.
  Future<void> refresh() async {
    final result = await _getImport(jobId);
    if (isClosed) return;
    final current = state;
    switch (result) {
      case Success(:final data):
        // Every list starts selected, once the preview arrives.
        final previewArrived =
            current is! ImportJobSuccess || current.job.preview == null;
        emit(switch (current) {
          ImportJobSuccess() when !previewArrived => current.copyWith(
            job: data,
          ),
          ImportJobSuccess() => current.copyWith(
            job: data,
            selectedLists: _allLists(data),
          ),
          _ => ImportJobSuccess(job: data, selectedLists: _allLists(data)),
        });
        _schedulePoll(data.status);
      case Failure(:final error):
        if (current is! ImportJobSuccess) emit(ImportJobError(error.message));
    }
  }

  void toggleList(String externalId) {
    final current = state;
    if (current is! ImportJobSuccess) return;
    final selected = {...current.selectedLists};
    if (!selected.remove(externalId)) selected.add(externalId);
    emit(current.copyWith(selectedLists: selected));
  }

  void setVisibility(ContentVisibility visibility) {
    final current = state;
    if (current is! ImportJobSuccess) return;
    emit(current.copyWith(visibility: visibility));
  }

  Future<void> confirm() async {
    final current = state;
    if (current is! ImportJobSuccess || current.submitting) return;
    emit(current.copyWith(submitting: true));
    final result = await _confirmImport(
      ConfirmImportParams(
        jobId: jobId,
        listsToImport: current.selectedLists.toList(),
        visibility: current.visibility,
      ),
    );
    _afterAction(result);
  }

  /// Only before writing: nothing is saved.
  Future<void> cancel() async {
    final current = state;
    if (current is! ImportJobSuccess || current.submitting) return;
    emit(current.copyWith(submitting: true));
    _afterAction(await _cancelImport(jobId));
  }

  void _afterAction(Result<ImportJob> result) {
    final current = state;
    if (isClosed || current is! ImportJobSuccess) return;
    switch (result) {
      case Success(:final data):
        emit(current.copyWith(job: data, submitting: false));
        _schedulePoll(data.status);
      case Failure():
        emit(current.copyWith(submitting: false, actionFailed: true));
    }
  }

  Set<String> _allLists(ImportJob job) => {
    for (final list in job.preview?.lists ?? const <ImportPreviewList>[])
      list.externalId,
  };

  void _schedulePoll(ImportStatus status) {
    _pollTimer?.cancel();
    if (status.isRunning) _pollTimer = Timer(pollInterval, refresh);
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _progressSubscription?.cancel();
    return super.close();
  }
}
