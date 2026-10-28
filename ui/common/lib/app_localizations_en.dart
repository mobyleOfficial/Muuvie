// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Muuvie';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get profile => 'Profile';

  @override
  String get moviesTab => 'Movies';

  @override
  String get reviewsTab => 'Reviews';

  @override
  String get unknownError => 'Unknown error';

  @override
  String movieRelease(String date) {
    return 'Release: $date';
  }

  @override
  String movieRating(String rating) {
    return 'Rating: $rating';
  }

  @override
  String movieRuntime(int minutes) {
    return 'Runtime: $minutes min';
  }

  @override
  String movieGenres(String genres) {
    return 'Genres: $genres';
  }

  @override
  String get socialTab => 'Social';

  @override
  String get newUserActivityTab => 'New Activity';

  @override
  String get searchHint => 'Movies, people, shelves and more';

  @override
  String get searchBrowse => 'Browse';

  @override
  String get searchBrowseReleaseDate => 'Release Date';

  @override
  String get searchBrowseGenre => 'Genre';

  @override
  String get searchBrowseCountryAndLanguage => 'Country & Language';

  @override
  String get searchBrowseGenreCountryLanguage => 'Genre, Country & Language';

  @override
  String get searchBrowseCountry => 'Country';

  @override
  String get searchBrowseLanguage => 'Language';

  @override
  String get searchBrowseService => 'Service';

  @override
  String get searchBrowseMostPopular => 'Most Popular';

  @override
  String get searchBrowseMostAnticipated => 'Most Anticipated';

  @override
  String get searchBrowseFeaturedLists => 'Featured Lists';

  @override
  String get profileTabProfile => 'Profile';

  @override
  String get profileTabDiary => 'Diary';

  @override
  String get profileTabReviews => 'Reviews';

  @override
  String get profileTabLists => 'Lists';

  @override
  String get profileTabWatchlist => 'Watchlist';

  @override
  String get profileTabShelves => 'Shelves';

  @override
  String get profileTabLocadoras => 'Locadoras';

  @override
  String locadoraShelvesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shelves',
      one: '1 shelf',
    );
    return '$_temp0';
  }

  @override
  String locadoraMoviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies',
      one: '1 movie',
    );
    return '$_temp0';
  }

  @override
  String get profileTabMarathons => 'Marathons';

  @override
  String get profileTabHistory => 'History';

  @override
  String get profileTabParticipations => 'Participations';

  @override
  String get profileTabCharts => 'Charts';

  @override
  String shelfWatchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count watched',
      one: '1 watched',
    );
    return '$_temp0';
  }

  @override
  String shelfMoviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies',
      one: '1 movie',
    );
    return '$_temp0';
  }

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileMoviesWatched => 'Watched';

  @override
  String get profileMoviesWatchedTitle => 'Movies watched';

  @override
  String get profileFollowingTitle => 'Following';

  @override
  String get profileFollowersTitle => 'Followers';

  @override
  String get profileEmptyMoviesWatched => 'No movies watched yet';

  @override
  String get profileEmptyFollowing => 'Not following anyone yet';

  @override
  String get profileEmptyFollowers => 'No followers yet';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get editProfileUsernameLabel => 'Username';

  @override
  String get editProfileUsernamePlaceholder => 'Enter your username';

  @override
  String get editProfileBioLabel => 'Bio';

  @override
  String get editProfileBioPlaceholder => 'Tell us about yourself';

  @override
  String get editProfileChangePhoto => 'Change photo';

  @override
  String get profileRecentMovies => 'Recent Movies';

  @override
  String get profileFavoriteMovies => 'Favorite Movies';

  @override
  String get profileRecentActivity => 'Recent Activity';

  @override
  String get profileMoviesSection => 'Movies';

  @override
  String get profileReviewsSection => 'Reviews';

  @override
  String get profileWatchlistSection => 'Watchlist';

  @override
  String get profileSeeAll => 'See all';

  @override
  String get socialFriendsTab => 'Friends';

  @override
  String get socialActivitiesTab => 'Activities';

  @override
  String get socialNoFriends => 'No friends yet';

  @override
  String get moviesListListsTab => 'Lists';

  @override
  String get moviesListArticlesTab => 'Articles';

  @override
  String get moviesListPopularThisWeek => 'Popular this week';

  @override
  String movieListDetailMoviesTab(int count) {
    return '$count Movies';
  }

  @override
  String movieListDetailCommentsTab(int count) {
    return '$count Comments';
  }

  @override
  String get movieListDetailCommentsPlaceholder => 'Comments coming soon';

  @override
  String get newUserActivityDraftsSection => 'Drafts';

  @override
  String get newUserActivityRecentSection => 'Recent';

  @override
  String get profileFollow => 'Follow';

  @override
  String get reviewDetailsBodyTitle => 'My Review';

  @override
  String get noResults => 'No results found';

  @override
  String get movieReviewTitle => 'Review';

  @override
  String get movieReviewNameHint => 'Review title';

  @override
  String get movieReviewAddReview => 'Add a review...';

  @override
  String get movieReviewRewatch => 'Rewatch';

  @override
  String get movieReviewFirstTime => 'First time';

  @override
  String get movieReviewTags => 'Tags';

  @override
  String get movieReviewTagMasterpiece => 'Masterpiece';

  @override
  String get movieReviewTagOverrated => 'Overrated';

  @override
  String get movieReviewTagUnderrated => 'Underrated';

  @override
  String get movieReviewTagMustWatch => 'Must Watch';

  @override
  String get movieReviewTagDisappointing => 'Disappointing';

  @override
  String get movieReviewTagFeelGood => 'Feel Good';

  @override
  String get movieReviewTagMindBending => 'Mind Bending';

  @override
  String get movieReviewTagEmotional => 'Emotional';

  @override
  String get movieReviewSend => 'Send review';

  @override
  String get deleteDraftTitle => 'Delete draft?';

  @override
  String get deleteDraftContent => 'This draft will be permanently deleted.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get reviewEditorTitle => 'Write a review';

  @override
  String get reviewEditorPlaceholder => 'Start writing your review...';

  @override
  String get reviewEditorClear => 'Clear all';

  @override
  String get reviewEditorClearConfirmTitle => 'Clear review?';

  @override
  String get reviewEditorClearConfirmContent => 'All text will be removed.';

  @override
  String get reviewDetailsAddReview => 'Add a review...';

  @override
  String get movieListDetailShowGridView => 'Show grid view';

  @override
  String get movieListDetailShowListView => 'Show list view';

  @override
  String get emptyStateErrorTitle => 'Something went wrong';

  @override
  String get emptyStateErrorMessage =>
      'An unexpected error occurred. Please try again.';

  @override
  String get emptyStateRetry => 'Retry';

  @override
  String get emptyStateNoItemsTitle => 'Nothing here yet';

  @override
  String get emptyStateNoItemsMessage => 'There are no items to display.';

  @override
  String get clearSearch => 'Clear';

  @override
  String get submitReviewTitle => 'Submit Review';

  @override
  String get submitReviewContent =>
      'Are you sure you want to submit this review? It will be published and the draft will be removed.';

  @override
  String get submit => 'Submit';

  @override
  String get submittingReview => 'Submitting review...';

  @override
  String get submissionFailed => 'Submission failed';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get ratingRequired => 'Please select a rating';

  @override
  String get reviewBodyRequired => 'Please write a review';

  @override
  String get tagsRequired => 'Please select at least one tag';

  @override
  String get movieDetailWhereToWatch => 'Where to Watch';

  @override
  String get movieDetailSynopsis => 'Synopsis';

  @override
  String get movieDetailUnmatched =>
      'We couldn\'t find this movie in our catalog. The details come from Filmow and may be incomplete.';

  @override
  String get movieDetailCast => 'Cast';

  @override
  String get movieDetailReviews => 'Reviews';

  @override
  String get movieDetailSimilar => 'Similar Movies';

  @override
  String movieDetailLikes(int count) {
    return '$count likes';
  }

  @override
  String movieDetailReviewCount(int count) {
    return '$count reviews';
  }

  @override
  String movieDetailListCount(int count) {
    return '$count lists';
  }

  @override
  String get movieDetailDirectedBy => 'Directed by';

  @override
  String movieDetailMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get movieDetailSeeAll => 'See all';

  @override
  String get movieDetailAboutTab => 'About';

  @override
  String movieDetailMovieReviews(String title) {
    return '$title Reviews';
  }

  @override
  String get comments => 'Comments';

  @override
  String get noComments => 'No comments yet';

  @override
  String get loadMore => 'Load More Comments';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get reviewDetailsShare => 'Share review';

  @override
  String get reviewDetailsLike => 'Like review';

  @override
  String get reviewDetailsUnlike => 'Unlike review';

  @override
  String get reviewDetailsLikeError => 'Couldn\'t update like. Try again.';

  @override
  String reviewDetailsLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
      zero: 'No likes yet',
    );
    return '$_temp0';
  }

  @override
  String get reviewDetailsCommentsTitle => 'Comments';

  @override
  String reviewDetailsViewAllComments(int count) {
    return 'View all ($count)';
  }

  @override
  String get reviewDetailsNoComments => 'No comments yet';

  @override
  String get reviewDetailsOtherReviewsForMovie =>
      'Other reviews for this movie';

  @override
  String reviewDetailsMoreFromAuthor(String author) {
    return 'More reviews from $author';
  }

  @override
  String reviewDetailsBy(String author) {
    return 'by $author';
  }

  @override
  String get reviewDetailsAnonymousAuthor => 'Anonymous';

  @override
  String get reviewDetailsNoBody => 'No review text';

  @override
  String get reviewDetailsLoadCommentsError => 'Couldn\'t load comments';

  @override
  String get reviewDetailsLoadRelatedError => 'Couldn\'t load related reviews';

  @override
  String get loginSubtitle => 'Sign in to discover and review movies';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get articleDetailShare => 'Share article';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginEmailHint => 'Enter your email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginButton => 'Log In';

  @override
  String get signUpNickname => 'Nickname';

  @override
  String get signUpNicknameHint => 'Choose a nickname';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get emailValidationError => 'Please enter a valid email address';

  @override
  String get passwordValidationError =>
      'Password must be at least 8 characters';

  @override
  String get passwordTooLongError => 'Password must be at most 72 characters';

  @override
  String get nicknameValidationError => 'Please enter a nickname';

  @override
  String get nicknameTooLongError => 'Nickname must be at most 30 characters';

  @override
  String get nicknameTakenError => 'This nickname is already taken';

  @override
  String get signUpConflictError => 'This email or nickname is already in use.';

  @override
  String get signUpBadRequestError =>
      'Please check your information and try again.';

  @override
  String get signUpNetworkError => 'No internet connection. Please try again.';

  @override
  String get signUpServerError => 'Server error. Please try again later.';

  @override
  String get loginError => 'Incorrect email or password.';

  @override
  String get loginGenericError =>
      'Something went wrong, please try again later.';

  @override
  String get loginWelcomeTitle => 'Good to see you!';

  @override
  String get loginNoAccount => 'New to Muuvie?';

  @override
  String get loginCreateAccountLink => 'Create an account';

  @override
  String get signUpHeadline => 'Get your ticket';

  @override
  String get signUpSubtitle => 'Create your account in less than a minute.';

  @override
  String get signUpHaveAccount => 'Already have an account?';

  @override
  String get signUpNicknameChecking => 'Checking availability…';

  @override
  String get signUpNicknameAvailable => 'Nickname available';

  @override
  String get signUpPasswordHelper => 'At least 8 characters';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get movieDetailWriteReview => 'Write a Review';

  @override
  String get movieDetailCreateList => 'Create a List';

  @override
  String get movieDetailActions => 'Actions';

  @override
  String get movieDetailWantToWatch => 'Want to Watch';

  @override
  String get movieDetailWatched => 'Watched';

  @override
  String get movieDetailYourRating => 'Your rating';

  @override
  String get movieListDeleteTitle => 'Delete List';

  @override
  String get movieListDeleteContent =>
      'Are you sure you want to delete this list? This action cannot be undone.';

  @override
  String get movieListDoneEditing => 'Done editing';

  @override
  String get movieListEditList => 'Edit list';

  @override
  String get movieListDeleteTooltip => 'Delete list';

  @override
  String get createListTitle => 'New List';

  @override
  String get createListSave => 'Save';

  @override
  String get createListAddMovies => 'Add Movies';

  @override
  String get createListNoMovies => 'No movies added yet';

  @override
  String get createListNameHint => 'Name';

  @override
  String get createListDescriptionHint => 'Description';

  @override
  String get createListMoviesSection => 'MOVIES';

  @override
  String createListMoviesCount(int count) {
    return 'MOVIES ($count)';
  }

  @override
  String get editProfileFilmowLogin => 'Login no Filmow';

  @override
  String get editProfileImportFilmow => 'Import data from Filmow';

  @override
  String get editProfileImportLetterboxd => 'Import data from Letterboxd';

  @override
  String get followLabel => 'Follow';

  @override
  String get followingLabel => 'Following';

  @override
  String get unfollowLabel => 'Unfollow';

  @override
  String routeReviewsTitle(String title) {
    return '$title Reviews';
  }

  @override
  String get routeReviews => 'Reviews';

  @override
  String get routeReleaseDate => 'Release Date';

  @override
  String get routeBrowse => 'Browse';

  @override
  String get routeMostPopular => 'Most Popular';

  @override
  String get routeMostAnticipated => 'Most Anticipated';

  @override
  String get routeFeaturedLists => 'Featured Lists';

  @override
  String get addShelvesSearchHint => 'Search shelves...';

  @override
  String get addShelvesEmptyState => 'Search for shelves to add';

  @override
  String get createLocadoraTitle => 'New Locadora';

  @override
  String get createLocadoraNamePrompt => 'What\'s the name of your locadora?';

  @override
  String get createLocadoraNameHint => 'Name';

  @override
  String get createLocadoraDescriptionPrompt =>
      'Describe your locadora (optional)';

  @override
  String get createLocadoraDescriptionHint => 'Description';

  @override
  String get createLocadoraVisibilityPrompt => 'Who can see this locadora?';

  @override
  String get createLocadoraSave => 'Create Locadora';

  @override
  String get createShelfTitle => 'New Shelf';

  @override
  String get createShelfNamePrompt => 'What\'s the name of your shelf?';

  @override
  String get createShelfNameHint => 'Name';

  @override
  String get createShelfDescriptionPrompt => 'Describe your shelf (optional)';

  @override
  String get createShelfDescriptionHint => 'Description';

  @override
  String get createShelfColorPrompt => 'Choose a color for your shelf';

  @override
  String get createShelfVisibilityPrompt => 'Who can see this shelf?';

  @override
  String get createShelfVisibilityPublic => 'Public';

  @override
  String get createShelfVisibilityPrivate => 'Private';

  @override
  String get createShelfVisibilityMutuals => 'Mutuals';

  @override
  String get createShelfSave => 'Create Shelf';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityMutual => 'Mutuals';

  @override
  String get visibilitySecret => 'Secret';

  @override
  String get watchModeWatched => 'Watched';

  @override
  String get watchModeMinutes => 'Minutes';

  @override
  String get watchModePercent => 'Percentage';

  @override
  String get watchVenueCinema => 'Cinema';

  @override
  String get watchVenueStreaming => 'Streaming';

  @override
  String get watchVenueTv => 'TV';

  @override
  String get watchVenuePhysicalMedia => 'Physical media';

  @override
  String get watchVenueFestival => 'Festival';

  @override
  String get watchVenueOther => 'Other';

  @override
  String get watchStatusWatched => 'Watched';

  @override
  String get watchStatusWantToWatch => 'Want to watch';

  @override
  String get systemShelfWatched => 'Watched';

  @override
  String get systemShelfWatchlist => 'Want to watch';

  @override
  String get ratingLabelFavorite => 'Favorite';

  @override
  String get ratingLabelLoved => 'Loved it';

  @override
  String get ratingLabelLiked => 'Liked it';

  @override
  String get ratingLabelNeutral => 'Neutral';

  @override
  String get ratingLabelNotForMe => 'Not for me';

  @override
  String get ratingLabelAbandoned => 'Abandoned';

  @override
  String get ratingLabelOnHold => 'On hold';

  @override
  String get shelfSortManual => 'Manual';

  @override
  String get shelfSortTitle => 'Title';

  @override
  String get shelfSortDirector => 'Director';

  @override
  String get shelfSortReleaseYear => 'Release year';

  @override
  String get shelfSortAddedNewest => 'Recently added';

  @override
  String get shelfSortAddedOldest => 'First added';

  @override
  String get shelfSortUpdatedNewest => 'Recently updated';

  @override
  String get shelfSortWatchedFirst => 'Watched first';

  @override
  String get shelfSortWatchedLast => 'Watched last';

  @override
  String get shelfSortProgressHighest => 'Most progress';

  @override
  String get shelfSortRatingHighest => 'By rating';

  @override
  String get emotionCuriosity => 'Curiosity';

  @override
  String get emotionInspiration => 'Inspiration';

  @override
  String get emotionReflection => 'Reflection';

  @override
  String get emotionRelaxation => 'Relaxation';

  @override
  String get emotionMoved => 'Moved';

  @override
  String get emotionNostalgia => 'Nostalgia';

  @override
  String get emotionGratitude => 'Gratitude';

  @override
  String get emotionAffection => 'Affection';

  @override
  String get emotionSurprise => 'Surprise';

  @override
  String get emotionPassion => 'Passion';

  @override
  String get emotionFun => 'Fun';

  @override
  String get emotionJoy => 'Joy';

  @override
  String get emotionHumor => 'Humor';

  @override
  String get emotionFreakOut => 'Freak-out';

  @override
  String get emotionAnxiety => 'Anxiety';

  @override
  String get emotionDistress => 'Distress';

  @override
  String get emotionTension => 'Tension';

  @override
  String get emotionDistraction => 'Distraction';

  @override
  String get emotionConfusion => 'Confusion';

  @override
  String get emotionSuspicion => 'Suspicion';

  @override
  String get emotionIrritation => 'Irritation';

  @override
  String get emotionAnger => 'Anger';

  @override
  String get emotionIndignation => 'Indignation';

  @override
  String get emotionFear => 'Fear';

  @override
  String get emotionVulnerability => 'Vulnerability';

  @override
  String get emotionEmbarrassment => 'Embarrassment';

  @override
  String get emotionFrustration => 'Frustration';

  @override
  String get emotionSadness => 'Sadness';

  @override
  String get emotionMelancholy => 'Melancholy';

  @override
  String get emotionTiredness => 'Tiredness';

  @override
  String get emotionBoredom => 'Boredom';

  @override
  String get emotionConnection => 'Connection';

  @override
  String get emotionFocus => 'Focus';

  @override
  String get emotionIntensity => 'Intensity';

  @override
  String get emotionEnthusiasm => 'Enthusiasm';

  @override
  String get emotionExcitement => 'Thrill';

  @override
  String get emotionEuphoria => 'Euphoria';

  @override
  String get emotionShock => 'Shock';

  @override
  String get emotionHorror => 'Horror';

  @override
  String get emotionDisgust => 'Disgust';

  @override
  String get emotionDevastation => 'Devastation';

  @override
  String get emotionGrudge => 'Grudge';

  @override
  String get emotionIndifference => 'Indifference';

  @override
  String get emotionApathy => 'Apathy';

  @override
  String get editProfileLogout => 'Log out';

  @override
  String get editProfileLogoutConfirmTitle => 'Log out of Muuvie?';

  @override
  String get editProfileLogoutConfirmMessage => 'You can log back in anytime.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get navAtts => 'Atts';

  @override
  String get navProgramacao => 'Schedule';

  @override
  String get navCatalogo => 'Catalog';

  @override
  String get navNoticias => 'News';

  @override
  String get attsWhispers => 'Whispers';

  @override
  String get programacaoMaratonasTab => 'Marathons';

  @override
  String get programacaoCineClubesTab => 'Film clubs';

  @override
  String get programacaoParticipatingFilter => 'Joined';

  @override
  String get programacaoMaratonasComingSoon =>
      'Movie marathons with challenges and deadlines will show up here.';

  @override
  String get programacaoCineClubesComingSoon =>
      'Film clubs: one movie, one period and a discussion day.';

  @override
  String colorPickerOption(int index, int total) {
    return 'Color $index of $total';
  }

  @override
  String emotionPickerCount(int count, int max) {
    return '$count of $max emotions';
  }

  @override
  String movieProgressMinutes(int watched, int total) {
    return '$watched of $total min';
  }

  @override
  String get editShelfTitle => 'Edit shelf';

  @override
  String get shelfSave => 'Save';

  @override
  String get systemShelfLockedHint =>
      'Default shelf: it can\'t be renamed or deleted';

  @override
  String get shelfEdit => 'Edit';

  @override
  String get shelfDelete => 'Delete shelf';

  @override
  String shelfDeleteConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get shelfDeleteConfirmMessage => 'The movies stay in your history.';

  @override
  String get shelfPin => 'Pin to top';

  @override
  String get shelfUnpin => 'Unpin';

  @override
  String get shelfReorder => 'Reorder shelves';

  @override
  String get shelfReorderDone => 'Done';

  @override
  String get shelfPinned => 'Pinned';

  @override
  String shelfWatchedOfTotal(int watched, int total) {
    return '$watched/$total watched';
  }

  @override
  String get shelfNew => 'New shelf';

  @override
  String get shelfAddMovies => 'Add movies';

  @override
  String get shelfFilterWatched => 'Watched';

  @override
  String get shelfFilterNotWatched => 'Not watched';

  @override
  String get shelfFilterDecade => 'Decade';

  @override
  String shelfFilterDecadeValue(int decade) {
    return '${decade}s';
  }

  @override
  String get shelfFilterGenre => 'Genre';

  @override
  String get shelfFilterAny => 'Any';

  @override
  String get shelfFilterClear => 'Clear filters';

  @override
  String get shelfEmptyFiltered => 'No movies match these filters';

  @override
  String get shelfSortBy => 'Sort by';

  @override
  String get shelfSortApplyOnce => 'Apply only once';

  @override
  String get shelfSortApply => 'Apply';

  @override
  String get shelfManualOrder => 'Reorder movies';

  @override
  String get shelfMovieRemove => 'Remove from shelf';

  @override
  String get shelfMovieMoveTo => 'Move to…';

  @override
  String get shelfMovieCopyTo => 'Copy to…';

  @override
  String get shelfMoveAll => 'Move all to…';

  @override
  String get shelfCopyAll => 'Copy all to…';

  @override
  String get shelfPickTarget => 'Choose a shelf';

  @override
  String get shelfUnmarkWatchedTitle => 'Unmark as watched?';

  @override
  String get shelfUnmarkWatchedMessage => 'Your logs of this movie are kept.';

  @override
  String get shelfUnmarkWatchedConfirm => 'Unmark';

  @override
  String get shelfActionError => 'Couldn\'t finish that. Try again.';

  @override
  String get addToShelvesAction => 'Add to shelf…';

  @override
  String get addToShelvesTitle => 'Add to shelves';

  @override
  String get addToShelvesSave => 'Save';

  @override
  String addToShelvesSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shelves',
      one: '1 shelf',
    );
    return 'Saved to $_temp0';
  }

  @override
  String get watchLogAction => 'Log session';

  @override
  String get watchLogTitle => 'Log a session';

  @override
  String get watchLogEditTitle => 'Edit session';

  @override
  String get watchLogDate => 'Date';

  @override
  String get watchLogProgress => 'Progress';

  @override
  String watchLogPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String watchLogMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get watchLogVenue => 'Where you watched';

  @override
  String get watchLogProvider => 'Service or theater (optional)';

  @override
  String get watchLogEmotions => 'How did it feel?';

  @override
  String get watchLogAddGif => 'Add GIF';

  @override
  String get watchLogRemoveGif => 'Remove GIF';

  @override
  String get watchLogComment => 'Comment (optional)';

  @override
  String get watchLogSpoiler => 'Contains spoilers';

  @override
  String get watchLogVisibility => 'Who can see it';

  @override
  String get watchLogSave => 'Save';

  @override
  String get watchLogSaved => 'Session logged';

  @override
  String get watchLogError => 'Couldn\'t save the session. Try again.';

  @override
  String get gifSearchHint => 'Search GIFs';

  @override
  String get gifRecent => 'Recent';

  @override
  String get gifSearchUnavailable => 'GIF search is unavailable right now.';

  @override
  String get gifPickerTitle => 'Pick a GIF';

  @override
  String get gifLabel => 'GIF';

  @override
  String get ratingTitle => 'Rate';

  @override
  String get ratingPrompt => 'Which option best reflects your final rating?';

  @override
  String get ratingReview => 'Comment (optional)';

  @override
  String get ratingCreateLog => 'Create a 100% session';

  @override
  String get ratingSave => 'Save rating';

  @override
  String get ratingRemove => 'Remove rating';

  @override
  String get ratingError => 'Couldn\'t save the rating. Try again.';

  @override
  String get rewatchAction => 'Watch again';

  @override
  String get rewatchStarted => 'Rewatch started';

  @override
  String get watchingNowTitle => 'Watching now';

  @override
  String watchProgressPercent(int percent) {
    return '$percent% watched';
  }

  @override
  String get watchStateError => 'Couldn\'t update. Try again.';

  @override
  String get historyTitle => 'History';

  @override
  String historyMinutes(int minutes) {
    return '$minutes min watched';
  }

  @override
  String historySessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String historyRewatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rewatches',
      one: '1 rewatch',
      zero: 'No rewatches',
    );
    return '$_temp0';
  }

  @override
  String get historyFirstWatch => 'First watch';

  @override
  String historyRewatch(int number) {
    return 'Rewatch $number';
  }

  @override
  String get historyEmpty => 'No sessions yet';

  @override
  String get historyEdit => 'Edit';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyDeleteTitle => 'Delete this session?';

  @override
  String get historyDeleteMessage =>
      'The progress is recalculated. The movie stays in Watched.';

  @override
  String get spoilerReveal => 'Spoiler. Tap to show';

  @override
  String get threadCommentsTitle => 'Comments';

  @override
  String get threadCommentHint => 'Write a comment';

  @override
  String get threadCommentSend => 'Send';

  @override
  String get threadCommentDelete => 'Delete comment';

  @override
  String get threadCommentsEmpty => 'No comments yet';

  @override
  String get threadCommentError => 'Couldn\'t send the comment. Try again.';

  @override
  String get editProfileImportSection => 'Import data';

  @override
  String get importTitle => 'Import';

  @override
  String get importIntro =>
      'Bring your Filmow history: watched movies go to Watched, your watchlist to Want to watch and your lists become shelves. Nothing is saved before you confirm.';

  @override
  String get importStartFilmow => 'Sign in to Filmow and import';

  @override
  String get importFilmowWaitTitle => 'Wait after signing in';

  @override
  String get importFilmowWaitMessage =>
      'After you sign in to Filmow, you MUST wait for the screen to close on its own. Don\'t close it yourself, or the import won\'t start.';

  @override
  String get importFilmowWaitConfirm => 'Got it';

  @override
  String get importHistoryTitle => 'Previous imports';

  @override
  String get importInProgress => 'You already have an import running.';

  @override
  String get importStartError => 'Couldn\'t start the import. Try again.';

  @override
  String get importActionError => 'Something went wrong. Try again.';

  @override
  String importStatusLabel(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Starting',
      'reading': 'Reading',
      'preview': 'Waiting for you',
      'importing': 'Importing',
      'done': 'Done',
      'failed': 'Failed',
      'cancelled': 'Cancelled',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get importReadingTitle => 'Reading your Filmow profile';

  @override
  String get importReadingMessage =>
      'This can take a few minutes. You can leave this screen: the preview will be waiting for you here.';

  @override
  String get importPreviewTitle => 'Ready to import';

  @override
  String importPreviewWatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies → Watched',
      one: '1 movie → Watched',
    );
    return '$_temp0';
  }

  @override
  String importPreviewWatchlist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies → Want to watch',
      one: '1 movie → Want to watch',
    );
    return '$_temp0';
  }

  @override
  String importPreviewFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favorites become Favorite',
      one: '1 favorite becomes Favorite',
    );
    return '$_temp0';
  }

  @override
  String importPreviewLogs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dated sessions',
      one: '1 dated session',
    );
    return '$_temp0';
  }

  @override
  String get importPreviewLists => 'Lists → shelves';

  @override
  String get importPreviewNoLists => 'No lists found on your profile.';

  @override
  String get importPreviewVisibility =>
      'Who can see the new shelves and sessions';

  @override
  String get importConfirm => 'Import';

  @override
  String get importCancel => 'Cancel import';

  @override
  String get importImportingTitle => 'Importing your history';

  @override
  String importImportingProgress(int processed, int total) {
    return '$processed of $total';
  }

  @override
  String get importImportingMessage =>
      'You can leave this screen: we\'ll let you know when it\'s done.';

  @override
  String get importDoneTitle => 'Import finished';

  @override
  String importDoneShelves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lists became shelves',
      one: '1 list became a shelf',
    );
    return '$_temp0';
  }

  @override
  String importDoneKept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies you already had were kept as they were',
      one: '1 movie you already had was kept as it was',
    );
    return '$_temp0';
  }

  @override
  String importReviewUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Review $count movies',
      one: 'Review 1 movie',
    );
    return '$_temp0';
  }

  @override
  String get importAgain => 'Import again';

  @override
  String get importFailedTitle => 'The import failed';

  @override
  String get importCancelledTitle => 'Import cancelled';

  @override
  String get importCancelledMessage => 'Nothing was saved.';

  @override
  String get importUnmatchedTitle => 'Confirm movies';

  @override
  String get importUnmatchedHint =>
      'We weren\'t sure about these movies. They are already on your shelves: pick the right one or skip.';

  @override
  String get importUnmatchedSkip => 'Skip';

  @override
  String get importUnmatchedNoCandidates => 'No suggestions found.';

  @override
  String get importUnmatchedMatched => 'Confirmed';

  @override
  String get importUnmatchedSkipped => 'Skipped';

  @override
  String get importUnmatchedEmpty => 'Every movie was matched.';

  @override
  String get importFinishedSnack => 'Your Filmow import is done';

  @override
  String get importSeeReport => 'See report';

  @override
  String get watchedEmptyImport => 'Already use Filmow? Bring your history';

  @override
  String get locadoraNew => 'New locadora';

  @override
  String get editLocadoraTitle => 'Edit locadora';

  @override
  String get locadoraEdit => 'Edit';

  @override
  String get locadoraDelete => 'Delete locadora';

  @override
  String locadoraDeleteConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get locadoraDeleteConfirmMessage =>
      'The shelves stay on your profile.';

  @override
  String get locadoraReorder => 'Reorder locadoras';

  @override
  String get locadoraEmptyTitle => 'No locadoras yet';

  @override
  String get locadoraEmptyMessage =>
      'Group your shelves like the aisles of a video store.';

  @override
  String get locadoraEmptyOtherMessage => 'Nothing to show here yet.';

  @override
  String get locadoraHideInProfile => 'Hide its shelves from the Shelves tab';

  @override
  String get locadoraHideInFilters => 'Hide its shelves from the filters';

  @override
  String locadoraByOwner(String username) {
    return 'by @$username';
  }

  @override
  String get locadoraChooseShelves => 'Choose shelves';

  @override
  String get locadoraNoShelves => 'This locadora has no shelves yet.';

  @override
  String get locadoraPickShelvesTitle => 'Shelves in the locadora';

  @override
  String get locadoraPickShelvesEmpty => 'Create a shelf first.';

  @override
  String get locadoraShelfEmpty => 'Empty shelf';

  @override
  String locadoraProgress(int watched, int total) {
    return '$watched of $total movies watched';
  }

  @override
  String get locadoraOpenShelf => 'Open shelf';

  @override
  String get profileTabHighlights => 'Highlights';

  @override
  String get profileTabLogs => 'Sessions';

  @override
  String get profileStatWatched => 'Watched';

  @override
  String get profileStatCineclubes => 'CineClubes';

  @override
  String get profileFollowsYou => 'Follows you';

  @override
  String get profilePickHandleTip => 'Pick your @ so friends can find you';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get profileShare => 'Share profile';

  @override
  String profileShareText(String name, String link) {
    return '$name on Muuvie: $link';
  }

  @override
  String profileWatchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies watched',
      one: '1 movie watched',
      zero: 'no movies watched',
    );
    return '$_temp0';
  }

  @override
  String get highlightsEdit => 'Edit highlights';

  @override
  String get highlightsEmptyOwnTitle => 'Show off your taste';

  @override
  String get highlightsEmptyOwnMessage =>
      'Pick a top 4, a shelf, a locadora and a soundtrack.';

  @override
  String get highlightsEmptyOther => 'Nothing highlighted yet.';

  @override
  String highlightTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'top4': 'Top 4',
      'shelf': 'Featured shelf',
      'locadora': 'Featured locadora',
      'soundtrack': 'Soundtrack',
      'other': 'Highlight',
    });
    return '$_temp0';
  }

  @override
  String highlightSoundtrackOpen(String service) {
    String _temp0 = intl.Intl.selectLogic(service, {
      'youtubeMusic': 'Listen on YouTube Music',
      'other': 'Listen on Spotify',
    });
    return '$_temp0';
  }

  @override
  String get highlightChoose => 'Choose';

  @override
  String get highlightChange => 'Change';

  @override
  String get highlightNotSet => 'Not set';

  @override
  String get highlightTop4Pick => 'Pick up to 4 movies you watched, in order.';

  @override
  String highlightTop4Count(int count) {
    return '$count of 4';
  }

  @override
  String get highlightTop4Empty => 'Mark movies as watched to pick your top 4.';

  @override
  String get highlightSoundtrackHint => 'Spotify or YouTube Music link';

  @override
  String get highlightSoundtrackInvalid =>
      'Paste a link from open.spotify.com or music.youtube.com';

  @override
  String get highlightsSaveError => 'Could not save the highlights';

  @override
  String get diaryEmptyOwn => 'Your sessions show up here.';

  @override
  String get diaryEmptyOther => 'No sessions to show.';

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileSaveError => 'Could not save the profile';

  @override
  String get editProfileInvalidField =>
      'Check the fields: a link or an image may be invalid';

  @override
  String get editProfileDisplayNameLabel => 'Name';

  @override
  String get editProfileHandleLabel => '@handle';

  @override
  String get editProfileHandleHint => '5 to 30 letters, digits, . or _';

  @override
  String get editProfileHandleChecking => 'Checking…';

  @override
  String get editProfileHandleAvailable => 'Available';

  @override
  String get editProfileHandleTaken => 'This @ is already taken';

  @override
  String get editProfileHandleInvalid =>
      'Use 5 to 30 lowercase letters, digits, dots or underscores';

  @override
  String get editProfilePronounsLabel => 'Pronouns';

  @override
  String get editProfilePronounsPlaceholder => 'e.g. she/her';

  @override
  String get editProfileLinksLabel => 'Links';

  @override
  String get editProfileAddLink => 'Add link';

  @override
  String get editProfileAccentLabel => 'Accent color';

  @override
  String get editProfileAccentDefault => 'Default';

  @override
  String get editProfileImagesLabel => 'Photo and banner';

  @override
  String get editProfileImagesHint =>
      'Paste an image link. Uploading files comes later.';

  @override
  String get editProfileAvatarUrlLabel => 'Photo link';

  @override
  String get editProfileBannerUrlLabel => 'Banner link';

  @override
  String get discoverReleases => 'In theaters and new';

  @override
  String get discoverShelves => 'Most popular shelves';

  @override
  String get discoverLocadoras => 'Community locadoras';

  @override
  String get discoverProfiles => 'Cinéfilos to follow';

  @override
  String get discoverExplore => 'Explore the catalog';

  @override
  String get discoverEmpty => 'Nothing here yet.';

  @override
  String get discoverFeatured => 'Featured';

  @override
  String get searchTabMovies => 'Movies';

  @override
  String get newsAllSources => 'All';

  @override
  String get newsRead => 'Read';

  @override
  String get newsMoviesTitle => 'Movies in this story';

  @override
  String get newsWantToWatch => 'Want to watch';

  @override
  String get newsInWantToWatch => 'In Want to watch';

  @override
  String get newsWatched => 'Already watched';

  @override
  String get newsAddToShelf => 'Add to shelf';

  @override
  String newsAddedToWatchlist(String title) {
    return '$title is in Want to watch';
  }

  @override
  String get newsWantToWatchError => 'Could not add the movie';

  @override
  String get personDirected => 'Directed';

  @override
  String get personActed => 'Cast';

  @override
  String get personNoCredits => 'No movies from the catalog yet.';

  @override
  String get attsScopeAll => 'Everyone';

  @override
  String get attsScopeFollowing => 'Following';

  @override
  String get attsScopeMe => 'Just me';

  @override
  String get attsEmptyTitle => 'Nothing here yet';

  @override
  String get attsEmptyFollowing => 'Follow people to see what they watch.';

  @override
  String get attsEmptyMe => 'What you log, rate and create shows up here.';

  @override
  String attsWhispersUnread(int count) {
    return 'Whispers, $count unread';
  }

  @override
  String get attsFollowsAction => 'Following and followers';

  @override
  String get activityVerbSession => 'logged a session of';

  @override
  String get activityVerbFinished => 'watched';

  @override
  String get activityVerbRewatched => 'rewatched';

  @override
  String get activityVerbRating => 'rated';

  @override
  String get activityVerbNewShelf => 'created the shelf';

  @override
  String get activityVerbFeaturedShelf => 'featured the shelf';

  @override
  String get activityVerbNewLocadora => 'opened the locadora';

  @override
  String get activityVerbWatchingNow => 'is watching';

  @override
  String activityVerbImported(String source) {
    return 'imported their movies from $source';
  }

  @override
  String get activityVerbOther => 'did something new';

  @override
  String activityImportCounts(int watched, int watchlist) {
    return '$watched watched · $watchlist to watch';
  }

  @override
  String get activityLove => 'Love';

  @override
  String get activityUnlove => 'Remove love';

  @override
  String activityLovesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loves',
      one: '1 love',
    );
    return '$_temp0';
  }

  @override
  String get activityMoreOptions => 'More options';

  @override
  String get activityHide => 'Hide from others';

  @override
  String get activityShow => 'Show it again';

  @override
  String get activityHidden => 'Hidden';

  @override
  String get activityHiddenSnack => 'Only you see it now';

  @override
  String get timeNow => 'now';

  @override
  String timeMinutes(int count) {
    return '$count min';
  }

  @override
  String timeHours(int count) {
    return '$count h';
  }

  @override
  String timeDays(int count) {
    return '$count d';
  }

  @override
  String get followBackLabel => 'Follow back';

  @override
  String get followRateLimited =>
      'Too many follows in a row. Try again in a minute.';

  @override
  String get followError => 'Could not update the follow';

  @override
  String get followsEmptyFollowers => 'No followers yet.';

  @override
  String get followsEmptyFollowing => 'Not following anyone yet.';

  @override
  String get whispersEmptyTitle => 'No whispers yet';

  @override
  String get whispersEmptyMessage =>
      'Whisper from the profile of someone who follows you back.';

  @override
  String get whisperAction => 'Whisper';

  @override
  String get whisperHint => 'Write a whisper';

  @override
  String get whisperSend => 'Send';

  @override
  String get whisperDisabled =>
      'You can only whisper while you follow each other.';

  @override
  String get whisperMutualLost =>
      'You no longer follow each other. This conversation is read-only.';

  @override
  String get whisperMutualRestored => 'You follow each other again.';

  @override
  String get whisperSendError => 'Could not send. Try again.';

  @override
  String get whisperRateLimited => 'Slow down: too many whispers in a minute.';

  @override
  String whisperYou(String body) {
    return 'You: $body';
  }

  @override
  String whisperStart(String name) {
    return 'Say hi to $name';
  }

  @override
  String whisperUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
    );
    return '$_temp0';
  }

  @override
  String get movieFollowingActivity => 'From people you follow';

  @override
  String get maratonaSearchHint => 'Search marathons';

  @override
  String get maratonaFilterCurated => 'Curated';

  @override
  String get maratonaFilterOpen => 'No password';

  @override
  String get maratonaFilterFinished => 'Include finished';

  @override
  String get maratonaFilterMine => 'Created by me';

  @override
  String get maratonaCreate => 'Create marathon';

  @override
  String get maratonaListEmptyTitle => 'No marathons here';

  @override
  String get maratonaListEmptyMessage => 'Create one or change the filters.';

  @override
  String get maratonaParticipatingEmpty =>
      'You have not joined a marathon yet.';

  @override
  String get maratonaStatusUpcoming => 'Starts soon';

  @override
  String get maratonaStatusActive => 'Running';

  @override
  String get maratonaStatusFinished => 'Finished';

  @override
  String get maratonaStatusCancelled => 'Cancelled';

  @override
  String maratonaPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String maratonaParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String maratonaChallengesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count challenges',
      one: '1 challenge',
    );
    return '$_temp0';
  }

  @override
  String get maratonaJoined => 'Joined';

  @override
  String get maratonaLocked => 'Password';

  @override
  String get maratonaTabAbout => 'About';

  @override
  String get maratonaTabChallenges => 'Challenges';

  @override
  String get maratonaTabQueue => 'My queue';

  @override
  String get maratonaTabDiscovery => 'Discover';

  @override
  String get maratonaTabRanking => 'Ranking';

  @override
  String get maratonaJoin => 'Join';

  @override
  String get maratonaLeave => 'Leave';

  @override
  String get maratonaLeaveTitle => 'Leave this marathon?';

  @override
  String get maratonaLeaveMessage =>
      'Your queue shelf and the challenges you marked will be removed.';

  @override
  String get maratonaJoinTitle => 'Join the marathon';

  @override
  String get maratonaJoinLevel => 'Level';

  @override
  String get maratonaJoinTeam => 'Team';

  @override
  String get maratonaNoTeam => 'No team';

  @override
  String get maratonaPassword => 'Password';

  @override
  String get maratonaWrongPassword => 'Wrong password.';

  @override
  String get maratonaClosed => 'This marathon is not open.';

  @override
  String get maratonaActionError => 'Could not complete. Try again.';

  @override
  String maratonaOwnerBy(String name) {
    return 'By $name';
  }

  @override
  String get maratonaCoOwners => 'Co-owners';

  @override
  String get maratonaLevels => 'Levels';

  @override
  String get maratonaTeams => 'Teams';

  @override
  String get maratonaPrizes => 'Prizes';

  @override
  String get maratonaProgressFeed => 'Activity';

  @override
  String get maratonaProgressEmpty => 'Nothing happened yet.';

  @override
  String maratonaMyProgress(int done, int total) {
    return '$done of $total challenges';
  }

  @override
  String get maratonaSocialLink => 'Community';

  @override
  String get maratonaEdit => 'Edit';

  @override
  String get maratonaCancel => 'Cancel marathon';

  @override
  String get maratonaCancelMessage =>
      'Nobody will be able to join or mark challenges. This cannot be undone.';

  @override
  String get maratonaCancelConfirm => 'Cancel it';

  @override
  String get maratonaKeep => 'Keep';

  @override
  String get maratonaChallengeAuto => 'Checked automatically';

  @override
  String get maratonaChallengeManual => 'Marked by hand';

  @override
  String get maratonaChallengeDaily => 'Daily';

  @override
  String get maratonaTeamOnly => 'Team challenges';

  @override
  String get maratonaChallengeDone => 'Done';

  @override
  String get maratonaChallengeOpen => 'To do';

  @override
  String get maratonaLinkMovie => 'Mark with a movie';

  @override
  String get maratonaLinkFromQueue => 'From your queue';

  @override
  String get maratonaLinkFromWatched => 'From your watched movies';

  @override
  String get maratonaUnlink => 'Remove';

  @override
  String get maratonaLinkAuto => 'from a session';

  @override
  String get maratonaLinksEmpty => 'No movie yet.';

  @override
  String get maratonaNotRunning =>
      'Challenges can be marked while the marathon runs.';

  @override
  String get maratonaJoinToMark => 'Join to mark challenges.';

  @override
  String get maratonaPickerEmpty => 'No movies here.';

  @override
  String get maratonaQueueEmpty =>
      'Your queue is empty. Add movies from Discover.';

  @override
  String get maratonaQueueOpen => 'Open shelf';

  @override
  String get maratonaQueueJoin => 'Join to get a queue.';

  @override
  String get maratonaAddToQueue => 'Add to queue';

  @override
  String get maratonaAddedToQueue => 'Added to your queue';

  @override
  String get maratonaDiscoveryPick => 'Pick a challenge';

  @override
  String get maratonaDiscoveryNone =>
      'No challenge here has criteria to suggest movies.';

  @override
  String get maratonaRankingUsers => 'Participants';

  @override
  String get maratonaRankingEmpty => 'No one has completed a challenge yet.';

  @override
  String maratonaRankingPosition(int position) {
    return '#$position';
  }

  @override
  String maratonaTeamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get maratonaEditorNewTitle => 'New marathon';

  @override
  String get maratonaEditorEditTitle => 'Edit marathon';

  @override
  String get maratonaEditorFromScratch => 'Start from scratch';

  @override
  String get maratonaEditorTemplates => 'Or start from a template';

  @override
  String maratonaTemplateDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get maratonaStepDetails => 'Details';

  @override
  String get maratonaStepLevels => 'Levels and teams';

  @override
  String get maratonaStepPrizes => 'Prizes and privacy';

  @override
  String get maratonaFieldTitle => 'Title';

  @override
  String get maratonaFieldSlug => 'Address';

  @override
  String maratonaSlugHelp(String slug) {
    return 'Letters, numbers and hyphens: /m/$slug';
  }

  @override
  String get maratonaSlugTaken => 'This address is taken.';

  @override
  String get maratonaSlugInvalid =>
      'Use 3 to 50 lowercase letters, numbers or hyphens.';

  @override
  String get maratonaSlugAvailable => 'Available';

  @override
  String get maratonaFieldDescription => 'Description';

  @override
  String get maratonaFieldStart => 'Starts on';

  @override
  String get maratonaFieldEnd => 'Ends on';

  @override
  String get maratonaFieldColor => 'Color';

  @override
  String get maratonaFieldLogo => 'Logo (image link)';

  @override
  String get maratonaFieldSocial => 'Community link';

  @override
  String get maratonaAddCategory => 'Add category';

  @override
  String get maratonaCategoryName => 'Category name';

  @override
  String get maratonaAddChallenge => 'Add challenge';

  @override
  String get maratonaChallengeDescription => 'Challenge';

  @override
  String get maratonaCriteria => 'Automatic criteria';

  @override
  String get maratonaCriteriaNone => 'No criteria: marked by hand';

  @override
  String get maratonaCriteriaGenres => 'Genres';

  @override
  String get maratonaCriteriaDecades => 'Decades';

  @override
  String get maratonaCriteriaCountries => 'Countries';

  @override
  String get maratonaCriteriaLanguages => 'Original language';

  @override
  String get maratonaCriteriaRuntimeMin => 'At least (minutes)';

  @override
  String get maratonaCriteriaRuntimeMax => 'At most (minutes)';

  @override
  String get maratonaCriteriaVote => 'Minimum TMDB score';

  @override
  String get maratonaCriteriaCodesHint =>
      'Codes separated by commas, like BR, FR';

  @override
  String get maratonaCriteriaKept =>
      'Other criteria of this challenge are kept.';

  @override
  String get maratonaCriteriaApply => 'Apply';

  @override
  String get maratonaCriteriaClear => 'Clear criteria';

  @override
  String get maratonaMinChallenges => 'Challenges to complete';

  @override
  String get maratonaAddLevel => 'Add level';

  @override
  String get maratonaLevelName => 'Level name';

  @override
  String get maratonaDefaultLevel =>
      'Without levels, finishing every challenge completes the marathon.';

  @override
  String get maratonaAddTeam => 'Add team';

  @override
  String get maratonaTeamName => 'Team name';

  @override
  String get maratonaAddPrize => 'Add prize';

  @override
  String get maratonaPrizeTitle => 'Prize';

  @override
  String get maratonaFieldPassword => 'Password to join (optional)';

  @override
  String get maratonaKeepPassword =>
      'Leave empty to keep the current password.';

  @override
  String get maratonaRemovePassword => 'Remove password';

  @override
  String get maratonaSave => 'Save';

  @override
  String get maratonaNext => 'Next';

  @override
  String get maratonaBack => 'Back';

  @override
  String get maratonaRemove => 'Remove';

  @override
  String maratonaMinChallengesError(int min) {
    return 'Add at least $min challenges.';
  }

  @override
  String get maratonaRequired => 'Required';

  @override
  String get maratonaPeriodError => 'The end must be on or after the start.';

  @override
  String get maratonaStartedNote =>
      'The marathon started: only texts, color, logo, link and prizes can change.';

  @override
  String get maratonaSaveError =>
      'Could not save. Check the fields and try again.';

  @override
  String get activityVerbCreatedMaratona => 'created the marathon';

  @override
  String get activityVerbJoinedMaratona => 'joined the marathon';

  @override
  String get activityVerbFinishedChallenge => 'completed a challenge in';

  @override
  String get activityVerbFinishedMaratona => 'finished the marathon';

  @override
  String activityMaratonaLevel(String level, int done, int total) {
    return 'Level $level · $done of $total challenges';
  }

  @override
  String get maratonaLoadMore => 'Load more';

  @override
  String get activityVerbCreatedCineClube => 'created the film club';

  @override
  String get activityVerbJoinedCineClube => 'joined the film club';

  @override
  String get cineclubeAddSession => 'Add movie';

  @override
  String get cineclubeCancel => 'Cancel film club';

  @override
  String get cineclubeCancelMessage =>
      'Nobody will be able to join or change it anymore.';

  @override
  String get cineclubeClosed => 'This film club is not open.';

  @override
  String cineclubeCompletedSessions(int done, int total) {
    return '$done of $total movies';
  }

  @override
  String get cineclubeCreate => 'Create film club';

  @override
  String get cineclubeCurrentSession => 'Now showing';

  @override
  String get cineclubeCycle => 'Cycle';

  @override
  String get cineclubeCycleHelp =>
      'With more than one movie it becomes a cycle: one movie after another, each with its own period and discussion day.';

  @override
  String get cineclubeDebateLink => 'Discussion link (call or chat)';

  @override
  String cineclubeDebateOn(String date) {
    return 'Discussion on $date';
  }

  @override
  String get cineclubeEditorEditTitle => 'Edit film club';

  @override
  String get cineclubeEditorNewTitle => 'New film club';

  @override
  String get cineclubeFieldDebate => 'Discussion day';

  @override
  String get cineclubeFilterAll => 'Everyone';

  @override
  String get cineclubeFutureSessionError =>
      'New and changed movies have to start after today.';

  @override
  String get cineclubeGif => 'GIF';

  @override
  String get cineclubeJoin => 'Join the film club';

  @override
  String get cineclubeJoined =>
      'You joined. The movie is on your Want to watch.';

  @override
  String get cineclubeLeaveMessage => 'The movie stays on your Want to watch.';

  @override
  String get cineclubeLeaveTitle => 'Leave the film club?';

  @override
  String get cineclubeListEmptyMessage =>
      'Create one and invite people to watch a movie together.';

  @override
  String get cineclubeListEmptyTitle => 'No film clubs here';

  @override
  String get cineclubeMovieAndDates => 'Movie and dates';

  @override
  String get cineclubeMovieRequired => 'Pick the movie of each session.';

  @override
  String get cineclubeOverlapError => 'The movies of a cycle cannot overlap.';

  @override
  String get cineclubeParticipantsEmpty => 'Nobody here yet';

  @override
  String get cineclubeParticipatingEmpty =>
      'You have not joined any film club yet.';

  @override
  String get cineclubePickMovie => 'Pick a movie';

  @override
  String get cineclubeProgressCompleted => 'Watched';

  @override
  String get cineclubeProgressEmptyMessage =>
      'Sessions logged by the participants during the period show up here.';

  @override
  String get cineclubeProgressEmptyTitle => 'No sessions yet';

  @override
  String get cineclubeProgressPending => 'Not started';

  @override
  String get cineclubeProgressWatching => 'Watching';

  @override
  String cineclubeRuntime(int minutes) {
    return '$minutes min';
  }

  @override
  String get cineclubeSave => 'Save';

  @override
  String get cineclubeSearchHint => 'Search film clubs';

  @override
  String get cineclubeSearchMovie => 'Search a movie';

  @override
  String cineclubeSessionLabel(int number, String title) {
    return '$number. $title';
  }

  @override
  String cineclubeSessionNumber(int number) {
    return 'Movie $number';
  }

  @override
  String get cineclubeSessionStarted => 'Already started';

  @override
  String get cineclubeSessions => 'Movies of the cycle';

  @override
  String cineclubeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies',
      one: '1 movie',
    );
    return '$_temp0';
  }

  @override
  String cineclubeSlugHelp(String slug) {
    return 'muuvie.app/c/$slug';
  }

  @override
  String get cineclubeSpoilerHidden =>
      'Comment hidden until you finish the movie or the discussion day comes.';

  @override
  String get cineclubeSpoilerNote =>
      'Comments stay hidden until you watch it, or until the discussion.';

  @override
  String get cineclubeTabParticipants => 'Participants';

  @override
  String get cineclubeTabProgress => 'Progress';

  @override
  String cineclubeWatchedMinutes(int minutes) {
    return '$minutes min watched';
  }

  @override
  String cineclubeWatchedPercent(int percent) {
    return '$percent% watched';
  }

  @override
  String get cineclubeWhereToWatch => 'Where to watch';

  @override
  String get chartsGoalTitle => 'Movies goal for the year';

  @override
  String get chartsGoalSave => 'Save goal';

  @override
  String get chartsGoalInvalid => 'Type a number between 1 and 5000.';

  @override
  String chartsGoalPrompt(String year) {
    return 'Set how many movies you want to watch in $year.';
  }

  @override
  String get chartsGoalSet => 'Set goal';

  @override
  String chartsGoalProgress(int watched, int target, String year) {
    return '$watched of $target movies in $year';
  }

  @override
  String get chartsGoalReached => 'Goal reached!';

  @override
  String get chartsEmptyTitle => 'No sessions this year';

  @override
  String get chartsEmptyMessage =>
      'Sessions logged in the year show up here as charts.';

  @override
  String chartsOpenRetrospective(String year) {
    return 'See the $year retrospective';
  }

  @override
  String get chartsMovies => 'movies';

  @override
  String get chartsHours => 'hours in front of the screen';

  @override
  String get chartsSessions => 'sessions';

  @override
  String get chartsRewatches => 'rewatches';

  @override
  String get chartsMonths => 'Movies per month';

  @override
  String get chartsGenres => 'Genres';

  @override
  String get chartsOthers => 'Others';

  @override
  String get chartsDecades => 'Decades';

  @override
  String chartsDecade(String decade) {
    return '${decade}s';
  }

  @override
  String get chartsCountries => 'Countries';

  @override
  String get chartsLanguages => 'Languages';

  @override
  String get chartsVenues => 'Where you watched';

  @override
  String get chartsDirectors => 'Directors';

  @override
  String get chartsEmotions => 'Emotions';

  @override
  String get chartsRatings => 'Ratings';

  @override
  String get chartsCalendar => 'Calendar';

  @override
  String chartsCalendarSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sessions on $count days',
      one: 'Sessions on 1 day',
    );
    return '$_temp0';
  }

  @override
  String get retrospectiveShare => 'Share this story';

  @override
  String retrospectiveShareText(String year) {
    return 'My $year in movies on Muuvie';
  }

  @override
  String get retrospectiveEmpty => 'No movies finished this year yet';

  @override
  String get retrospectiveIntro => 'Your year at the movies';

  @override
  String retrospectiveMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'movies',
      one: 'movie',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hours in front of the screen',
      one: 'hour in front of the screen',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveRewatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'And $count rewatches',
      one: 'And 1 rewatch',
    );
    return '$_temp0';
  }

  @override
  String get retrospectiveTopGenres => 'Your genres';

  @override
  String get retrospectiveTopDirectors => 'Directors you watched the most';

  @override
  String get retrospectiveTopActors => 'Faces you saw the most';

  @override
  String get retrospectiveEmotion => 'The emotion of your year';

  @override
  String get retrospectiveFavorite => 'Your favorite movie';

  @override
  String get retrospectiveBestMonth => 'Your most movie-filled month';

  @override
  String retrospectiveMaratonas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maratonas finished',
      one: '1 maratona finished',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveCineclubes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count film clubs',
      one: '1 film club',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveGoalReached(int target) {
    return 'Goal of $target movies reached!';
  }

  @override
  String retrospectiveGoalProgress(int watched, int target) {
    return '$watched of the $target movies of your goal';
  }

  @override
  String get retrospectiveOutro => 'See you at the next session';

  @override
  String get activityVerbUnlockedBichinho => 'unlocked the vaquinha';

  @override
  String get petShelterTitle => 'Vaquinha da Bombonière';

  @override
  String get petAdopt => 'Adopt a vaquinha';

  @override
  String get petStarterTitle => 'Pick your popcorn bucket';

  @override
  String get petStarterMessage =>
      'Your vaquinha grows with the minutes you watch and the sessions you log. The first choice is for good.';

  @override
  String petStarterConfirmTitle(String name) {
    return 'Adopt $name?';
  }

  @override
  String get petStarterConfirmMessage =>
      'The first vaquinha cannot be changed later. Others unlock as you watch.';

  @override
  String get petStarterConfirm => 'Adopt';

  @override
  String petLevel(int level) {
    return 'Level $level';
  }

  @override
  String petXp(int xp, int next) {
    return '$xp of $next XP';
  }

  @override
  String get petXpHelp =>
      'Each finished movie gives 20 XP, plus 1 for every 10 minutes. Imports do not count.';

  @override
  String petUnlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vaquinhas',
      one: '1 vaquinha',
    );
    return '$_temp0';
  }

  @override
  String get petLocked => 'To unlock';

  @override
  String get petPin => 'Show on my profile';

  @override
  String get petRarityStarter => 'Starter';

  @override
  String get petRarityCommon => 'Common';

  @override
  String get petRarityRare => 'Rare';

  @override
  String get petRarityLegendary => 'Legendary';

  @override
  String get petPipocaDoce => 'Sweet popcorn';

  @override
  String get petPipocaSalgada => 'Salty popcorn';

  @override
  String get petPipocaCaramelo => 'Caramel popcorn';

  @override
  String get petPipocaDoceAbout => 'Loves romance and animation.';

  @override
  String get petPipocaSalgadaAbout => 'Never misses a thriller.';

  @override
  String get petPipocaCarameloAbout => 'Collects classics.';

  @override
  String get petClaquete => 'Clapperboard';

  @override
  String get petIngresso => 'Ticket';

  @override
  String get petFantasminha => 'Little ghost';

  @override
  String get petRobozinho => 'Little robot';

  @override
  String get petLanterninha => 'Usher';

  @override
  String get petRoloDeFilme => 'Film reel';

  @override
  String get petDinossauro => 'Dinosaur';

  @override
  String get petCoruja => 'Owl';

  @override
  String get petTrofeu => 'Trophy';

  @override
  String get petProjetor => 'Projector';

  @override
  String get petEstatueta => 'Statuette';

  @override
  String get petRuleStarter => 'Starter pack';

  @override
  String petRuleMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Watch $count movies',
      one: 'Watch 1 movie',
    );
    return '$_temp0';
  }

  @override
  String petRuleMinutes(int count) {
    return 'Watch $count minutes';
  }

  @override
  String petRuleHorror(int count) {
    return 'Watch $count horror movies';
  }

  @override
  String petRuleSciFi(int count) {
    return 'Watch $count sci-fi movies';
  }

  @override
  String petRuleOldMovies(int count, String year) {
    return 'Watch $count movies from before $year';
  }

  @override
  String petRuleMaratonas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Finish $count maratonas',
      one: 'Finish a maratona',
    );
    return '$_temp0';
  }

  @override
  String petRuleCineclubes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Join $count film clubs',
      one: 'Join a film club',
    );
    return '$_temp0';
  }

  @override
  String petRuleMissions(int count) {
    return 'Complete $count missions';
  }

  @override
  String get missionsTitle => 'Missions';

  @override
  String missionsWeek(String start, String end) {
    return 'Week of $start to $end';
  }

  @override
  String get missionsHelp =>
      'Three new missions every Monday. Their XP goes to your pinned vaquinha.';

  @override
  String missionXp(int xp) {
    return '+$xp XP';
  }

  @override
  String get missionDone => 'Done!';

  @override
  String missionSessions(int count) {
    return 'Log $count sessions';
  }

  @override
  String missionMovies(int count) {
    return 'Finish $count movies';
  }

  @override
  String missionEmotions(int count) {
    return 'Log $count sessions with emotions';
  }

  @override
  String get missionLongMovie => 'Watch a movie of 2h30 or more';

  @override
  String get missionClassic => 'Watch a movie from before 1970';

  @override
  String get missionDocumentary => 'Watch a documentary';

  @override
  String get missionHorror => 'Watch a horror movie';

  @override
  String get missionAnimation => 'Watch an animation';

  @override
  String get missionAsia => 'Watch a movie from Asia';

  @override
  String get missionAfrica => 'Watch a movie from Africa';

  @override
  String get missionBrazil => 'Watch a Brazilian movie';

  @override
  String get missionCineclube => 'Join a film club';

  @override
  String get missionChallenge => 'Complete a maratona challenge';

  @override
  String get diaryTitle => 'Caderninho';

  @override
  String get diaryToday => 'Today';

  @override
  String get diaryPreviousDay => 'Previous day';

  @override
  String get diaryNextDay => 'Next day';

  @override
  String get diaryMood => 'How was your day?';

  @override
  String diaryGoals(int count, int max) {
    return 'Goals ($count of $max)';
  }

  @override
  String get diaryAddGoal => 'Add goal';

  @override
  String get diaryAdd => 'Add';

  @override
  String get diaryGoalHint => 'Watch Rashomon';

  @override
  String get diaryNoGoals => 'No goals for this day.';

  @override
  String get diaryReorder => 'Reorder';

  @override
  String get diaryNote => 'Desabafo';

  @override
  String get diaryNoteHint => 'Write whatever you want about today';

  @override
  String get diaryPrivate => 'Only you see your Caderninho.';

  @override
  String get diarySaved => 'Day saved';

  @override
  String get diaryDiscardTitle => 'Leave without saving?';

  @override
  String get diaryDiscardMessage => 'The changes of this day will be lost.';

  @override
  String get diaryDiscard => 'Leave';

  @override
  String get diaryYearTitle => 'Year of moods';

  @override
  String diaryYearOf(String year) {
    return 'Your $year in moods';
  }

  @override
  String diaryYearDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days written',
      one: '1 day written',
    );
    return '$_temp0';
  }

  @override
  String diaryYearTop(String mood) {
    return 'most of all: $mood';
  }

  @override
  String get diaryCategoryMovie => 'Movie';

  @override
  String get diaryCategoryShort => 'Short';

  @override
  String get diaryCategorySeries => 'Series';

  @override
  String get diaryCategoryStudy => 'Study';

  @override
  String get diaryCategoryOther => 'Other';

  @override
  String get moodGreat => 'Great';

  @override
  String get moodGood => 'Good';

  @override
  String get moodOkay => 'Okay';

  @override
  String get moodBad => 'Bad';

  @override
  String get moodAwful => 'Awful';

  @override
  String get partyTitle => 'Watch party';

  @override
  String get partyIntro =>
      'Press play at the same time as your friends: create a room, share the code and start the countdown.';

  @override
  String get partyCreate => 'Create a room';

  @override
  String get partyFieldTitle => 'What are you watching?';

  @override
  String get partyJoin => 'Join with a code';

  @override
  String get partyFieldCode => 'Room code';

  @override
  String get partyNotFound => 'No room with this code.';

  @override
  String get partyFull => 'This room is full.';

  @override
  String get partyClosed => 'The room was closed';

  @override
  String partyCodeLabel(String code) {
    return 'Room code $code';
  }

  @override
  String get partyCopyCode => 'Copy code';

  @override
  String get partyCodeCopied => 'Code copied';

  @override
  String partyMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people in the room',
      one: '1 person in the room',
    );
    return '$_temp0';
  }

  @override
  String get partyWaiting => 'Waiting for the host to start the countdown';

  @override
  String get partyWaitingHost => 'When everyone is ready, start the countdown';

  @override
  String get partyStart => 'Start the countdown';

  @override
  String get partyRestart => 'Restart the countdown';

  @override
  String partyStartIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'In $seconds seconds',
      one: 'In 1 second',
    );
    return '$_temp0';
  }

  @override
  String partySecondsLeft(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds left',
      one: '1 second left',
    );
    return '$_temp0';
  }

  @override
  String get partyPlay => 'Play!';

  @override
  String get partyNoMessages => 'No messages yet';

  @override
  String get partyMessageHint => 'Say something';

  @override
  String get partySend => 'Send';

  @override
  String get posterGameTitle => 'Poster game';

  @override
  String get posterGameHint => 'A blurred movie poster';

  @override
  String get posterGameQuestion => 'Which movie is it?';

  @override
  String posterGameScore(int points) {
    return '$points points';
  }

  @override
  String posterGameStreak(int count) {
    return 'Streak: $count';
  }

  @override
  String get posterGameRight => 'Right!';

  @override
  String posterGameWrong(String title) {
    return 'It was $title';
  }

  @override
  String get posterGameNext => 'Next poster';

  @override
  String get onboardingWelcomeTitle => 'Muuvie is a movie marathon';

  @override
  String get onboardingWelcomeText =>
      'Keep what you watch, take on challenges and watch together with other movie lovers.';

  @override
  String get onboardingShelvesTitle => 'Shelves and locadoras';

  @override
  String get onboardingShelvesText =>
      'Watched and Want to watch are always there. Create your own shelves and group them in locadoras.';

  @override
  String get onboardingLogsTitle => 'Log every session';

  @override
  String get onboardingLogsText =>
      'Stars, emotions, a GIF and a comment for every movie, with who can see each one.';

  @override
  String get onboardingProgramacaoTitle => 'Maratonas and film clubs';

  @override
  String get onboardingProgramacaoText =>
      'Join maratonas with challenges that complete themselves, and film clubs with a discussion day and no spoilers.';

  @override
  String get onboardingSocialTitle => 'Friends and a vaquinha';

  @override
  String get onboardingSocialText =>
      'Follow people, send Sussurros and raise a vaquinha that grows with every movie.';

  @override
  String get onboardingImportTitle => 'Bring your history';

  @override
  String get onboardingImportText =>
      'Import what you watched, your watchlist and your lists from Filmow. Nothing you made here is overwritten.';

  @override
  String get onboardingImportFilmow => 'Import from Filmow';

  @override
  String get onboardingSuggestionsTitle => 'Showing now';

  @override
  String get onboardingSuggestionsText =>
      'Open maratonas and film clubs you can join today.';

  @override
  String get onboardingSuggestionsEmpty =>
      'Nothing open right now. Create the first one in Programação!';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsImport => 'Import movies';

  @override
  String get settingsImportHint =>
      'From Filmow, without overwriting what you made here';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotifyMessages => 'Sussurros';

  @override
  String get settingsNotifyFollowers => 'New followers';

  @override
  String get settingsNotifyLoves => 'Loves on my activities';

  @override
  String get settingsNotifyMaratonas => 'Maratonas I joined';

  @override
  String get settingsNotifyCineclubes => 'Discussion day of my film clubs';

  @override
  String get settingsPushOff => 'Notifications are off on this device';

  @override
  String get settingsPushOffHint =>
      'Allow them to get Sussurros and alerts with the app closed. If nothing happens, turn them on in the device settings.';

  @override
  String get settingsPushAllow => 'Allow';

  @override
  String get settingsAbout => 'Muuvie';

  @override
  String get settingsShowIntro => 'See the introduction again';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutTitle => 'Log out of Muuvie?';

  @override
  String get movieDetailRecordsTab => 'Activity';

  @override
  String get movieRecordsEmpty => 'Nobody logged this movie yet. Be the first!';

  @override
  String movieCommunityWatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people watched',
      one: '1 person watched',
      zero: 'Nobody watched it yet',
    );
    return '$_temp0';
  }

  @override
  String movieCommunityWantToWatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people want to watch',
      one: '1 person wants to watch',
      zero: 'Nobody wants to watch it yet',
    );
    return '$_temp0';
  }

  @override
  String get movieEventsTitle => 'In the Programação';

  @override
  String movieEventCountsFor(String challenges) {
    return 'Counts for: $challenges';
  }

  @override
  String get movieDetailWrittenBy => 'Written by';

  @override
  String get movieDetailTrailer => 'Watch trailer';

  @override
  String get movieDetailCreateCineClube => 'Create a CineClube with this movie';

  @override
  String get movieDetailWatchParty => 'Watch together';

  @override
  String get movieActivitiesRatings => 'Ratings';

  @override
  String get movieActivitiesUpdates => 'Updates';

  @override
  String get movieActivitiesEverything => 'Everything';

  @override
  String get movieActivitiesEveryone => 'Everyone';

  @override
  String get movieActivitiesFollowing => 'Following';

  @override
  String get movieActivitiesOnlyMe => 'Only me';

  @override
  String get movieCommunityTitle => 'Community';

  @override
  String movieCommunityShelves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count shelves',
      one: 'In 1 shelf',
    );
    return '$_temp0';
  }

  @override
  String get movieCommunityFeelings => 'How people felt';

  @override
  String get movieRecentRatings => 'Recent ratings';

  @override
  String get movieRecentRatingsAll => 'See all';

  @override
  String get movieShelvesTitle => 'Shelves with this movie';

  @override
  String get movieShelvesEmpty => 'No public shelf has this movie yet.';

  @override
  String movieShelvesBy(String name) {
    return 'by $name';
  }

  @override
  String get movieDetailReadMore => 'Read more';

  @override
  String get movieDetailReadLess => 'Show less';

  @override
  String get movieStatWatched => 'Watched';

  @override
  String get movieStatWantToWatch => 'Want to watch';

  @override
  String get movieStatShelves => 'Shelves';

  @override
  String movieEmotionsAll(int count) {
    return 'See all ($count)';
  }

  @override
  String get movieTimelineTitle => 'Last 12 months';

  @override
  String get movieTimelineSessions => 'Sessions';

  @override
  String movieTimelineMonth(String month, int sessions, int ratings) {
    return '$month: $sessions sessions, $ratings ratings';
  }

  @override
  String get movieShelvesSection => 'On shelves';

  @override
  String get movieMaratonasSection => 'Maratonas it counted in';

  @override
  String get cineclubeStatusFinished => 'Finished';

  @override
  String get movieCommunityEmpty => 'Nobody did anything with this movie yet.';

  @override
  String get discoverTrending => 'Trending on Muuvie';

  @override
  String get discoverMostLoved => 'Most loved on Muuvie';

  @override
  String get discoverGenres => 'Genres';

  @override
  String get discoverSectionError => 'Couldn\'t load this section';

  @override
  String get searchMinLetters => 'Type at least 3 letters';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchClearRecent => 'Clear all';

  @override
  String get searchRemoveRecent => 'Remove';

  @override
  String get searchTabPeople => 'People';

  @override
  String shelfByOwner(String name) {
    return 'by $name';
  }

  @override
  String get shelfSavedLabel => 'Saved';

  @override
  String get shelfSaveError => 'Couldn\'t update the saved shelves. Try again.';

  @override
  String shelfOpenOwnerProfile(String name) {
    return 'Open $name\'s profile';
  }

  @override
  String get savedShelvesTitle => 'Saved shelves';

  @override
  String get savedShelvesAction => 'Saved';

  @override
  String get savedShelvesEmpty =>
      'Shelves you save from other people show up here.';
}
