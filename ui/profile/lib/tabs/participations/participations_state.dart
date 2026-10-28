import 'package:maratonas/maratonas.dart';

sealed class ParticipationsState {
  const ParticipationsState();
}

class ParticipationsLoading extends ParticipationsState {
  const ParticipationsLoading();
}

/// The maratonas the profile joined (phase 7); CineClubes join in phase 8.
class ParticipationsSuccess extends ParticipationsState {
  final List<MaratonaSummary> maratonas;
  final int page;
  final bool hasNext;
  final bool loadingMore;

  const ParticipationsSuccess({
    this.maratonas = const [],
    this.page = 1,
    this.hasNext = false,
    this.loadingMore = false,
  });

  ParticipationsSuccess copyWith({
    List<MaratonaSummary>? maratonas,
    int? page,
    bool? hasNext,
    bool? loadingMore,
  }) => ParticipationsSuccess(
    maratonas: maratonas ?? this.maratonas,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

class ParticipationsError extends ParticipationsState {
  final String message;

  const ParticipationsError(this.message);
}
