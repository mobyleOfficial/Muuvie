import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_network/social_network.dart';
import 'package:whispers/conversation/conversation_bloc.dart';
import 'package:whispers/conversation/conversation_screen.dart';

/// A conversation with [userId], titled with [name]. Opened from the list
/// (with [conversationId]) or from a mutual's profile (without it).
@RoutePage()
class ConversationPage extends StatefulWidget {
  final String userId;
  final String name;
  final int? conversationId;

  const ConversationPage({
    super.key,
    required this.userId,
    required this.name,
    this.conversationId,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _controller = TextEditingController();
  late final ConversationCubit _cubit = ConversationCubit(
    otherUserId: widget.userId,
    conversationId: widget.conversationId,
    getConversation: GetIt.I<GetConversation>(),
    getConversationWith: GetIt.I<GetConversationWith>(),
    getMessages: GetIt.I<GetMessages>(),
    sendWhisper: GetIt.I<SendWhisper>(),
    markRead: GetIt.I<MarkConversationRead>(),
    getFollowStatus: GetIt.I<GetFollowStatus>(),
    watchIncomingMessages: GetIt.I<WatchIncomingMessages>(),
  );

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    _controller.clear();
    final error = await _cubit.send(text);
    if (!mounted || error == null) return;
    // Give the text back so it is not lost.
    if (_controller.text.isEmpty) _controller.text = text;
    final message = switch (error) {
      AppError.tooManyRequests => l10n?.whisperRateLimited,
      AppError.forbidden => l10n?.whisperDisabled,
      _ => l10n?.whisperSendError,
    };
    messenger.showSnackBar(SnackBar(content: Text(message ?? '')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ConversationScreen(
      cubit: _cubit,
      otherName: widget.name,
      controller: _controller,
      onSend: _send,
    ),
  );
}
