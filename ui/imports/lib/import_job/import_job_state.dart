import 'package:core/core.dart';
import 'package:imports/imports.dart';

sealed class ImportJobState {
  const ImportJobState();
}

class ImportJobLoading extends ImportJobState {
  const ImportJobLoading();
}

class ImportJobError extends ImportJobState {
  final String message;

  const ImportJobError(this.message);
}

class ImportJobSuccess extends ImportJobState {
  final ImportJob job;

  /// Lists picked on the preview, by external id. All of them by default.
  final Set<String> selectedLists;
  final ContentVisibility visibility;

  /// Confirming or cancelling.
  final bool submitting;

  /// The last confirm or cancel failed; the screen shows a snackbar once.
  final bool actionFailed;

  const ImportJobSuccess({
    required this.job,
    this.selectedLists = const {},
    this.visibility = ContentVisibility.defaultValue,
    this.submitting = false,
    this.actionFailed = false,
  });

  ImportJobSuccess copyWith({
    ImportJob? job,
    Set<String>? selectedLists,
    ContentVisibility? visibility,
    bool? submitting,
    bool actionFailed = false,
  }) => ImportJobSuccess(
    job: job ?? this.job,
    selectedLists: selectedLists ?? this.selectedLists,
    visibility: visibility ?? this.visibility,
    submitting: submitting ?? this.submitting,
    actionFailed: actionFailed,
  );
}
