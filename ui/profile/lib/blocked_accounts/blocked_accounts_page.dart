import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:social_network/social_network.dart';

import 'package:profile_ui/blocked_accounts/blocked_accounts_bloc.dart';

/// Configurações › Contas bloqueadas.
@RoutePage()
class BlockedAccountsPage extends StatefulWidget {
  const BlockedAccountsPage({super.key});

  @override
  State<BlockedAccountsPage> createState() => _BlockedAccountsPageState();
}

class _BlockedAccountsPageState extends State<BlockedAccountsPage> {
  late final BlockedAccountsCubit _cubit = BlockedAccountsCubit(
    getBlockedUsers: GetIt.I<GetBlockedUsers>(),
    setBlocked: GetIt.I<SetBlocked>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _unblock(String userId) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final error = await _cubit.unblock(userId);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          (error == null ? l10n?.unblockedSnack : l10n?.commonActionError) ??
              '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settingsBlockedAccounts ?? '')),
      body: BlocBuilder<BlockedAccountsCubit, BlockedAccountsState>(
        bloc: _cubit,
        builder: (context, state) => switch (state) {
          BlockedAccountsLoading() => const Center(
            child: MuuvieActivityIndicator(),
          ),
          BlockedAccountsError() => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: l10n?.emptyStateErrorMessage ?? '',
            action: _cubit.load,
            actionLabel: l10n?.emptyStateRetry,
          ),
          BlockedAccountsReady(:final users) when users.isEmpty =>
            MuuvieEmptyState(
              illustration: MuuvieIllustration.sleeping,
              title: l10n?.blockedAccountsEmpty ?? '',
              message: '',
            ),
          BlockedAccountsReady(:final users, :final hasNext, :final busy) =>
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (hasNext &&
                    notification.metrics.extentAfter < 200) {
                  _cubit.loadMore();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].user;
                  return ListTile(
                    leading: MuuvieUserAvatar(
                      url: user.avatarUrl,
                      accentColor: user.accentColor,
                      name: user.name,
                    ),
                    title: Text(user.name),
                    subtitle: user.handle == null
                        ? null
                        : Text('@${user.handle}'),
                    trailing: OutlinedButton(
                      onPressed: busy.contains(user.id)
                          ? null
                          : () => _unblock(user.id),
                      child: Text(l10n?.unblockAction ?? ''),
                    ),
                  );
                },
              ),
            ),
        },
      ),
    );
  }
}
