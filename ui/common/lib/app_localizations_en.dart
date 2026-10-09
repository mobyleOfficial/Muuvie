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
  String get searchHint => 'Movies, people, lists...';

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
  String get searchBrowseHighestRated => 'Highest Rated';

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
  String get signUpButton => 'Sign Up';

  @override
  String get signUpTitle => 'Create Account';

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
}
