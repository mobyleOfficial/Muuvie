import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:common/src/platform_helper.dart';

class MuuvieIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;

  const MuuvieIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(icon, size: size, color: color),
      );
    }

    return IconButton(
      icon: Icon(icon),
      iconSize: size,
      color: color,
      onPressed: onPressed,
    );
  }
}
