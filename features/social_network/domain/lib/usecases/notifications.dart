import 'package:core/core.dart';
import 'package:social_network_domain/models/models.dart';
import 'package:social_network_domain/repositories/social_network_repository.dart';

/// The push preferences of the current user (Perfil › Configurações).
class GetNotificationPrefs extends UseCase<void, Result<NotificationPrefs>> {
  final SocialNetworkRepository _repository;

  GetNotificationPrefs(this._repository);

  @override
  Future<Result<NotificationPrefs>> call([void params]) =>
      _repository.getNotificationPrefs();
}

class SaveNotificationPrefs
    extends UseCase<NotificationPrefs, Result<NotificationPrefs>> {
  final SocialNetworkRepository _repository;

  SaveNotificationPrefs(this._repository);

  @override
  Future<Result<NotificationPrefs>> call([NotificationPrefs? prefs]) =>
      _repository.saveNotificationPrefs(prefs!);
}
