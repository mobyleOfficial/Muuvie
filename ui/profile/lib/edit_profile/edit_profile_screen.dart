import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/edit_profile/edit_profile_bloc.dart';
import 'package:profile_ui/edit_profile/edit_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  static const maxLinks = 5;

  final EditProfileCubit cubit;
  final ProfileDetails profile;

  /// Opens the import flow (F3.6). Letterboxd is hidden until F3.3 ships.
  final VoidCallback onImportFilmow;

  const EditProfileScreen({
    super.key,
    required this.cubit,
    required this.profile,
    required this.onImportFilmow,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _displayName = TextEditingController(
    text: widget.profile.displayName ?? '',
  );
  late final _handle = TextEditingController(text: widget.profile.handle ?? '');
  late final _pronouns = TextEditingController(
    text: widget.profile.pronouns ?? '',
  );
  late final _bio = TextEditingController(text: widget.profile.bio ?? '');
  late final _avatarUrl = TextEditingController(
    text: widget.profile.avatarUrl ?? '',
  );
  late final _bannerUrl = TextEditingController(
    text: widget.profile.bannerUrl ?? '',
  );
  late final List<TextEditingController> _links = [
    for (final link in widget.profile.links) TextEditingController(text: link),
  ];

  @override
  void dispose() {
    for (final controller in [
      _displayName,
      _handle,
      _pronouns,
      _bio,
      _avatarUrl,
      _bannerUrl,
      ..._links,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _text(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  /// Keyboards may capitalize the scheme ("HTTPS://"); Uri lowercases it and the host.
  String? _link(TextEditingController controller) {
    final value = _text(controller);
    return value == null ? null : Uri.tryParse(value)?.toString() ?? value;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final handle = HandleAvailability.normalize(_handle.text);
    final error = await widget.cubit.save(
      ProfileDraft(
        displayName: _text(_displayName),
        // An empty field keeps the handle the account already has.
        handle: handle.isEmpty ? null : handle,
        pronouns: _text(_pronouns),
        bio: _text(_bio),
        links: _links.map(_link).whereType<String>().toList(),
        avatarUrl: _link(_avatarUrl),
        bannerUrl: _link(_bannerUrl),
      ),
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          switch (error) {
                EditProfileSaveError.handleTaken =>
                  l10n?.editProfileHandleTaken,
                EditProfileSaveError.invalid => l10n?.editProfileInvalidField,
                EditProfileSaveError.other => l10n?.editProfileSaveError,
              } ??
              '',
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context);
    var confirmed = false;
    await MuuvieDialog.show(
      context: context,
      title: l10n?.editProfileLogoutConfirmTitle ?? '',
      content: l10n?.editProfileLogoutConfirmMessage,
      confirmText: l10n?.editProfileLogout ?? '',
      cancelText: l10n?.cancel ?? '',
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    await widget.cubit.logout();
    // Unsaved edits are dropped: they belong to the account that just left.
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<EditProfileCubit, EditProfileState>(
      bloc: widget.cubit,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(l10n?.profileEditProfile ?? ''),
          centerTitle: true,
          actions: [
            if (state is EditProfileReady)
              TextButton(
                onPressed: state.isSaving ? null : _save,
                child: Text(l10n?.editProfileSave ?? ''),
              ),
          ],
        ),
        body: switch (state) {
          EditProfileLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          EditProfileError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
          ),
          EditProfileReady() => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              if (state.isSaving) const LinearProgressIndicator(),
              _Field(
                controller: _displayName,
                label: l10n?.editProfileDisplayNameLabel ?? '',
                placeholder: widget.profile.username,
                maxLength: 50,
              ),
              _Field(
                controller: _handle,
                label: l10n?.editProfileHandleLabel ?? '',
                placeholder: l10n?.editProfileHandleHint ?? '',
                prefixText: '@',
                maxLength: 30,
                onChanged: widget.cubit.onHandleChanged,
                helper: _HandleStatusText(status: state.handleStatus),
              ),
              _Field(
                controller: _pronouns,
                label: l10n?.editProfilePronounsLabel ?? '',
                placeholder: l10n?.editProfilePronounsPlaceholder ?? '',
                maxLength: 30,
              ),
              _Field(
                controller: _bio,
                label: l10n?.editProfileBioLabel ?? '',
                placeholder: l10n?.editProfileBioPlaceholder ?? '',
                maxLength: 500,
                maxLines: 4,
              ),
              _SectionTitle(l10n?.editProfileLinksLabel ?? ''),
              for (final (index, controller) in _links.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Input(
                          controller: controller,
                          placeholder: 'https://',
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n?.delete,
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () =>
                            setState(() => _links.removeAt(index).dispose()),
                      ),
                    ],
                  ),
                ),
              if (_links.length < EditProfileScreen.maxLinks)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _links.add(TextEditingController())),
                    icon: const Icon(Icons.add_link),
                    label: Text(l10n?.editProfileAddLink ?? ''),
                  ),
                ),
              _SectionTitle(l10n?.editProfileAccentLabel ?? ''),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n?.editProfileAccentDefault ?? ''),
                    selected: state.accentColor == null,
                    onSelected: (_) => widget.cubit.onAccentColorChanged(null),
                  ),
                  MuuvieColorPicker(
                    selected: MuuvieColorPicker.fromHex(state.accentColor),
                    onChanged: (color) => widget.cubit.onAccentColorChanged(
                      MuuvieColorPicker.toHex(color),
                    ),
                  ),
                ],
              ),
              _SectionTitle(l10n?.editProfileImagesLabel ?? ''),
              Text(
                l10n?.editProfileImagesHint ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              _Field(
                controller: _avatarUrl,
                label: l10n?.editProfileAvatarUrlLabel ?? '',
                placeholder: 'https://',
                keyboardType: TextInputType.url,
              ),
              _Field(
                controller: _bannerUrl,
                label: l10n?.editProfileBannerUrlLabel ?? '',
                placeholder: 'https://',
                keyboardType: TextInputType.url,
              ),
              _SectionTitle(l10n?.editProfileImportSection ?? ''),
              OutlinedButton.icon(
                onPressed: state.isScraping ? null : widget.onImportFilmow,
                icon: const Icon(Icons.download),
                label: Text(l10n?.editProfileImportFilmow ?? ''),
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: _confirmLogout,
                style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                icon: const Icon(Icons.logout),
                label: Text(l10n?.editProfileLogout ?? ''),
              ),
            ],
          ),
        },
      ),
    );
  }
}

