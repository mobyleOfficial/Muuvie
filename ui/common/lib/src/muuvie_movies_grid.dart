import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const int muuvieGridCrossAxisCount = 3;
const double muuvieGridChildAspectRatio = 2 / 3;
const double muuvieGridSpacing = 8;
const double muuvieGridPadding = 16;

const SliverGridDelegateWithFixedCrossAxisCount muuvieGridDelegate =
    SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: muuvieGridCrossAxisCount,
      childAspectRatio: muuvieGridChildAspectRatio,
      crossAxisSpacing: muuvieGridSpacing,
      mainAxisSpacing: muuvieGridSpacing,
    );

class MuuvieMoviePosterCard extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  static const double _borderRadius = 10;

  const MuuvieMoviePosterCard({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(_borderRadius),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        child: imageUrl != null
            ? Ink.image(
                image: CachedNetworkImageProvider(imageUrl!),
                fit: BoxFit.cover,
              )
            : const Center(child: Icon(Icons.movie, size: 36)),
      ),
    ),
  );
}
