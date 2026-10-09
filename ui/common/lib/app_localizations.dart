import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'lib/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Muuvie'**
  String get appTitle;

  /// Bottom navigation home label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Bottom navigation search label and search screen title
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Home screen movies tab label
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get moviesTab;

  /// Home screen reviews tab label
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTab;

  /// Fallback error message when no details are available
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Movie release date label
  ///
  /// In en, this message translates to:
  /// **'Release: {date}'**
  String movieRelease(String date);

  /// Movie rating label
  ///
  /// In en, this message translates to:
  /// **'Rating: {rating}'**
  String movieRating(String rating);

  /// Movie runtime label
  ///
  /// In en, this message translates to:
  /// **'Runtime: {minutes} min'**
  String movieRuntime(int minutes);

  /// Movie genres label
  ///
  /// In en, this message translates to:
  /// **'Genres: {genres}'**
  String movieGenres(String genres);

  /// Bottom navigation social tab label
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get socialTab;

  /// Bottom navigation new user activity tab label
  ///
  /// In en, this message translates to:
  /// **'New Activity'**
  String get newUserActivityTab;

  /// Hint text inside the search input field
  ///
  /// In en, this message translates to:
  /// **'Movies, people, lists...'**
  String get searchHint;

  /// Section header above browse options on the search screen
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get searchBrowse;

  /// Browse by release date option
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get searchBrowseReleaseDate;

  /// Browse by genre option
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get searchBrowseGenre;

  /// Browse by country and language option
  ///
  /// In en, this message translates to:
  /// **'Country & Language'**
  String get searchBrowseCountryAndLanguage;

  /// Merged browse option for genre, country and language
  ///
  /// In en, this message translates to:
  /// **'Genre, Country & Language'**
  String get searchBrowseGenreCountryLanguage;

  /// Country tab label in browse categories
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get searchBrowseCountry;

  /// Language tab label in browse categories
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get searchBrowseLanguage;

  /// Browse by streaming service option
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get searchBrowseService;

  /// Browse most popular movies option
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get searchBrowseMostPopular;

  /// Browse highest rated movies option
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get searchBrowseHighestRated;

  /// Browse most anticipated movies option
  ///
  /// In en, this message translates to:
  /// **'Most Anticipated'**
  String get searchBrowseMostAnticipated;

  /// Browse featured lists option
  ///
  /// In en, this message translates to:
  /// **'Featured Lists'**
  String get searchBrowseFeaturedLists;

  /// Profile tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTabProfile;

  /// Diary tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get profileTabDiary;

  /// Reviews tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profileTabReviews;

  /// Lists tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get profileTabLists;

  /// Watchlist tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get profileTabWatchlist;

  /// Followers stat label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileFollowers;

  /// Following stat label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileFollowing;

  /// Movies watched stat label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get profileMoviesWatched;

  /// Title for the movies watched bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Movies watched'**
  String get profileMoviesWatchedTitle;

  /// Title for the following bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileFollowingTitle;

  /// Title for the followers bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileFollowersTitle;

  /// Empty state message for movies watched
  ///
  /// In en, this message translates to:
  /// **'No movies watched yet'**
  String get profileEmptyMoviesWatched;

  /// Empty state message for following list
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet'**
  String get profileEmptyFollowing;

  /// Empty state message for followers list
  ///
  /// In en, this message translates to:
  /// **'No followers yet'**
  String get profileEmptyFollowers;

  /// Edit profile button label
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// Username field label on the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get editProfileUsernameLabel;

  /// Username field placeholder on the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get editProfileUsernamePlaceholder;

  /// Bio field label on the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileBioLabel;

  /// Bio field placeholder on the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get editProfileBioPlaceholder;

  /// Change photo button label on the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editProfileChangePhoto;

  /// Recent movies section header on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Recent Movies'**
  String get profileRecentMovies;

  /// Favorite movies section header on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Favorite Movies'**
  String get profileFavoriteMovies;

  /// Recent activity section header on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get profileRecentActivity;

  /// Movies section header on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get profileMoviesSection;

  /// Reviews section header on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profileReviewsSection;

  /// Watchlist section header on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get profileWatchlistSection;

  /// See all link label for profile sections
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get profileSeeAll;

  /// Friends tab label on the social screen
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get socialFriendsTab;

  /// Activities tab label on the social screen
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get socialActivitiesTab;

  /// Empty state message when the user has no friends
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get socialNoFriends;

  /// Lists tab label on the movies list screen
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get moviesListListsTab;

  /// Articles tab label on the movies list screen
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get moviesListArticlesTab;

  /// Header for popular lists section
  ///
  /// In en, this message translates to:
  /// **'Popular this week'**
  String get moviesListPopularThisWeek;

  /// Movies tab label with count
  ///
  /// In en, this message translates to:
  /// **'{count} Movies'**
  String movieListDetailMoviesTab(int count);

  /// Comments tab label with count
  ///
  /// In en, this message translates to:
  /// **'{count} Comments'**
  String movieListDetailCommentsTab(int count);

  /// Placeholder for comments tab
  ///
  /// In en, this message translates to:
  /// **'Comments coming soon'**
  String get movieListDetailCommentsPlaceholder;

  /// Drafts section header on the new activity screen
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get newUserActivityDraftsSection;

  /// Recent searches section header on the new activity screen
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get newUserActivityRecentSection;

  /// Follow button label on public profile screen
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get profileFollow;

  /// Section header for the review body text on the review details screen
  ///
  /// In en, this message translates to:
  /// **'My Review'**
  String get reviewDetailsBodyTitle;

  /// Message shown when a search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// App bar title for the movie review screen
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get movieReviewTitle;

  /// Hint text for the review name input field
  ///
  /// In en, this message translates to:
  /// **'Review title'**
  String get movieReviewNameHint;

  /// Placeholder text in the add review box
  ///
  /// In en, this message translates to:
  /// **'Add a review...'**
  String get movieReviewAddReview;

  /// Label for the rewatch toggle
  ///
  /// In en, this message translates to:
  /// **'Rewatch'**
  String get movieReviewRewatch;

  /// Label for the first time watching toggle
  ///
  /// In en, this message translates to:
  /// **'First time'**
  String get movieReviewFirstTime;

  /// Section header for the tags section
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get movieReviewTags;

  /// Predefined tag for movie review
  ///
  /// In en, this message translates to:
  /// **'Masterpiece'**
  String get movieReviewTagMasterpiece;

  /// Predefined tag for movie review
  ///
  /// In en, this message translates to:
  /// **'Overrated'**
  String get movieReviewTagOverrated;

  /// Predefined tag for movie review
  ///
  /// In en, this message translates to:
  /// **'Underrated'**
  String get movieReviewTagUnderrated;

  /// Predefined tag for movie review
  ///
  /// In en, this message translates to:
  /// **'Must Watch'**
  String get movieReviewTagMustWatch;

  /// Predefined tag for movie review
  ///
  /// In en, this message translates to:
  /// **'Disappointing'**
  String get movieReviewTagDisappointing;

  /// Predefined tag for movie review
  ///
  /// In en, this message translates to:
  /// **'Feel Good'**
  String get movieReviewTagFeelGood;

  /// Predefined tag for movie review
  ///
  /// In en, this message translates to:
  /// **'Mind Bending'**
  String get movieReviewTagMindBending;

  /// Predefined tag for movie review
  ///
  /// In en, this message translates to:
  /// **'Emotional'**
  String get movieReviewTagEmotional;

  /// Tooltip for the send review button in the app bar
  ///
  /// In en, this message translates to:
  /// **'Send review'**
  String get movieReviewSend;

  /// Title for the delete draft confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete draft?'**
  String get deleteDraftTitle;

  /// Content for the delete draft confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This draft will be permanently deleted.'**
  String get deleteDraftContent;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Cancel action label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title for the review editor bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get reviewEditorTitle;

  /// Placeholder text for the review editor
  ///
  /// In en, this message translates to:
  /// **'Start writing your review...'**
  String get reviewEditorPlaceholder;

  /// Button to clear all text in the review editor
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get reviewEditorClear;

  /// Title for the clear review confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Clear review?'**
  String get reviewEditorClearConfirmTitle;

  /// Content for the clear review confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'All text will be removed.'**
  String get reviewEditorClearConfirmContent;

  /// Placeholder text for the add review section on the review details screen
  ///
  /// In en, this message translates to:
  /// **'Add a review...'**
  String get reviewDetailsAddReview;

  /// Tooltip for the button that switches movie list detail to grid layout
  ///
  /// In en, this message translates to:
  /// **'Show grid view'**
  String get movieListDetailShowGridView;

  /// Tooltip for the button that switches movie list detail to list layout
  ///
  /// In en, this message translates to:
  /// **'Show list view'**
  String get movieListDetailShowListView;

  /// Title for the error empty state
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get emptyStateErrorTitle;

  /// Message for the error empty state
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get emptyStateErrorMessage;

  /// Retry button label on the error empty state
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get emptyStateRetry;

  /// Title for the empty list state
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateNoItemsTitle;

  /// Message for the empty list state
  ///
  /// In en, this message translates to:
  /// **'There are no items to display.'**
  String get emptyStateNoItemsMessage;

  /// Tooltip for the clear search text button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// Title of the submit review confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReviewTitle;

  /// Content of the submit review confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to submit this review? It will be published and the draft will be removed.'**
  String get submitReviewContent;

  /// Submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Label shown while a review is being submitted
  ///
  /// In en, this message translates to:
  /// **'Submitting review...'**
  String get submittingReview;

  /// Label shown when review submission fails
  ///
  /// In en, this message translates to:
  /// **'Submission failed'**
  String get submissionFailed;

  /// Error message shown below a required field that is empty
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Error message shown when rating is missing
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get ratingRequired;

  /// Error message shown when review body is empty
  ///
  /// In en, this message translates to:
  /// **'Please write a review'**
  String get reviewBodyRequired;

  /// Error message shown when no tags are selected
  ///
  /// In en, this message translates to:
  /// **'Please select at least one tag'**
  String get tagsRequired;

  /// Section title for streaming services
  ///
  /// In en, this message translates to:
  /// **'Where to Watch'**
  String get movieDetailWhereToWatch;

  /// Section title for movie description
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get movieDetailSynopsis;

  /// Section title for popular reviews
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get movieDetailReviews;

  /// Section title for similar movies
  ///
  /// In en, this message translates to:
  /// **'Similar Movies'**
  String get movieDetailSimilar;

  /// Number of likes
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String movieDetailLikes(int count);

  /// Number of reviews
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String movieDetailReviewCount(int count);

  /// Number of lists
  ///
  /// In en, this message translates to:
  /// **'{count} lists'**
  String movieDetailListCount(int count);

  /// Label before director name
  ///
  /// In en, this message translates to:
  /// **'Directed by'**
  String get movieDetailDirectedBy;

  /// Runtime in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String movieDetailMinutes(int minutes);

  /// See all button in movie detail sections
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get movieDetailSeeAll;

  /// About tab label on the movie detail screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get movieDetailAboutTab;

  /// AppBar title for movie reviews list
  ///
  /// In en, this message translates to:
  /// **'{title} Reviews'**
  String movieDetailMovieReviews(String title);

  /// Comments section title
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// Message shown when there are no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// Button label to load more comments
  ///
  /// In en, this message translates to:
  /// **'Load More Comments'**
  String get loadMore;

  /// Loading state message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Tooltip and semantic label for the share review action in the AppBar
  ///
  /// In en, this message translates to:
  /// **'Share review'**
  String get reviewDetailsShare;

  /// Tooltip and semantic label when the review is not yet liked
  ///
  /// In en, this message translates to:
  /// **'Like review'**
  String get reviewDetailsLike;

  /// Tooltip and semantic label when the review has been liked
  ///
  /// In en, this message translates to:
  /// **'Unlike review'**
  String get reviewDetailsUnlike;

  /// SnackBar message shown when toggling the like state fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update like. Try again.'**
  String get reviewDetailsLikeError;

  /// Localized plural label rendered next to the like icon
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No likes yet} =1{1 like} other{{count} likes}}'**
  String reviewDetailsLikeCount(int count);

  /// Section header for the comments preview
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get reviewDetailsCommentsTitle;

  /// Button label to open the full comments bottom sheet
  ///
  /// In en, this message translates to:
  /// **'View all ({count})'**
  String reviewDetailsViewAllComments(int count);

  /// Empty state shown when a review has no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get reviewDetailsNoComments;

  /// Header for the carousel of other reviews for the same movie
  ///
  /// In en, this message translates to:
  /// **'Other reviews for this movie'**
  String get reviewDetailsOtherReviewsForMovie;

  /// Header for the carousel of more reviews from the same author
  ///
  /// In en, this message translates to:
  /// **'More reviews from {author}'**
  String reviewDetailsMoreFromAuthor(String author);

  /// Inline author label on carousel cards
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String reviewDetailsBy(String author);

  /// Fallback label when a review's author is null
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get reviewDetailsAnonymousAuthor;

  /// Fallback body shown when a review has no content
  ///
  /// In en, this message translates to:
  /// **'No review text'**
  String get reviewDetailsNoBody;

  /// Inline error row label when the comments section fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load comments'**
  String get reviewDetailsLoadCommentsError;

  /// Inline error row label when a related-reviews carousel fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load related reviews'**
  String get reviewDetailsLoadRelatedError;

  /// Subtitle text on the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to discover and review movies'**
  String get loginSubtitle;

  /// Google OAuth login button label
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Facebook OAuth login button label
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// Tooltip for the share article action in the AppBar
  ///
  /// In en, this message translates to:
  /// **'Share article'**
  String get articleDetailShare;

  /// Email field label on the login screen
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// Email field hint on the login screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailHint;

  /// Password field label on the login screen
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// Password field hint on the login screen
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// Sign up navigation button label on the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// Title of the sign up screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpTitle;

  /// Nickname field label on the sign up screen
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get signUpNickname;

  /// Nickname field hint on the sign up screen
  ///
  /// In en, this message translates to:
  /// **'Choose a nickname'**
  String get signUpNicknameHint;

  /// Create account button label on the sign up screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// Error message for invalid email format
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailValidationError;

  /// Error message for password too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordValidationError;

  /// Error message for password too long
  ///
  /// In en, this message translates to:
  /// **'Password must be at most 72 characters'**
  String get passwordTooLongError;

  /// Error message for empty nickname
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname'**
  String get nicknameValidationError;

  /// Error message for nickname too long
  ///
  /// In en, this message translates to:
  /// **'Nickname must be at most 30 characters'**
  String get nicknameTooLongError;

  /// Error message when nickname is unavailable
  ///
  /// In en, this message translates to:
  /// **'This nickname is already taken'**
  String get nicknameTakenError;

  /// Error message when sign-up fails due to conflict
  ///
  /// In en, this message translates to:
  /// **'This email or nickname is already in use.'**
  String get signUpConflictError;

  /// Error message when sign-up fails due to invalid input
  ///
  /// In en, this message translates to:
  /// **'Please check your information and try again.'**
  String get signUpBadRequestError;

  /// Error message when sign-up fails due to network
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get signUpNetworkError;

  /// Error message when sign-up fails due to server error
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get signUpServerError;

  /// Login error for invalid credentials
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get loginError;

  /// Generic login error for server/network issues
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again later.'**
  String get loginGenericError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