class _HandleStatusText extends StatelessWidget {
  final HandleStatus status;

  const _HandleStatusText({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (icon, text, color) = switch (status) {
      HandleStatus.unchanged => (null, null, null),
      HandleStatus.checking => (
        Icons.hourglass_empty,
        l10n?.editProfileHandleChecking,
        colorScheme.onSurfaceVariant,
      ),
      HandleStatus.available => (
        Icons.check_circle,
        l10n?.editProfileHandleAvailable,
        colorScheme.primary,
      ),
      HandleStatus.taken => (
        Icons.error,
        l10n?.editProfileHandleTaken,
        colorScheme.error,
      ),
      HandleStatus.invalid => (
        Icons.error_outline,
        l10n?.editProfileHandleInvalid,
        colorScheme.error,
      ),
    };
    if (text == null) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final String? prefixText;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? helper;

  const _Field({
    required this.controller,
    required this.label,
    required this.placeholder,
    this.prefixText,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.helper,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label),
        _Input(
          controller: controller,
          placeholder: placeholder,
          prefixText: prefixText,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          semanticLabel: label,
        ),
        ?helper,
      ],
    ),
  );
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final String? prefixText;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;

  const _Input({
    required this.controller,
    required this.placeholder,
    this.prefixText,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      autocorrect: keyboardType != TextInputType.url && prefixText == null,
      style: TextStyle(color: colorScheme.onSurface),
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixText: prefixText,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
    final label = semanticLabel;
    return label == null ? field : Semantics(label: label, child: field);
  }
}
