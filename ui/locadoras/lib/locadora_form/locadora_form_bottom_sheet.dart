import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:shelves/shelves.dart';

/// Creates a locadora, or edits [locadora] when given (F4.1).
///
/// [onSave] returns the saved locadora, or null when saving failed. The sheet
/// pops with the saved locadora.
class LocadoraFormBottomSheet extends StatefulWidget {
  final Locadora? locadora;
  final Future<Locadora?> Function(LocadoraDraft draft) onSave;

  const LocadoraFormBottomSheet({
    super.key,
    this.locadora,
    required this.onSave,
  });

  static Future<Locadora?> show(
    BuildContext context, {
    Locadora? locadora,
    required Future<Locadora?> Function(LocadoraDraft draft) onSave,
  }) => MuuvieBottomSheet.show<Locadora>(
    context: context,
    builder: (_) => LocadoraFormBottomSheet(locadora: locadora, onSave: onSave),
  );

  @override
  State<LocadoraFormBottomSheet> createState() =>
      _LocadoraFormBottomSheetState();
}

class _LocadoraFormBottomSheetState extends State<LocadoraFormBottomSheet> {
  late final _nameController = TextEditingController(
    text: widget.locadora?.name,
  );
  late final _descriptionController = TextEditingController(
    text: widget.locadora?.description,
  );
  late ContentVisibility _visibility =
      widget.locadora?.visibility ?? ContentVisibility.public;
  late bool _hideShelvesInProfile =
      widget.locadora?.hideShelvesInProfile ?? false;
  late bool _hideShelvesInFilters =
      widget.locadora?.hideShelvesInFilters ?? false;
  bool _isSaving = false;

  bool get _isEditing => widget.locadora != null;

  bool get _canSave {
    final name = _nameController.text.trim();
    return !_isSaving &&
        name.isNotEmpty &&
        name.length <= SaveLocadora.maxNameLength &&
        _descriptionController.text.trim().length <=
            SaveLocadora.maxDescriptionLength;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final saved = await widget.onSave(
      LocadoraDraft(
        name: _nameController.text,
        description: _descriptionController.text,
        visibility: _visibility,
        hideShelvesInProfile: _hideShelvesInProfile,
        hideShelvesInFilters: _hideShelvesInFilters,
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved != null) {
      Navigator.of(context).pop(saved);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.shelfActionError ?? ''),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final descriptionLength = _descriptionController.text.trim().length;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        color: colorScheme.surface,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  (_isEditing
                          ? l10n?.editLocadoraTitle
                          : l10n?.createLocadoraTitle) ??
                      '',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _Label(l10n?.createLocadoraNamePrompt ?? ''),
              const SizedBox(height: 8),
              MuuvieTextField(
                controller: _nameController,
                placeholder: l10n?.createLocadoraNameHint,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _Label(l10n?.createLocadoraDescriptionPrompt ?? ''),
              const SizedBox(height: 8),
              MuuvieTextField(
                controller: _descriptionController,
                placeholder: l10n?.createLocadoraDescriptionHint,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$descriptionLength/${SaveLocadora.maxDescriptionLength}',
                    style: textTheme.labelSmall?.copyWith(
                      color:
                          descriptionLength > SaveLocadora.maxDescriptionLength
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _Label(l10n?.createLocadoraVisibilityPrompt ?? ''),
              const SizedBox(height: 12),
              MuuvieVisibilitySelector(
                value: _visibility,
                onChanged: (visibility) =>
                    setState(() => _visibility = visibility),
              ),
              const SizedBox(height: 12),
              _SwitchRow(
                label: l10n?.locadoraHideInProfile ?? '',
                value: _hideShelvesInProfile,
                onChanged: (value) =>
                    setState(() => _hideShelvesInProfile = value),
              ),
              _SwitchRow(
                label: l10n?.locadoraHideInFilters ?? '',
                value: _hideShelvesInFilters,
                onChanged: (value) =>
                    setState(() => _hideShelvesInFilters = value),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: MuuvieButton(
                  onPressed: _canSave ? _save : null,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          (_isEditing
                                  ? l10n?.shelfSave
                                  : l10n?.createLocadoraSave) ??
                              '',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          MuuvieSwitch(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
  );
}
