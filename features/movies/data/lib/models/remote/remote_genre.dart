import 'package:movies_domain/models/genre.dart';

class RemoteGenre {
  final int id;
  final String name;

  const RemoteGenre({required this.id, required this.name});

  factory RemoteGenre.fromJson(Map<String, dynamic> json) =>
      RemoteGenre(id: json['id'] as int, name: json['name'] as String);

  Genre toDomain() => Genre(id: id, name: name);
}
