import 'package:movies_domain/models/language.dart';

class RemoteLanguage {
  final String iso;
  final String englishName;
  final String? name;

  const RemoteLanguage({
    required this.iso,
    required this.englishName,
    this.name,
  });

  factory RemoteLanguage.fromJson(Map<String, dynamic> json) => RemoteLanguage(
    iso: (json['iso'] ?? json['iso_639_1']) as String,
    englishName: (json['englishName'] ?? json['english_name']) as String,
    name: json['name'] as String?,
  );

  Language toDomain() => Language(
    iso: iso,
    englishName: englishName,
    name: (name?.isNotEmpty ?? false) ? name : null,
  );
}
