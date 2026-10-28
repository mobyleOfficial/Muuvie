import 'package:movies_domain/models/person.dart';

class CastMember {
  final Person person;
  final String? character;
  final int? order;

  const CastMember({required this.person, this.character, this.order});
}
