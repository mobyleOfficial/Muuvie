import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// Hosts login and sign up. The screens carry their own headline, so the
/// bar only offers back (when there is a screen to go back to) and close.
@RoutePage()
class AuthFlowPage extends StatefulWidget {
  const AuthFlowPage({super.key});

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  final _canGoBack = ValueNotifier(false);
  StackRouter? _innerRouter;

  void _attachRouter(StackRouter router) {
    if (_innerRouter == router) return;
    _detachListeners();
    _innerRouter = router;
    router.addListener(_onRouteChanged);
    _onRouteChanged();
  }

  void _detachListeners() => _innerRouter?.removeListener(_onRouteChanged);

  void _onRouteChanged() {
    if (!mounted) return;
    _canGoBack.value = (_innerRouter?.stack.length ?? 0) > 1;
  }

  @override
  void dispose() {
    _detachListeners();
    _canGoBack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoRouter(
      builder: (context, content) {
        final router = context.router;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _attachRouter(router);
        });

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  ValueListenableBuilder(
                    valueListenable: _canGoBack,
                    builder: (context, canGoBack, _) => MuuvieAnimatedAppBar(
                      leading: canGoBack
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => _innerRouter?.maybePop(),
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).backButtonTooltip,
                            )
                          : null,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(false),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: content),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
