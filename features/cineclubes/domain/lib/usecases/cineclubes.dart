import 'package:cineclubes_domain/models/models.dart';
import 'package:cineclubes_domain/repositories/cineclubes_repository.dart';
import 'package:core/core.dart';

class GetCineClubesParams {
  final CineClubeFilter filter;
  final int page;

  const GetCineClubesParams({
    this.filter = const CineClubeFilter(),
    this.page = 1,
  });
}

/// The CineClube list of Programação (F8.2).
class GetCineClubes
    extends UseCase<GetCineClubesParams, Result<CineClubePage>> {
  final CineClubesRepository _repository;

  GetCineClubes(this._repository);

  @override
  Future<Result<CineClubePage>> call([GetCineClubesParams? params]) {
    final value = params ?? const GetCineClubesParams();
    return _repository.getCineClubes(value.filter, page: value.page);
  }
}

class GetCineClube extends UseCase<String, Result<CineClube>> {
  final CineClubesRepository _repository;

  GetCineClube(this._repository);

  @override
  Future<Result<CineClube>> call([String? slug]) =>
      _repository.getCineClube(slug!);
}

class CheckCineClubeSlug extends UseCase<String, Result<CineClubeSlug>> {
  final CineClubesRepository _repository;

  CheckCineClubeSlug(this._repository);

  @override
  Future<Result<CineClubeSlug>> call([String? slug]) =>
      _repository.checkSlug(slug!);
}

class SaveCineClubeParams {
  /// Null to create a new CineClube.
  final String? slug;
  final CineClubeForm form;

  const SaveCineClubeParams({this.slug, required this.form});
}

/// Creates or edits a CineClube (F8.5).
class SaveCineClube extends UseCase<SaveCineClubeParams, Result<CineClube>> {
  final CineClubesRepository _repository;

  SaveCineClube(this._repository);

  @override
  Future<Result<CineClube>> call([SaveCineClubeParams? params]) {
    final value = params!;
    final slug = value.slug;
    return slug == null
        ? _repository.create(value.form)
        : _repository.update(slug, value.form);
  }
}

/// Only the owner; the CineClube becomes read only (F8.5).
class CancelCineClube extends UseCase<String, Result<CineClube>> {
  final CineClubesRepository _repository;

  CancelCineClube(this._repository);

  @override
  Future<Result<CineClube>> call([String? slug]) => _repository.cancel(slug!);
}

class JoinCineClubeParams {
  final String slug;
  final String? password;

  const JoinCineClubeParams({required this.slug, this.password});
}

/// Joins a CineClube (F8.4); the backend puts the movie on Quero ver.
class JoinCineClube extends UseCase<JoinCineClubeParams, Result<CineClube>> {
  final CineClubesRepository _repository;

  JoinCineClube(this._repository);

  @override
  Future<Result<CineClube>> call([JoinCineClubeParams? params]) =>
      _repository.join(params!.slug, password: params.password);
}

class LeaveCineClube extends UseCase<String, Result<void>> {
  final CineClubesRepository _repository;

  LeaveCineClube(this._repository);

  @override
  Future<Result<void>> call([String? slug]) => _repository.leave(slug!);
}

class GetCineClubeProgressParams {
  final String slug;
  final int? sessionId;
  final int page;

  const GetCineClubeProgressParams({
    required this.slug,
    this.sessionId,
    this.page = 1,
  });
}

/// The participants' logs of a session (F8.3).
class GetCineClubeProgress
    extends UseCase<GetCineClubeProgressParams, Result<CineClubeLogPage>> {
  final CineClubesRepository _repository;

  GetCineClubeProgress(this._repository);

  @override
  Future<Result<CineClubeLogPage>> call([GetCineClubeProgressParams? params]) {
    final value = params!;
    return _repository.getProgress(
      value.slug,
      sessionId: value.sessionId,
      page: value.page,
    );
  }
}

class GetCineClubeParticipantsParams {
  final String slug;
  final int? sessionId;

  /// Null for everyone.
  final SessionProgress? progress;
  final int page;

  const GetCineClubeParticipantsParams({
    required this.slug,
    this.sessionId,
    this.progress,
    this.page = 1,
  });
}

/// Participants of a session, filtered by their progress (F8.3).
class GetCineClubeParticipants
    extends UseCase<GetCineClubeParticipantsParams, Result<ParticipantPage>> {
  final CineClubesRepository _repository;

  GetCineClubeParticipants(this._repository);

  @override
  Future<Result<ParticipantPage>> call([
    GetCineClubeParticipantsParams? params,
  ]) {
    final value = params!;
    return _repository.getParticipants(
      value.slug,
      sessionId: value.sessionId,
      progress: value.progress,
      page: value.page,
    );
  }
}
