import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:common/src/platform_helper.dart';

class MuuvieAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  const MuuvieAppBar({super.key, this.title, this.actions, this.leading});

  @override
  Size get preferredSize => isIOS
      ? const Size.fromHeight(44.0)
      : const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoNavigationBar(
        middle: title != null ? Text(title!) : null,
        leading: leading,
        trailing: actions != null
            ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
            : null,
      );
    }

    return AppBar(
      title: title != null ? Text(title!) : null,
      leading: leading,
      actions: actions,
    );
  }
}
