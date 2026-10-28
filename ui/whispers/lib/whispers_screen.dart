import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network/social_network.dart';
import 'package:whispers/whispers_bloc.dart';
import 'package:whispers/whispers_state.dart';

/// The Sussurros list (F6.5): one row per conversation, unread ones in bold
/// with their count.
class WhispersScreen extends StatelessWidget {
  final WhispersCubit cubit;
  final ValueChanged<Conversation> onOpenConversation;

  const WhispersScreen({
    super.key,
    required this.cubit,
    required this.onOpenConversation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<WhispersCubit, WhispersState>(
        builder: (context, state) => switch (state) {
          WhispersLoading() => const Center(child: CircularProgressIndicator()),
          WhispersError() => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: l10n?.emptyStateErrorMessage ?? '',
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          WhispersSuccess(:final conversations) when conversations.isEmpty =>
            MuuvieEmptyState(
              title: l10n?.whispersEmptyTitle ?? '',
              message: l10n?.whispersEmptyMessage ?? '',
            ),
          final WhispersSuccess success => RefreshIndicator(
            onRefresh: cubit.load,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 400) cubit.loadMore();
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: success.conversations.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  final conversation = success.conversations[index];
                  return _ConversationTile(
                    conversation: conversation,
                    onTap: () => onOpenConversation(conversation),
                  );
                },
              ),
            ),
          ),
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final other = conversation.other;
    final unread = conversation.unread > 0;
    final last = conversation.lastMessage;
    final preview = last == null
        ? ''
        : last.system
        ? whisperSystemText(l10n, last)
        : last.mine
        ? l10n?.whisperYou(last.body) ?? last.body
        : last.body;

    return Semantics(
      label: unread ? l10n?.whisperUnread(conversation.unread) : null,
      child: ListTile(
        onTap: onTap,
        leading: MuuvieUserAvatar(
          url: other.avatarUrl,
          name: other.name,
          accentColor: other.accentColor,
        ),
        title: Text(
          other.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: unread ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
        subtitle: Text(
          preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: unread
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontWeight: unread ? FontWeight.w600 : null,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatRelativeTime(l10n, conversation.lastMessageAt),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (unread) ...[
              const SizedBox(height: 4),
              Badge(label: Text('${conversation.unread}')),
            ] else if (!conversation.enabled) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.lock_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Text of a system message in the user's language.
String whisperSystemText(AppLocalizations? l10n, Message message) =>
    switch (message.systemCode) {
      SystemMessageCode.mutualLost => l10n?.whisperMutualLost ?? '',
      SystemMessageCode.mutualRestored => l10n?.whisperMutualRestored ?? '',
      null => message.body,
    };
