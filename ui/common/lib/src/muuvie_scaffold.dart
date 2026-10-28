import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:common/src/platform_helper.dart';

class MuuvieScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool hasNavigationBar;

  const MuuvieScaffold({
    super.key,
    this.title,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.actions,
    this.hasNavigationBar = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoPageScaffold(
        navigationBar: hasNavigationBar
            ? CupertinoNavigationBar(
                middle: title != null ? Text(title!) : null,
                trailing: actions != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                    : null,
              )
            : null,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: body),
              ?bottomNavigationBar,
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: hasNavigationBar
          ? AppBar(title: title != null ? Text(title!) : null, actions: actions)
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
