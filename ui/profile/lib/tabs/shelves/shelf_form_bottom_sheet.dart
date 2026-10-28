import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:shelves/shelves.dart';

/// Creates a shelf, or edits [shelf] when given (F1.1, F1.2).
///
/// System shelves ("Já assisti", "Quero ver") keep their name: the field is
/// disabled and a line explains why. Everything else stays editable.
class ShelfFormBottomSheet extends StatefulWidget {
  final Shelf? shelf;
  final Future<bool> Function(ShelfDraft draft) onSave;

  const ShelfFormBottomSheet({super.key, this.shelf, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    Shelf? shelf,
    required Future<bool> Function(ShelfDraft draft) onSave,
  }) => MuuvieBottomSheet.show(
    context: context,
    builder: (_) => ShelfFormBottomSheet(shelf: shelf, onSave: onSave),
  );

  @override
  State<ShelfFormBottomSheet> createState() => _ShelfFormBottomSheetState();
}

class _ShelfFormBottomSheetState extends State<ShelfFormBottomSheet> {
  late final _nameController = TextEditingController(text: widget.shelf?.name);
  late final _descriptionController = TextEditingController(
    text: widget.shelf?.description,
  );
  late Color? _color = MuuvieColorPicker.fromHex(widget.shelf?.color);
  late ContentVisibility _visibility =
      widget.shelf?.visibility ?? ContentVisibility.public;
  bool _isSaving = false;

  bool get _isEditing => widget.shelf != null;

  bool get _isSystem => widget.shelf?.isSystem ?? false;

  bool get _canSave {
    final name = _nameController.text.trim();
    return !_isSaving &&
        name.isNotEmpty &&
        name.length <= SaveShelf.maxNameLength &&
        _descriptionController.text.trim().length <=
            SaveShelf.maxDescriptionLength;
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
      ShelfDraft(
        name: _nameController.text,
        description: _descriptionController.text,
        color: _color == null ? null : MuuvieColorPicker.toHex(_color!),
        visibility: _visibility,
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      Navigator.of(context).pop();
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
                          ? l10n?.editShelfTitle
                          : l10n?.createShelfTitle) ??
                      '',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _Label(l10n?.createShelfNamePrompt ?? ''),
              const SizedBox(height: 8),
              if (_isSystem)
                // The stored name is Portuguese; show the localized one, read-only.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: MuuvieRadius.mediumAll,
                  ),
                  child: Text(
                    l10n?.shelfName(
                          widget.shelf!.systemType,
                          widget.shelf!.name,
                        ) ??
                        widget.shelf!.name,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                MuuvieTextField(
                  controller: _nameController,
                  placeholder: l10n?.createShelfNameHint,
                  onChanged: (_) => setState(() {}),
                ),
              if (_isSystem) ...[
                const SizedBox(height: 6),
                Text(
                  l10n?.systemShelfLockedHint ?? '',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _Label(l10n?.createShelfDescriptionPrompt ?? ''),
              const SizedBox(height: 8),
              MuuvieTextField(
                controller: _descriptionController,
                placeholder: l10n?.createShelfDescriptionHint,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${_descriptionController.text.trim().length}/${SaveShelf.maxDescriptionLength}',
                    style: textTheme.labelSmall?.copyWith(
                      color:
                          _descriptionController.text.trim().length >
                              SaveShelf.maxDescriptionLength
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _Label(l10n?.createShelfColorPrompt ?? ''),
              const SizedBox(height: 8),
              MuuvieColorPicker(
                selected: _color,
                // Tapping the selected swatch again clears the color.
                onChanged: (color) =>
                    setState(() => _color = color == _color ? null : color),
              ),
              const SizedBox(height: 20),
              _Label(l10n?.createShelfVisibilityPrompt ?? ''),
              const SizedBox(height: 12),
              MuuvieVisibilitySelector(
                value: _visibility,
                onChanged: (visibility) =>
                    setState(() => _visibility = visibility),
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
                                  : l10n?.createShelfSave) ??
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
