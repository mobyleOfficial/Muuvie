import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:common/src/platform_helper.dart';

class MuuvieSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const MuuvieSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoSlider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      );
    }

    return Slider(value: value, min: min, max: max, onChanged: onChanged);
  }
}
