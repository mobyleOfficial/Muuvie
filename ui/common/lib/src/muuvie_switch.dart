import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:common/src/platform_helper.dart';

class MuuvieSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const MuuvieSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoSwitch(value: value, onChanged: onChanged);
    }

    return Switch(value: value, onChanged: onChanged);
  }
}
