import 'package:movies_domain/domain.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class LocalRecentSearch {
  @Id()
  int id;
  @Unique()
  String query;

  @Property(type: PropertyType.date)
  DateTime searchedAt;

  LocalRecentSearch({
    this.id = 0,
    required this.query,
    required this.searchedAt,
  });

  RecentSearch toDomain() =>
      RecentSearch(id: id, query: query, searchedAt: searchedAt);
}
