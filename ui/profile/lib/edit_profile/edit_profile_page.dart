import 'package:auth/auth.dart' show Logout;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/edit_profile/edit_profile_bloc.dart';
import 'package:profile_ui/edit_profile/edit_profile_screen.dart';

/// Edits the own profile (F5.3). Pops `true` once saved.
@RoutePage()
class EditProfilePage extends StatefulWidget {
  final ProfileDetails profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final EditProfileCubit _cubit = EditProfileCubit(
    saveMyProfile: GetIt.I<SaveMyProfile>(),
    checkHandle: GetIt.I<CheckHandleAvailability>(),
    observeUserProfile: GetIt.I<ObserveUserProfile>(),
    logout: GetIt.I<Logout>(),
    profile: widget.profile,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EditProfileScreen(
    cubit: _cubit,
    profile: widget.profile,
    onImportFilmow: () => context.router.root.push(const ImportStartRoute()),
  );
}
