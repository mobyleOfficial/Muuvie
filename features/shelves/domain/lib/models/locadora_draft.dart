import 'package:core/core.dart';

/// Editable fields of a locadora.
class LocadoraDraft {
  final String name;
  final String? description;
  final ContentVisibility visibility;
  final bool hideShelvesInProfile;
  final bool hideShelvesInFilters;

  const LocadoraDraft({
    required this.name,
    this.description,
    this.visibility = ContentVisibility.public,
    this.hideShelvesInProfile = false,
    this.hideShelvesInFilters = false,
  });
}
