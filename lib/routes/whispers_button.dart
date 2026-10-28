import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_network/social_network.dart';
import 'package:whispers/whispers_router.dart';

/// Sussurros in the Atts app bar (F6.6), with a badge counting the
/// conversations that have something unread. The count comes from the
/// server once and then from the `unread` WebSocket event.
class WhispersButton extends StatefulWidget {
  const WhispersButton({super.key});

  @override
  State<WhispersButton> createState() => _WhispersButtonState();
}

class _WhispersButtonState extends State<WhispersButton> {
  UnreadCount _count = UnreadCount.zero;
  StreamSubscription<UnreadCount>? _changes;

  @override
  void initState() {
    super.initState();
    _changes = GetIt.I<WatchUnreadCount>()().listen(_show);
    _load();
  }

  Future<void> _load() async {
    final result = await GetIt.I<GetUnreadCount>()();
    if (result case Success(:final data)) _show(data);
  }

  void _show(UnreadCount count) {
    if (mounted) setState(() => _count = count);
  }

  @override
  void dispose() {
    _changes?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unread = _count.conversations;

    return IconButton(
      tooltip: unread > 0
          ? l10n?.attsWhispersUnread(unread)
          : l10n?.attsWhispers,
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.mail_outline),
      ),
      onPressed: () async {
        await context.router.push(const WhispersRoute());
        _load();
      },
    );
  }
}
