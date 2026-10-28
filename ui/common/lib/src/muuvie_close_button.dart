import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:common/src/platform_helper.dart';

class MuuvieCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;

  /// Icon color; white by default, for the dark modals and stories.
  final Color color;

  const MuuvieCloseButton({
    super.key,
    this.onPressed,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final onTap = onPressed ?? () => Navigator.of(context).pop();
    final closeLabel = MaterialLocalizations.of(context).closeButtonTooltip;

    if (isIOS) {
      return Semantics(
        label: closeLabel,
        button: true,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Icon(CupertinoIcons.xmark, color: color),
        ),
      );
    }

    return IconButton(
      tooltip: closeLabel,
      icon: Icon(Icons.close, color: color),
      onPressed: onTap,
    );
  }
}
