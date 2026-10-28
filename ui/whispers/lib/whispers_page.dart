import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_network/social_network.dart';
import 'package:whispers/whispers_bloc.dart';
import 'package:whispers/whispers_router.dart';
import 'package:whispers/whispers_screen.dart';

/// The Sussurros (F6.5), opened from the Atts app bar.
@RoutePage()
class WhispersPage extends StatefulWidget {
  const WhispersPage({super.key});

  @override
  State<WhispersPage> createState() => _WhispersPageState();
}

class _WhispersPageState extends State<WhispersPage> {
  late final WhispersCubit _cubit = WhispersCubit(
    getConversations: GetIt.I<GetConversations>(),
    watchIncomingMessages: GetIt.I<WatchIncomingMessages>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _open(Conversation conversation) async {
    _cubit.markRead(conversation.id);
    await context.router.push(
      ConversationRoute(
        userId: conversation.other.id,
        name: conversation.other.name,
        conversationId: conversation.id,
      ),
    );
    // Messages sent there already moved it to the top; the order and the
    // read state are confirmed by the server on the way back.
    if (mounted) _cubit.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: WhispersScreen(cubit: _cubit, onOpenConversation: _open),
  );
}
