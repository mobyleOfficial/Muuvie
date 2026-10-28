import 'dart:async';

import 'package:auth/auth.dart' show Logout;
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/edit_profile/edit_profile_state.dart';

/// Edits the own profile on the v1 API (F5.3). The handle is checked while the
/// user types, after a short pause.
class EditProfileCubit extends Cubit<EditProfileState> {
  static const _handleCheckDelay = Duration(milliseconds: 400);

  final SaveMyProfile _saveMyProfile;
  final CheckHandleAvailability _checkHandle;
  final Logout _logout;
  final String? _currentHandle;

  StreamSubscription<UserProfile>? _profileSubscription;
  Timer? _handleTimer;

  EditProfileCubit({
    required SaveMyProfile saveMyProfile,
    required CheckHandleAvailability checkHandle,
    required ObserveUserProfile observeUserProfile,
    required Logout logout,
    required ProfileDetails profile,
  }) : _saveMyProfile = saveMyProfile,
       _checkHandle = checkHandle,
       _logout = logout,
       _currentHandle = profile.handle,
       super(
         EditProfileReady(
           accentColor: profile.accentColor,
           isScraping: profile.isScraping,
         ),
       ) {
    // The import button waits while an import runs.
    _profileSubscription = observeUserProfile().listen((legacy) {
      _update((ready) => ready.copyWith(isScraping: legacy.isScraping));
    }, onError: (_) {});
  }

  void onAccentColorChanged(String? hex) =>
      _update((ready) => ready.copyWith(accentColor: () => hex));

  void onHandleChanged(String value) {
    _handleTimer?.cancel();
    final handle = HandleAvailability.normalize(value);
    if (handle.isEmpty || handle == _currentHandle) {
      _update((ready) => ready.copyWith(handleStatus: HandleStatus.unchanged));
      return;
    }
    if (!HandleAvailability.format.hasMatch(handle)) {
      _update((ready) => ready.copyWith(handleStatus: HandleStatus.invalid));
      return;
    }
    _update((ready) => ready.copyWith(handleStatus: HandleStatus.checking));
    _handleTimer = Timer(_handleCheckDelay, () => _check(handle));
  }

  Future<void> _check(String handle) async {
    final result = await _checkHandle(handle);
    if (isClosed) return;
    final status = switch (result) {
      Success(:final data) when data.available => HandleStatus.available,
      Success(:final data) when data.problem == HandleProblem.taken =>
        HandleStatus.taken,
      Success() => HandleStatus.invalid,
      // Offline: the save answers for real.
      Failure() => HandleStatus.unchanged,
    };
    _update((ready) => ready.copyWith(handleStatus: status));
  }

  /// Saves and returns null, or the reason it failed.
  Future<EditProfileSaveError?> save(ProfileDraft draft) async {
    final current = state;
    if (current is! EditProfileReady || current.isSaving) {
      return EditProfileSaveError.other;
    }
    if (current.handleStatus == HandleStatus.invalid) {
      return EditProfileSaveError.invalid;
    }
    if (current.handleStatus == HandleStatus.taken) {
      return EditProfileSaveError.handleTaken;
    }
    emit(current.copyWith(isSaving: true));
    final result = await _saveMyProfile(
      ProfileDraft(
        displayName: draft.displayName,
        handle: draft.handle,
        pronouns: draft.pronouns,
        bio: draft.bio,
        links: draft.links,
        accentColor: current.accentColor,
        avatarUrl: draft.avatarUrl,
        bannerUrl: draft.bannerUrl,
      ),
    );
    if (isClosed) return null;
    _update((ready) => ready.copyWith(isSaving: false));
    return switch (result) {
      Success() => null,
      Failure(:final error) when error == AppError.conflict => () {
        _update((ready) => ready.copyWith(handleStatus: HandleStatus.taken));
        return EditProfileSaveError.handleTaken;
      }(),
      Failure(:final error) when error == AppError.badRequest =>
        EditProfileSaveError.invalid,
      Failure() => EditProfileSaveError.other,
    };
  }

  /// Ends the session; the main screen reacts by leaving the logged-in tabs.
  Future<void> logout() async {
    emit(const EditProfileLoading());
    await _logout();
  }

  void _update(EditProfileReady Function(EditProfileReady) change) {
    final current = state;
    if (current is EditProfileReady && !isClosed) emit(change(current));
  }

  @override
  Future<void> close() {
    _handleTimer?.cancel();
    _profileSubscription?.cancel();
    return super.close();
  }
}
