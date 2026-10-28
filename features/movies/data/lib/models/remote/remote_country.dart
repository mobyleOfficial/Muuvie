import 'package:movies_domain/models/country.dart';

class RemoteCountry {
  final String iso;
  final String englishName;
  final String? name;

  const RemoteCountry({
    required this.iso,
    required this.englishName,
    this.name,
  });

  factory RemoteCountry.fromJson(Map<String, dynamic> json) => RemoteCountry(
    iso: (json['iso'] ?? json['iso_3166_1']) as String,
    englishName: (json['englishName'] ?? json['english_name']) as String,
    name: json['name'] as String?,
  );

  Country toDomain() => Country(
    iso: iso,
    englishName: englishName,
    name: (name?.isNotEmpty ?? false) ? name : null,
  );
}
