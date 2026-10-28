/// What the live check says about the typed handle.
enum HandleStatus { unchanged, checking, available, taken, invalid }

sealed class EditProfileState {
  const EditProfileState();
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

class EditProfileReady extends EditProfileState {
  /// `#RRGGBB`, or null for the app's accent color.
  final String? accentColor;
  final HandleStatus handleStatus;
  final bool isSaving;
  final bool isScraping;

  const EditProfileReady({
    this.accentColor,
    this.handleStatus = HandleStatus.unchanged,
    this.isSaving = false,
    this.isScraping = false,
  });

  EditProfileReady copyWith({
    String? Function()? accentColor,
    HandleStatus? handleStatus,
    bool? isSaving,
    bool? isScraping,
  }) => EditProfileReady(
    accentColor: accentColor != null ? accentColor() : this.accentColor,
    handleStatus: handleStatus ?? this.handleStatus,
    isSaving: isSaving ?? this.isSaving,
    isScraping: isScraping ?? this.isScraping,
  );
}

class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);
}

/// Why saving failed.
enum EditProfileSaveError { handleTaken, invalid, other }
