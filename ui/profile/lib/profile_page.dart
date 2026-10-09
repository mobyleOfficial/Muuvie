import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/profile_bloc.dart';
import 'package:profile_ui/profile_screen.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileCubit _cubit = ProfileCubit(
    getUserProfile: GetIt.I<ObserveUserProfile>(),
    refreshUserProfile: GetIt.I<RefreshUserProfile>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ProfileScreen(cubit: _cubit, getMovieReviews: GetIt.I<GetMovieReviews>());
}
