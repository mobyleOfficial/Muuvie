import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:profile_ui/member/member_profile_view.dart';

/// The profile of another user (F5.5), with the same header and tabs as mine.
class PublicProfileScreen extends StatelessWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final inTabContext = TabIndexScope.find(context) != null;

    return Scaffold(
      appBar: inTabContext ? null : AppBar(),
      body: MemberProfileView(userId: userId),
    );
  }
}
