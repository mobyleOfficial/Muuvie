import 'package:auth/auth.dart' show AuthRepository, Logout;
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/edit_profile/edit_profile_bloc.dart';
import 'package:profile_ui/edit_profile/edit_profile_state.dart';
import 'package:profile_ui/member/highlights/highlights_editor_bloc.dart';
import 'package:profile_ui/member/member_profile_bloc.dart';
import 'package:profile_ui/member/member_profile_state.dart';
import 'package:profile_ui/member/profile_header.dart';
import 'package:social_network/social_network.dart';
import 'package:shelves/shelves.dart';

import '../../helpers/fake_social_network_repository.dart';

ProfileDetails _profile({
  bool isSelf = false,
  bool isFollowing = false,
  bool followsMe = false,
  String? handle = 'ana.cinefila',
}) => ProfileDetails(
  id: 'ana-id',
  username: 'ana',
  handle: handle,
  displayName: 'Ana',
  pronouns: 'ela/dela',
  stats: const ProfileStats(watchLogs: 12, followers: 5),
  isFollowing: isFollowing,
  followsMe: followsMe,
  isSelf: isSelf,
);

class _FakeProfiles implements ProfilesRepository {
  ProfileDetails profile = _profile();
  Result<ProfileDetails>? saveResult;
  ProfileDraft? savedDraft;
  List<ProfileHighlight> highlights = const [];
  List<ProfileHighlight>? saved;

  @override
  Future<Result<ProfileDetails>> getProfile(String userId) async =>
      Success(profile);

  @override
  Future<Result<ProfileDetails>> updateMyProfile(ProfileDraft draft) async {
    savedDraft = draft;
    return saveResult ?? Success(profile);
  }

  @override
  Future<Result<HandleAvailability>> checkHandle(String handle) async =>
      Success(
        handle == 'tomado'
            ? HandleAvailability(
                handle: handle,
                available: false,
                problem: HandleProblem.taken,
              )
            : HandleAvailability(handle: handle, available: true),
      );

  @override
  Future<Result<List<ProfileHighlight>>> getHighlights(String userId) async =>
      Success(highlights);

