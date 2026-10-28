import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:auth_ui/login_router.dart';

@RoutePage()
class AuthFlowPage extends StatefulWidget {
  const AuthFlowPage({super.key});

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  final _appBarController = AppBarController();
  StackRouter? _innerRouter;

  void _attachRouter(StackRouter router) {
    if (_innerRouter == router) return;
    _detachListeners();
    _innerRouter = router;
    router.addListener(_onRouteChanged);
    router.navigationHistory.addListener(_onRouteChanged);
    _resolveTitle();
  }

  void _detachListeners() {
    _innerRouter?.removeListener(_onRouteChanged);
    _innerRouter?.navigationHistory.removeListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    if (!mounted) return;
    _resolveTitle();
  }

  void _resolveTitle() {
    final router = _innerRouter;
    if (router == null) return;
    final title = switch (router.topRoute.name) {
      SignUpRoute.name => _signUpTitle,
      _ => null,
    };
    _appBarController.update(title: title);
  }

  String? get _signUpTitle {
    final l10n = AppLocalizations.of(context);
    return l10n?.signUpTitle;
  }

  @override
  void dispose() {
    _detachListeners();
    _appBarController.dispose();
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
                  ListenableBuilder(
                    listenable: _appBarController,
                    builder: (context, _) {
                      final titleOverride = _appBarController.currentTitle;
                      final hasTitle = titleOverride != null;

                      return MuuvieAnimatedAppBar(
                        title: titleOverride,
                        leading: hasTitle
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
                      );
                    },
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
