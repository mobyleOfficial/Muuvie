/// A push the user tapped (fase 15). [type] is the backend event type
/// (`message`, `new_follower`, `maratona_started`...) and [data] its fields.
class PushNotification {
  final String type;
  final Map<String, String> data;

  const PushNotification({required this.type, this.data = const {}});

  factory PushNotification.fromData(Map<String, dynamic> data) =>
      PushNotification(
        type: data['type']?.toString() ?? '',
        data: data.map((key, value) => MapEntry(key, value.toString())),
      );
}
