import 'package:core/core.dart';
import 'package:watch_logs_domain/models/models.dart';
import 'package:watch_logs_domain/repositories/watch_logs_repository.dart';

class GetThreadCommentsParams {
  final CommentTarget target;
  final int targetId;
  final int page;

  const GetThreadCommentsParams({
    required this.target,
    required this.targetId,
    this.page = 1,
  });
}

/// Comments of a session or a rating, oldest first (F2.8).
class GetThreadComments
    extends UseCase<GetThreadCommentsParams, Result<CommentPage>> {
  final WatchLogsRepository _repository;

  GetThreadComments(this._repository);

  @override
  Future<Result<CommentPage>> call([GetThreadCommentsParams? params]) {
    final value = params!;
    return _repository.getComments(
      target: value.target,
      targetId: value.targetId,
      page: value.page,
    );
  }
}

class PostThreadCommentParams {
  final CommentTarget target;
  final int targetId;
  final String body;
  final bool hasSpoiler;
  final int? parentId;

  const PostThreadCommentParams({
    required this.target,
    required this.targetId,
    required this.body,
    this.hasSpoiler = false,
    this.parentId,
  });
}

class PostThreadComment
    extends UseCase<PostThreadCommentParams, Result<ThreadComment>> {
  static const maxLength = 2000;

  final WatchLogsRepository _repository;

  PostThreadComment(this._repository);

  @override
  Future<Result<ThreadComment>> call([PostThreadCommentParams? params]) async {
    final value = params!;
    final body = value.body.trim();
    if (body.isEmpty || body.length > maxLength) {
      return const Failure(AppError.badRequest);
    }
    return _repository.postComment(
      target: value.target,
      targetId: value.targetId,
      body: body,
      hasSpoiler: value.hasSpoiler,
      parentId: value.parentId,
    );
  }
}

/// The author or the owner of the session or rating can delete a comment.
class DeleteThreadComment extends UseCase<int, Result<void>> {
  final WatchLogsRepository _repository;

  DeleteThreadComment(this._repository);

  @override
  Future<Result<void>> call([int? commentId]) =>
      _repository.deleteComment(commentId!);
}
