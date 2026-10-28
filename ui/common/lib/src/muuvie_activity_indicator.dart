import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:common/src/platform_helper.dart';

class MuuvieActivityIndicator extends StatelessWidget {
  final double? radius;
  final Color? color;

  const MuuvieActivityIndicator({super.key, this.radius, this.color});

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoActivityIndicator(radius: radius ?? 10.0, color: color);
    }

    return SizedBox(
      width: radius != null ? radius! * 2 : null,
      height: radius != null ? radius! * 2 : null,
      child: CircularProgressIndicator(color: color),
    );
  }
}
