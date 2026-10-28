import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_logs/watch_logs.dart';

sealed class ThreadCommentsState {
  const ThreadCommentsState();
}

class ThreadCommentsLoading extends ThreadCommentsState {
  const ThreadCommentsLoading();
}

class ThreadCommentsError extends ThreadCommentsState {
  final String message;

  const ThreadCommentsError(this.message);
}

class ThreadCommentsSuccess extends ThreadCommentsState {
  final List<ThreadComment> comments;
  final int page;
  final bool hasNext;
  final bool isSending;

  const ThreadCommentsSuccess({
    required this.comments,
    required this.page,
    required this.hasNext,
    this.isSending = false,
  });

  ThreadCommentsSuccess copyWith({
    List<ThreadComment>? comments,
    int? page,
    bool? hasNext,
    bool? isSending,
  }) => ThreadCommentsSuccess(
    comments: comments ?? this.comments,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    isSending: isSending ?? this.isSending,
  );
}

/// Comments of one session or rating (F2.8).
class ThreadCommentsCubit extends Cubit<ThreadCommentsState> {
  final CommentTarget target;
  final int targetId;
  final GetThreadComments _getComments;
  final PostThreadComment _postComment;
  final DeleteThreadComment _deleteComment;
  bool _loadingMore = false;

  ThreadCommentsCubit({
    required this.target,
    required this.targetId,
    required GetThreadComments getComments,
    required PostThreadComment postComment,
    required DeleteThreadComment deleteComment,
  }) : _getComments = getComments,
       _postComment = postComment,
       _deleteComment = deleteComment,
       super(const ThreadCommentsLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const ThreadCommentsLoading());
    final result = await _getComments(
      GetThreadCommentsParams(target: target, targetId: targetId),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => ThreadCommentsSuccess(
        comments: data.comments,
        page: data.page,
        hasNext: data.hasNext,
      ),
      Failure(:final error) => ThreadCommentsError(error.message),
    });
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ThreadCommentsSuccess || !current.hasNext || _loadingMore) {
      return;
    }
    _loadingMore = true;
    final result = await _getComments(
      GetThreadCommentsParams(
        target: target,
        targetId: targetId,
        page: current.page + 1,
      ),
    );
    _loadingMore = false;
    if (isClosed) return;
    if (result case Success(:final data)) {
      emit(
        current.copyWith(
          comments: [...current.comments, ...data.comments],
          page: data.page,
          hasNext: data.hasNext,
        ),
      );
    }
  }

  /// Returns false when sending failed.
  Future<bool> send(String body, {bool hasSpoiler = false}) async {
    final current = state;
    if (current is! ThreadCommentsSuccess || current.isSending) return false;
    emit(current.copyWith(isSending: true));
    final result = await _postComment(
      PostThreadCommentParams(
        target: target,
        targetId: targetId,
        body: body,
        hasSpoiler: hasSpoiler,
      ),
    );
    if (isClosed) return false;
    switch (result) {
      case Success(:final data):
        emit(
          current.copyWith(
            comments: [...current.comments, data],
            isSending: false,
          ),
        );
        return true;
      case Failure():
        emit(current.copyWith(isSending: false));
        return false;
    }
  }

  Future<bool> delete(int commentId) async {
    final current = state;
    if (current is! ThreadCommentsSuccess) return false;
    final result = await _deleteComment(commentId);
    if (isClosed || result is Failure) return false;
    emit(
      current.copyWith(
        comments: current.comments.where((c) => c.id != commentId).toList(),
      ),
    );
    return true;
  }
}
