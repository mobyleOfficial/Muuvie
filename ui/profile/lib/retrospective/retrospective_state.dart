import 'package:core/core.dart';
import 'package:stats/stats.dart';

sealed class RetrospectiveState {
  const RetrospectiveState();
}

class RetrospectiveLoading extends RetrospectiveState {
  const RetrospectiveLoading();
}

class RetrospectiveError extends RetrospectiveState {
  final AppError error;

  const RetrospectiveError(this.error);
}

class RetrospectiveSuccess extends RetrospectiveState {
  final Retrospective retrospective;

  const RetrospectiveSuccess(this.retrospective);
}
