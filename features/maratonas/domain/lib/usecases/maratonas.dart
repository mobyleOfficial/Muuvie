import 'package:core/core.dart';
import 'package:maratonas_domain/models/models.dart';
import 'package:maratonas_domain/repositories/maratonas_repository.dart';

class GetMaratonasParams {
  final MaratonaFilter filter;
  final int page;

  const GetMaratonasParams({
    this.filter = const MaratonaFilter(),
    this.page = 1,
  });
}

/// The maratona list of Programação (F7.2).
class GetMaratonas extends UseCase<GetMaratonasParams, Result<MaratonaPage>> {
  final MaratonasRepository _repository;

  GetMaratonas(this._repository);

  @override
  Future<Result<MaratonaPage>> call([GetMaratonasParams? params]) {
    final value = params ?? const GetMaratonasParams();
    return _repository.getMaratonas(value.filter, page: value.page);
  }
}

class GetMaratona extends UseCase<String, Result<Maratona>> {
  final MaratonasRepository _repository;

  GetMaratona(this._repository);

  @override
  Future<Result<Maratona>> call([String? slug]) =>
      _repository.getMaratona(slug!);
}

class CheckMaratonaSlug extends UseCase<String, Result<SlugAvailability>> {
  final MaratonasRepository _repository;

  CheckMaratonaSlug(this._repository);

  @override
  Future<Result<SlugAvailability>> call([String? slug]) =>
      _repository.checkSlug(slug!);
}

class SaveMaratonaParams {
  /// Null to create a new maratona.
  final String? slug;
  final MaratonaForm form;

  const SaveMaratonaParams({this.slug, required this.form});
}

/// Creates or edits a maratona (F7.7).
class SaveMaratona extends UseCase<SaveMaratonaParams, Result<Maratona>> {
  final MaratonasRepository _repository;

  SaveMaratona(this._repository);

  @override
  Future<Result<Maratona>> call([SaveMaratonaParams? params]) {
    final value = params!;
    final slug = value.slug;
    return slug == null
        ? _repository.create(value.form)
        : _repository.update(slug, value.form);
  }
}

/// Only the creator; the maratona becomes read only (F7.8).
class CancelMaratona extends UseCase<String, Result<Maratona>> {
  final MaratonasRepository _repository;

  CancelMaratona(this._repository);

  @override
  Future<Result<Maratona>> call([String? slug]) => _repository.cancel(slug!);
}

class GetMaratonaTemplates
    extends UseCase<void, Result<List<MaratonaTemplate>>> {
  final MaratonasRepository _repository;

  GetMaratonaTemplates(this._repository);

  @override
  Future<Result<List<MaratonaTemplate>>> call([void params]) =>
      _repository.getTemplates();
}

class CreateFromTemplateParams {
  final String templateId;
  final String slug;
  final DateTime startsOn;
  final String? title;

  const CreateFromTemplateParams({
    required this.templateId,
    required this.slug,
    required this.startsOn,
    this.title,
  });
}

/// Starts a maratona from a template (F7.9).
class CreateMaratonaFromTemplate
    extends UseCase<CreateFromTemplateParams, Result<Maratona>> {
  final MaratonasRepository _repository;

  CreateMaratonaFromTemplate(this._repository);

  @override
  Future<Result<Maratona>> call([CreateFromTemplateParams? params]) {
    final value = params!;
    return _repository.createFromTemplate(
      value.templateId,
      slug: value.slug,
      startsOn: value.startsOn,
      title: value.title,
    );
  }
}