  @override
  Future<Result<List<ProfileHighlight>>> saveHighlights(
    List<ProfileHighlight> highlights,
  ) async {
    saved = highlights;
    return Success(highlights);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _LegacyProfile implements ProfileRepository {
  @override
  Stream<UserProfile> watchProfile() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _Auth implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('header', () {
    testWidgets(
      'another profile shows the name, @, pronouns, follow and the counters',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ProfileHeader(
              profile: _profile(followsMe: true),
              onPrimaryAction: () {},
            ),
          ),
        );

        expect(find.text('Ana'), findsOneWidget);
        expect(find.text('@ana.cinefila'), findsOneWidget);
        expect(find.text('ela/dela'), findsOneWidget);
        expect(find.text('Seguir de volta'), findsOneWidget);
        expect(find.text('Segue você'), findsOneWidget);
        expect(find.text('Registros'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
      },
    );

    testWidgets(
      'a mutual can be whispered and the counters open the follow lists',
      (tester) async {
        FollowList? opened;
        var whispered = false;
        await tester.pumpWidget(
          _wrap(
            ProfileHeader(
              profile: _profile(
                isFollowing: true,
                followsMe: true,
              ).copyWith(mutual: true),
              onPrimaryAction: () {},
              onWhisper: () => whispered = true,
              onOpenFollows: (list) => opened = list,
            ),
          ),
        );

        await tester.tap(find.byTooltip('Sussurrar'));
        await tester.ensureVisible(find.text('Seguidores'));
        await tester.tap(find.text('Seguidores'));

        expect(whispered, true);
        expect(opened, FollowList.followers);
        expect(find.text('Seguindo'), findsWidgets);
      },
    );

    testWidgets(
      'my profile offers the edit and, without a handle, picking one',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ProfileHeader(
              profile: _profile(isSelf: true, handle: null),
              onPrimaryAction: () {},
              onPickHandle: () {},
            ),
          ),
        );

        expect(find.text('Editar perfil'), findsOneWidget);
        expect(
          find.text('Escolha seu @ para os amigos te acharem'),
          findsOneWidget,
        );
        expect(find.text('Seguir'), findsNothing);
      },
    );
  });

  group('follow', () {
    test(
      'following back counts the follower and takes the mutual flag from the server',
      () async {
        final profiles = _FakeProfiles()..profile = _profile(followsMe: true);
        final follows = FakeSocialNetworkRepository()
          ..followResult = const Success(
            FollowStatus(following: true, followedBy: true),
          );
        final cubit = MemberProfileCubit(
          userId: '@ana.cinefila',
          getProfile: GetProfileDetails(profiles),
          setFollowing: SetFollowing(follows),
        );
        await Future<void>.delayed(Duration.zero);

        expect(await cubit.toggleFollow(), isNull);

        final profile = (cubit.state as MemberProfileSuccess).profile;
        expect(follows.calls, ['follow ana-id']);
        expect(profile.isFollowing, true);
        expect(profile.mutual, true);
        expect(profile.stats.followers, 6);
        await cubit.close();
      },
    );

    test('a failed unfollow goes back to following', () async {
      final profiles = _FakeProfiles()..profile = _profile(isFollowing: true);
      final follows = FakeSocialNetworkRepository()
        ..followResult = const Failure(AppError.network);
      final cubit = MemberProfileCubit(
        userId: 'ana-id',
        getProfile: GetProfileDetails(profiles),
        setFollowing: SetFollowing(follows),
      );
      await Future<void>.delayed(Duration.zero);

      expect(await cubit.toggleFollow(), AppError.network);

      final profile = (cubit.state as MemberProfileSuccess).profile;
      expect(profile.isFollowing, true);
      expect(profile.stats.followers, 5);
      await cubit.close();
    });
  });

  group('edit profile', () {
    EditProfileCubit cubitFor(_FakeProfiles profiles) => EditProfileCubit(
      saveMyProfile: SaveMyProfile(profiles),
      checkHandle: CheckHandleAvailability(profiles),
      observeUserProfile: ObserveUserProfile(_LegacyProfile()),
      logout: Logout(_Auth()),
      profile: _profile(isSelf: true),
    );

    HandleStatus statusOf(EditProfileCubit cubit) =>
        (cubit.state as EditProfileReady).handleStatus;

    test(
      'the handle is checked after a pause; the current one needs no check',
      () async {
        final cubit = cubitFor(_FakeProfiles());

        cubit.onHandleChanged('ab');
        expect(statusOf(cubit), HandleStatus.invalid);

        cubit.onHandleChanged('@Ana.Cinefila');
        expect(statusOf(cubit), HandleStatus.unchanged);

        cubit.onHandleChanged('tomado');
        expect(statusOf(cubit), HandleStatus.checking);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(statusOf(cubit), HandleStatus.taken);

        cubit.onHandleChanged('livre.aqui');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(statusOf(cubit), HandleStatus.available);
        await cubit.close();
      },
    );

    test(
      'saving sends the accent color and a conflict marks the handle as taken',
      () async {
        final profiles = _FakeProfiles()
          ..saveResult = const Failure(AppError.conflict);
        final cubit = cubitFor(profiles)..onAccentColorChanged('#00897B');

        final error = await cubit.save(
          const ProfileDraft(displayName: 'Ana', handle: 'outra.ana'),
        );

        expect(error, EditProfileSaveError.handleTaken);
        expect(profiles.savedDraft?.accentColor, '#00897B');
        expect(statusOf(cubit), HandleStatus.taken);
        await cubit.close();
      },
    );
  });

  group('highlights editor', () {
    test(
      'every type gets a slot and only configured ones are saved, in order',
      () async {
        final profiles = _FakeProfiles()
          ..highlights = const [
            ProfileHighlight(
              type: HighlightType.soundtrack,
              soundtrackUrl: 'https://open.spotify.com/track/1',
            ),
          ];
        final cubit = HighlightsEditorCubit(
          getHighlights: GetProfileHighlights(profiles),
          saveHighlights: SaveProfileHighlights(profiles),
        );
        await Future<void>.delayed(Duration.zero);

        final slots = (cubit.state as HighlightsEditorReady).slots;
        expect(slots.map((s) => s.type), [
          HighlightType.soundtrack,
          HighlightType.top4,
          HighlightType.shelf,
          HighlightType.locadora,
        ]);

        cubit
          ..setTopMovies(const [
            HighlightMovie(movieId: 10, title: 'Halloween'),
          ])
          ..move(1, 0)
          ..setEnabled(HighlightType.soundtrack, false);
        expect(await cubit.save(), true);

        expect(profiles.saved?.map((h) => h.type), [
          HighlightType.top4,
          HighlightType.soundtrack,
        ]);
        expect(profiles.saved?.first.movieIds, [10]);
        expect(profiles.saved?.last.enabled, false);
        await cubit.close();
      },
    );

    test('a featured shelf is configured from the picked shelf', () async {
      final cubit = HighlightsEditorCubit(
        getHighlights: GetProfileHighlights(_FakeProfiles()),
        saveHighlights: SaveProfileHighlights(_FakeProfiles()),
      );
      await Future<void>.delayed(Duration.zero);

      cubit.setShelf(
        const Shelf(
          id: 7,
          ownerId: 'ana-id',
          name: 'Giallo',
          visibility: ContentVisibility.public,
          sortMode: ShelfSort.manual,
          pinned: false,
          totalMovies: 3,
          totalWatched: 1,
          posterPaths: [],
          isSelf: true,
        ),
      );

      final shelf = (cubit.state as HighlightsEditorReady).slots.firstWhere(
        (s) => s.type == HighlightType.shelf,
      );
      expect(shelf.shelfId, 7);
      expect(shelf.enabled, true);
      expect(HighlightsEditorCubit.isConfigured(shelf), true);
      await cubit.close();
    });
  });
}
