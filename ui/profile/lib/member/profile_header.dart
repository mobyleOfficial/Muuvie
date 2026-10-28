import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/follows/follow_button.dart';
import 'package:social_network/social_network.dart' show FollowList;
import 'package:url_launcher/url_launcher.dart';

/// Top of a profile (F5.1): banner, avatar, name, pronouns, @handle, bio,
/// links and counters. The accent color of the profile tints the banner
/// fallback, the avatar ring and the main action.
class ProfileHeader extends StatelessWidget {
  static const _bannerHeight = 112.0;
  static const _avatarRadius = 40.0;

  final ProfileDetails profile;

  /// Edit profile (own) or follow / unfollow (others).
  final VoidCallback? onPrimaryAction;
  final bool isPrimaryActionBusy;
  final VoidCallback? onShare;
  final VoidCallback? onPickHandle;

  /// Perfil › Configurações (F11.1); only on my profile.
  final VoidCallback? onOpenSettings;

  /// Opens the conversation; offered only to mutuals (F6.5).
  final VoidCallback? onWhisper;

  /// Opens the followers or following list from the counters (F6.3).
  final ValueChanged<FollowList>? onOpenFollows;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onPrimaryAction,
    this.isPrimaryActionBusy = false,
    this.onShare,
    this.onPickHandle,
    this.onOpenSettings,
    this.onWhisper,
    this.onOpenFollows,
  });

  /// The public link of a profile, or null until it has a handle.
  static String? linkOf(ProfileDetails profile) =>
      profile.handle == null ? null : 'https://muuvie.app/@${profile.handle}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final accent =
        MuuvieColorPicker.fromHex(profile.accentColor) ?? colorScheme.primary;
    final bio = profile.bio;
    final pronouns = profile.pronouns;
    final handle = profile.handle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _bannerHeight + _avatarRadius + 8,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _bannerHeight,
                child: _Banner(url: profile.bannerUrl, accent: accent),
              ),
              Positioned(
                left: 16,
                top: _bannerHeight - _avatarRadius,
                child: _Avatar(
                  url: profile.avatarUrl,
                  ring: accent,
                  radius: _avatarRadius,
                  label: profile.name,
                ),
              ),
              Positioned(
                right: 8,
                top: _bannerHeight + 4,
                child: Row(
                  children: [
                    if (onOpenSettings != null)
                      IconButton(
                        tooltip: l10n?.settingsTitle,
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: onOpenSettings,
                      ),
                    if (onShare != null)
                      IconButton(
                        tooltip: l10n?.profileShare,
                        icon: const Icon(Icons.share_outlined),
                        onPressed: onShare,
                      ),
                    if (onWhisper != null && profile.mutual && !profile.isSelf)
                      IconButton(
                        tooltip: l10n?.whisperAction,
                        icon: const Icon(Icons.mail_outline),
                        onPressed: onWhisper,
                      ),
                    if (onPrimaryAction != null)
                      _PrimaryAction(
                        profile: profile,
                        accent: accent,
                        busy: isPrimaryActionBusy,
                        onPressed: onPrimaryAction!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      profile.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (pronouns != null)
                    Text(
                      pronouns,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              if (handle != null)
                Text(
                  '@$handle',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              if (profile.followsMe && !profile.isSelf)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Chip(
                    label: Text(l10n?.profileFollowsYou ?? ''),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              if (handle == null && onPickHandle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: onPickHandle,
                    icon: const Icon(Icons.alternate_email, size: 18),
                    label: Text(l10n?.profilePickHandleTip ?? ''),
                  ),
                ),
              if (bio != null) ...[
                const SizedBox(height: 8),
                Text(bio, maxLines: 4, overflow: TextOverflow.ellipsis),
              ],
              if (profile.links.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final link in profile.links) _LinkChip(url: link),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Stats(stats: profile.stats, onOpenFollows: onOpenFollows),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final String? url;
  final Color accent;

  const _Banner({required this.url, required this.accent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.75),
            colorScheme.surfaceContainerHigh,
          ],
        ),
      ),
    );
    final banner = url;
    if (banner == null) return fallback;
    return CachedNetworkImage(
      imageUrl: banner,
      fit: BoxFit.cover,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final Color ring;
  final double radius;
  final String label;

  const _Avatar({
    required this.url,
    required this.ring,
    required this.radius,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = url;

    return Semantics(
      label: label,
      image: true,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: radius - 3,
          backgroundColor: colorScheme.secondaryContainer,
          backgroundImage: avatar != null
              ? CachedNetworkImageProvider(avatar)
              : null,
          child: avatar == null
              ? ExcludeSemantics(
                  child: Icon(
                    Icons.person,
                    size: radius,
                    color: colorScheme.onSecondaryContainer,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final ProfileDetails profile;
  final Color accent;
  final bool busy;
  final VoidCallback onPressed;

  const _PrimaryAction({
    required this.profile,
    required this.accent,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (profile.isSelf) {
      return OutlinedButton(
        onPressed: onPressed,
        child: Text(l10n?.profileEditProfile ?? ''),
      );
    }
    return FollowButton(
      following: profile.isFollowing,
      followedBy: profile.followsMe,
      busy: busy,
      accent: accent,
      onPressed: onPressed,
    );
  }
}

class _LinkChip extends StatelessWidget {
  final String url;

  const _LinkChip({required this.url});

  String get _label {
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? '';
    final label = host.startsWith('www.') ? host.substring(4) : host;
    return label.isEmpty ? url : label;
  }

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: const Icon(Icons.link, size: 16),
    label: Text(_label),
    visualDensity: VisualDensity.compact,
    onPressed: () =>
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
  );
}

class _Stats extends StatelessWidget {
  final ProfileStats stats;
  final ValueChanged<FollowList>? onOpenFollows;

  const _Stats({required this.stats, this.onOpenFollows});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (stats.watched, l10n?.profileStatWatched ?? ''),
      (stats.shelves, l10n?.profileTabShelves ?? ''),
      (stats.locadoras, l10n?.profileTabLocadoras ?? ''),
      (stats.watchLogs, l10n?.profileTabLogs ?? ''),
      (stats.maratonas, l10n?.profileTabMarathons ?? ''),
      (stats.cineclubes, l10n?.profileStatCineclubes ?? ''),
      (stats.participations, l10n?.profileTabParticipations ?? ''),
    ];
    final follows = [
      (stats.followers, l10n?.profileFollowers ?? '', FollowList.followers),
      (stats.following, l10n?.profileFollowing ?? '', FollowList.following),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final (value, label) in items) _Stat(value: value, label: label),
          for (final (value, label, list) in follows)
            _Stat(
              value: value,
              label: label,
              onTap: onOpenFollows == null ? null : () => onOpenFollows!(list),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback? onTap;

  const _Stat({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        children: [
          Text(
            '$value',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
    final tap = onTap;
    return MergeSemantics(
      child: tap == null
          ? content
          : InkWell(
              borderRadius: MuuvieRadius.smallAll,
              onTap: tap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: content,
              ),
            ),
    );
  }
}
