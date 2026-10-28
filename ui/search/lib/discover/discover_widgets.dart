import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:locadoras_ui/locadoras_router.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/member/highlights/highlights_tab.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:shelves/shelves.dart';

/// Opens a shelf of the discovery hub.
void openDiscoveredShelf(BuildContext context, Shelf shelf) =>
    context.router.push(
      ShelfDetailRoute(
        shelfId: shelf.id,
        shelfName: shelf.name,
        shelfColor: shelf.color,
      ),
    );

/// Opens a locadora of the discovery hub; its shelves open in the same stack.
void openDiscoveredLocadora(BuildContext context, Locadora locadora) =>
    context.router.push(
      LocadoraDetailRoute(
        locadoraId: locadora.id,
        locadoraName: locadora.name,
        onOpenShelf: openDiscoveredShelf,
        onOpenOwner: (context, locadora) => openProfile(
          context,
          locadora.ownerId,
          name: locadora.ownerUsername,
        ),
      ),
    );

void openProfile(BuildContext context, String userId, {String? name}) =>
    context.router.push(PublicProfileRoute(userId: userId, displayName: name));

/// A public shelf with its owner and first posters.
class DiscoveredShelfCard extends StatelessWidget {
  final Shelf shelf;

  const DiscoveredShelfCard({super.key, required this.shelf});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final owner = shelf.ownerName;
    return HighlightCollectionCard(
      title: shelf.name,
      subtitle: [
        if (owner != null) l10n?.shelfByOwner(owner) ?? owner,
        l10n?.shelfWatchedOfTotal(shelf.totalWatched, shelf.totalMovies) ?? '',
      ].join(' · '),
      posterPaths: shelf.posterPaths,
      onTap: () => openDiscoveredShelf(context, shelf),
    );
  }
}

/// A public locadora with its owner and first posters.
class DiscoveredLocadoraCard extends StatelessWidget {
  final Locadora locadora;

  const DiscoveredLocadoraCard({super.key, required this.locadora});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HighlightCollectionCard(
      title: locadora.name,
      subtitle: l10n?.locadoraByOwner(locadora.ownerUsername),
      posterPaths: locadora.posterPaths,
      onTap: () => openDiscoveredLocadora(context, locadora),
    );
  }
}

/// Avatar, name and @handle of a profile to follow.
class DiscoveredProfileTile extends StatelessWidget {
  final ProfileCard profile;

  const DiscoveredProfileTile({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final handle = profile.handle;
    return ListTile(
      leading: ProfileAvatar(
        url: profile.avatarUrl,
        accent: profile.accentColor,
      ),
      title: Text(profile.name),
      subtitle: Text(
        [
          if (handle != null) '@$handle',
          l10n?.profileWatchedCount(profile.watched) ?? '',
        ].join(' · '),
      ),
      trailing: profile.featured
          ? Icon(Icons.verified_outlined, semanticLabel: l10n?.discoverFeatured)
          : null,
      onTap: () => openProfile(context, profile.id, name: profile.name),
    );
  }
}

/// The round avatar of the profile cards, ringed with the profile accent color.
class ProfileAvatar extends StatelessWidget {
  final String? url;
  final String? accent;
  final double radius;

  const ProfileAvatar({super.key, this.url, this.accent, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = url;
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          MuuvieColorPicker.fromHex(accent) ?? colorScheme.secondaryContainer,
      child: CircleAvatar(
        radius: radius - 2,
        backgroundColor: colorScheme.secondaryContainer,
        backgroundImage: avatar == null
            ? null
            : CachedNetworkImageProvider(avatar),
        child: avatar == null
            ? Icon(Icons.person, color: colorScheme.onSecondaryContainer)
            : null,
      ),
    );
  }
}
