import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:public_profile/public_profile_screen.dart';

/// Someone else's profile. [userId] takes a user id or a handle with the @,
/// which is also the path of the profile link (`https://muuvie.app/@handle`).
@RoutePage()
class PublicProfilePage extends StatelessWidget {
  final String userId;

  /// Title of the app bar while the profile loads.
  final String? displayName;

  const PublicProfilePage({
    super.key,
    @PathParam('userId') required this.userId,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) => PublicProfileScreen(userId: userId);
}
