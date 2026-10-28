import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muuvie/routes/main_state.dart';
import 'package:profile/profile.dart';

/// Whether an import runs in the background, for the banner of the main screen.
class MainCubit extends Cubit<MainState> {
  late final StreamSubscription<UserProfile> _profileSubscription;

  MainCubit(ObserveUserProfile getUserProfile) : super(const MainLoading()) {
    _profileSubscription = getUserProfile().listen(
      (profile) => emit(MainSuccess(isScraping: profile.isScraping)),
    );
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }
}
