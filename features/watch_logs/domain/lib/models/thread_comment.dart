/// What a comment hangs from (F2.8).
enum CommentTarget {
  watchLog('watch_log'),
  rating('rating');

  final String wireValue;

  const CommentTarget(this.wireValue);

  static CommentTarget? fromWireValue(String? value) =>
      values.where((target) => target.wireValue == value).firstOrNull;
}

class ThreadComment {
  final int id;
  final int? parentId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String body;
  final bool hasSpoiler;
  final DateTime createdAt;

  /// Written by the current user.
  final bool self;

  const ThreadComment({
    required this.id,
    this.parentId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.body,
    this.hasSpoiler = false,
    required this.createdAt,
    this.self = false,
  });
}

/// One page of comments, oldest first.
class CommentPage {
  final List<ThreadComment> comments;
  final int page;
  final int totalResults;
  final bool hasNext;

  const CommentPage({
    required this.comments,
    required this.page,
    required this.totalResults,
    required this.hasNext,
  });
}
