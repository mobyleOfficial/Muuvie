import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/comments/thread_comments_cubit.dart';
import 'package:watch_logs_ui/widgets/spoiler_text.dart';

/// Comments of a session or a rating in a bottom sheet (F2.8).
class ThreadCommentsSheet extends StatefulWidget {
  final CommentTarget target;
  final int targetId;

  /// The current user owns the session or rating, so they can delete any comment.
  final bool ownsTarget;

  const ThreadCommentsSheet({
    super.key,
    required this.target,
    required this.targetId,
    this.ownsTarget = false,
  });

  static Future<void> show(
    BuildContext context, {
    required CommentTarget target,
    required int targetId,
    bool ownsTarget = false,
  }) => MuuvieBottomSheet.show<void>(
    context: context,
    builder: (_) => ThreadCommentsSheet(
      target: target,
      targetId: targetId,
      ownsTarget: ownsTarget,
    ),
  );

  @override
  State<ThreadCommentsSheet> createState() => _ThreadCommentsSheetState();
}

class _ThreadCommentsSheetState extends State<ThreadCommentsSheet> {
  late final ThreadCommentsCubit _cubit = ThreadCommentsCubit(
    target: widget.target,
    targetId: widget.targetId,
    getComments: GetIt.I<GetThreadComments>(),
    postComment: GetIt.I<PostThreadComment>(),
    deleteComment: GetIt.I<DeleteThreadComment>(),
  );
  final _controller = TextEditingController();
  bool _hasSpoiler = false;

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _send() async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context)?.threadCommentError ?? '';
    if (!await AuthGate.check(context)) return;
    if (await _cubit.send(_controller.text, hasSpoiler: _hasSpoiler)) {
      _controller.clear();
      setState(() => _hasSpoiler = false);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                header: true,
                child: Text(
                  l10n?.threadCommentsTitle ?? '',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ThreadCommentsCubit, ThreadCommentsState>(
                bloc: _cubit,
                builder: (context, state) => switch (state) {
                  ThreadCommentsLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ThreadCommentsError(:final message) => MuuvieEmptyState(
                    illustration: null,
                    title: l10n?.emptyStateErrorTitle ?? '',
                    message: message,
                    action: _cubit.load,
                    actionLabel: l10n?.emptyStateRetry ?? '',
                  ),
                  ThreadCommentsSuccess(:final comments)
                      when comments.isEmpty =>
                    Center(child: Text(l10n?.threadCommentsEmpty ?? '')),
                  ThreadCommentsSuccess(:final comments, :final hasNext) =>
                    ListView.builder(
                      itemCount: comments.length + (hasNext ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == comments.length) {
                          _cubit.loadMore();
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: comment.authorAvatarUrl != null
                                ? NetworkImage(comment.authorAvatarUrl!)
                                : null,
                            child: comment.authorAvatarUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(comment.authorName),
                          subtitle: comment.hasSpoiler
                              ? SpoilerText(text: comment.body)
                              : Text(comment.body),
                          trailing: comment.self || widget.ownsTarget
                              ? IconButton(
                                  tooltip: l10n?.threadCommentDelete ?? '',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _cubit.delete(comment.id),
                                )
                              : null,
                        );
                      },
                    ),
                },
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  8,
                  8 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLength: PostThreadComment.maxLength,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n?.threadCommentHint ?? '',
                          counterText: '',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n?.watchLogSpoiler ?? '',
                      isSelected: _hasSpoiler,
                      icon: const Icon(Icons.visibility_off_outlined),
                      selectedIcon: const Icon(Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _hasSpoiler = !_hasSpoiler),
                    ),
                    BlocBuilder<ThreadCommentsCubit, ThreadCommentsState>(
                      bloc: _cubit,
                      builder: (context, state) => IconButton(
                        tooltip: l10n?.threadCommentSend ?? '',
                        icon: const Icon(Icons.send),
                        onPressed:
                            state is ThreadCommentsSuccess && !state.isSending
                            ? _send
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
