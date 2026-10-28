import 'package:cineclubes_domain/models/models.dart';
import 'package:core/core.dart';

/// CineClubes of the v1 API (B8). The list, the detail, the progress and
/// the participants work without login.
abstract interface class CineClubesRepository {
  Future<Result<CineClubePage>> getCineClubes(
    CineClubeFilter filter, {
    int page = 1,
  });

  Future<Result<CineClube>> getCineClube(String slug);

  Future<Result<CineClubeSlug>> checkSlug(String slug);

  /// Fails with `conflict` when the slug is taken.
  Future<Result<CineClube>> create(CineClubeForm form);

  Future<Result<CineClube>> update(String slug, CineClubeForm form);

  Future<Result<CineClube>> cancel(String slug);

  /// Fails with `forbidden` for a wrong password and `conflict` when the
  /// CineClube is closed or the user already joined.
  Future<Result<CineClube>> join(String slug, {String? password});

  Future<Result<void>> leave(String slug);

  /// Logs of the participants of a session (default: the current one),
  /// with spoilers hidden by the server.
  Future<Result<CineClubeLogPage>> getProgress(
    String slug, {
    int? sessionId,
    int page = 1,
  });

  Future<Result<ParticipantPage>> getParticipants(
    String slug, {
    int? sessionId,
    SessionProgress? progress,
    int page = 1,
  });
}
