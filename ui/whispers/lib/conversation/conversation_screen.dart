import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network/social_network.dart';
import 'package:whispers/conversation/conversation_bloc.dart';
import 'package:whispers/conversation/conversation_state.dart';
import 'package:whispers/whispers_screen.dart';

/// A conversation (F6.5): messages bottom-up, newest at the bottom, and the
/// input while both follow each other.
class ConversationScreen extends StatelessWidget {
  final ConversationCubit cubit;
  final String otherName;
  final TextEditingController controller;
  final VoidCallback onSend;

  const ConversationScreen({
    super.key,
    required this.cubit,
    required this.otherName,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ConversationCubit, ConversationState>(
        builder: (context, state) => switch (state) {
          ConversationLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          ConversationError() => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: l10n?.emptyStateErrorMessage ?? '',
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          final ConversationReady ready => Column(
            children: [
              Expanded(
                child: ready.messages.isEmpty
                    ? MuuvieEmptyState(
                        illustration: MuuvieIllustration.sleeping,
                        title: l10n?.whisperStart(otherName) ?? '',
                        message: ready.enabled
                            ? ''
                            : l10n?.whisperDisabled ?? '',
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          // Reversed list: the end is the top, the oldest.
                          if (notification.metrics.extentAfter < 300) {
                            cubit.loadOlder();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount:
                              ready.messages.length + (ready.hasOlder ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == ready.messages.length) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final message = ready.messages[index];
                            return message.system
                                ? _SystemMessage(message: message)
                                : _Bubble(message: message);
                          },
                        ),
                      ),
              ),
              if (ready.enabled)
                _Composer(
                  controller: controller,
                  sending: ready.isSending,
                  onSend: onSend,
                )
              else if (ready.messages.isNotEmpty)
                _DisabledNotice(text: l10n?.whisperDisabled ?? ''),
            ],
          ),
        },
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final mine = message.mine;
    final background = mine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;
    final foreground = mine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(MuuvieRadius.large),
              topRight: const Radius.circular(MuuvieRadius.large),
              bottomLeft: Radius.circular(mine ? MuuvieRadius.large : 4),
              bottomRight: Radius.circular(mine ? 4 : MuuvieRadius.large),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.body,
                style: textTheme.bodyMedium?.copyWith(color: foreground),
              ),
              const SizedBox(height: 2),
              Text(
                formatRelativeTime(l10n, message.createdAt),
                style: textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final Message message;

  const _SystemMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: MuuvieRadius.pillAll,
          ),
          child: Text(
            whisperSystemText(AppLocalizations.of(context), message),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                maxLength: whisperMaxLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n?.whisperHint,
                  counterText: '',
                  border: const OutlineInputBorder(
                    borderRadius: MuuvieRadius.largeAll,
                  ),
                  isDense: true,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => IconButton(
                tooltip: l10n?.whisperSend,
                icon: sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: sending || value.text.trim().isEmpty ? null : onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisabledNotice extends StatelessWidget {
  final String text;

  const _DisabledNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: colorScheme.surfaceContainerHighest,
        child: Row(
          children: [
            Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
