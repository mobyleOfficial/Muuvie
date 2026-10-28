import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// A movie poster of the locadora cards and corridors, with a placeholder.
class LocadoraPoster extends StatelessWidget {
  static const width = 100.0;
  static const height = 150.0;

  final String? posterPath;

  const LocadoraPoster({super.key, required this.posterPath});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.movie, color: colorScheme.onSurfaceVariant),
    );
    final path = posterPath;

    return ClipRRect(
      borderRadius: MuuvieRadius.smallAll,
      child: path == null
          ? placeholder
          : CachedNetworkImage(
              imageUrl: TmdbImageUrl.buildPosterMedium(path),
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: width,
                height: height,
                color: colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (_, _, _) => placeholder,
            ),
    );
  }
}
