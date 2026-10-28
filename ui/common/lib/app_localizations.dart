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
  /// **'Movies, people, shelves and more'**
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

  /// Shelves tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Shelves'**
  String get profileTabShelves;

  /// Locadoras tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Locadoras'**
  String get profileTabLocadoras;

  /// Shelves count chip on locadora card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shelf} other{{count} shelves}}'**
  String locadoraShelvesCount(int count);

  /// Total movies count chip on locadora card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie} other{{count} movies}}'**
  String locadoraMoviesCount(int count);

  /// Marathons tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Marathons'**
  String get profileTabMarathons;

  /// History tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get profileTabHistory;

  /// Participations tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Participations'**
  String get profileTabParticipations;

  /// Charts tab label on the profile screen
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get profileTabCharts;

  /// Watched count chip on shelf card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 watched} other{{count} watched}}'**
  String shelfWatchedCount(int count);

  /// Movies count chip on shelf card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie} other{{count} movies}}'**
  String shelfMoviesCount(int count);

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

  /// Notice on an imported movie the backend could not match with TMDB
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this movie in our catalog. The details come from Filmow and may be incomplete.'**
  String get movieDetailUnmatched;

  /// Section title for movie cast
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get movieDetailCast;

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

  /// Headline on the login screen
  ///
  /// In en, this message translates to:
  /// **'Good to see you!'**
  String get loginWelcomeTitle;

  /// Prompt before the create account link on the login screen
  ///
  /// In en, this message translates to:
  /// **'New to Muuvie?'**
  String get loginNoAccount;

  /// Link from the login screen to the sign up screen
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccountLink;

  /// Headline on the sign up screen
  ///
  /// In en, this message translates to:
  /// **'Get your ticket'**
  String get signUpHeadline;

  /// Subtitle on the sign up screen
  ///
  /// In en, this message translates to:
  /// **'Create your account in less than a minute.'**
  String get signUpSubtitle;

  /// Prompt before the log in link on the sign up screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signUpHaveAccount;

  /// Shown while the nickname availability is being checked
  ///
  /// In en, this message translates to:
  /// **'Checking availability…'**
  String get signUpNicknameChecking;

  /// Shown when the nickname is available
  ///
  /// In en, this message translates to:
  /// **'Nickname available'**
  String get signUpNicknameAvailable;

  /// Password requirement shown under the password field
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get signUpPasswordHelper;

  /// Tooltip of the button that reveals the password
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShow;

  /// Tooltip of the button that hides the password
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHide;

  /// Action sheet option to write a review
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get movieDetailWriteReview;

  /// Action sheet option to create a list
  ///
  /// In en, this message translates to:
  /// **'Create a List'**
  String get movieDetailCreateList;

  /// Tooltip for the actions button on movie detail
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get movieDetailActions;

  /// Watch status chip label
  ///
  /// In en, this message translates to:
  /// **'Want to Watch'**
  String get movieDetailWantToWatch;

  /// Watch status chip label
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get movieDetailWatched;

  /// Label before the user's rating label
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get movieDetailYourRating;

  /// Title of the delete list confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get movieListDeleteTitle;

  /// Body of the delete list confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list? This action cannot be undone.'**
  String get movieListDeleteContent;

  /// Tooltip when list is in edit mode
  ///
  /// In en, this message translates to:
  /// **'Done editing'**
  String get movieListDoneEditing;

  /// Tooltip to enter list edit mode
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get movieListEditList;

  /// Tooltip for the delete list button
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get movieListDeleteTooltip;

  /// Title of the create list modal
  ///
  /// In en, this message translates to:
  /// **'New List'**
  String get createListTitle;

  /// Save button on the create list modal
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get createListSave;

  /// Button to add movies to a new list
  ///
  /// In en, this message translates to:
  /// **'Add Movies'**
  String get createListAddMovies;

  /// Empty state when no movies are added to a list
  ///
  /// In en, this message translates to:
  /// **'No movies added yet'**
  String get createListNoMovies;

  /// Hint for the list name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get createListNameHint;

  /// Hint for the list description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createListDescriptionHint;

  /// Section header for movies in create list
  ///
  /// In en, this message translates to:
  /// **'MOVIES'**
  String get createListMoviesSection;

  /// Section header with movie count
  ///
  /// In en, this message translates to:
  /// **'MOVIES ({count})'**
  String createListMoviesCount(int count);

  /// Title of the Filmow login webview
  ///
  /// In en, this message translates to:
  /// **'Login no Filmow'**
  String get editProfileFilmowLogin;

  /// Button to import data from Filmow
  ///
  /// In en, this message translates to:
  /// **'Import data from Filmow'**
  String get editProfileImportFilmow;

  /// Button to import data from Letterboxd
  ///
  /// In en, this message translates to:
  /// **'Import data from Letterboxd'**
  String get editProfileImportLetterboxd;

  /// Button label to follow a user
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followLabel;

  /// Button label when already following
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingLabel;

  /// Semantic label to unfollow a user
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollowLabel;

  /// AppBar title for a movie's reviews
  ///
  /// In en, this message translates to:
  /// **'{title} Reviews'**
  String routeReviewsTitle(String title);

  /// AppBar title for reviews without movie name
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get routeReviews;

  /// Route title for release date decades
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get routeReleaseDate;

  /// Route title for browse categories
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get routeBrowse;

  /// Route title for most popular movies
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get routeMostPopular;

  /// Route title for most anticipated movies
  ///
  /// In en, this message translates to:
  /// **'Most Anticipated'**
  String get routeMostAnticipated;

  /// Route title for featured lists
  ///
  /// In en, this message translates to:
  /// **'Featured Lists'**
  String get routeFeaturedLists;

  /// Search field placeholder in the add shelves to locadora screen
  ///
  /// In en, this message translates to:
  /// **'Search shelves...'**
  String get addShelvesSearchHint;

  /// Empty state message in the add shelves screen
  ///
  /// In en, this message translates to:
  /// **'Search for shelves to add'**
  String get addShelvesEmptyState;

  /// Title of the create locadora bottom sheet
  ///
  /// In en, this message translates to:
  /// **'New Locadora'**
  String get createLocadoraTitle;

  /// Prompt text above the locadora name field
  ///
  /// In en, this message translates to:
  /// **'What\'s the name of your locadora?'**
  String get createLocadoraNamePrompt;

  /// Hint for the locadora name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get createLocadoraNameHint;

  /// Prompt text above the locadora description field
  ///
  /// In en, this message translates to:
  /// **'Describe your locadora (optional)'**
  String get createLocadoraDescriptionPrompt;

  /// Hint for the locadora description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createLocadoraDescriptionHint;

  /// Prompt text above the visibility selector
  ///
  /// In en, this message translates to:
  /// **'Who can see this locadora?'**
  String get createLocadoraVisibilityPrompt;

  /// Create locadora button label
  ///
  /// In en, this message translates to:
  /// **'Create Locadora'**
  String get createLocadoraSave;

  /// Title of the create shelf bottom sheet
  ///
  /// In en, this message translates to:
  /// **'New Shelf'**
  String get createShelfTitle;

  /// Prompt text above the shelf name field
  ///
  /// In en, this message translates to:
  /// **'What\'s the name of your shelf?'**
  String get createShelfNamePrompt;

  /// Hint for the shelf name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get createShelfNameHint;

  /// Prompt text above the shelf description field
  ///
  /// In en, this message translates to:
  /// **'Describe your shelf (optional)'**
  String get createShelfDescriptionPrompt;

  /// Hint for the shelf description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createShelfDescriptionHint;

  /// Prompt text above the color picker
  ///
  /// In en, this message translates to:
  /// **'Choose a color for your shelf'**
  String get createShelfColorPrompt;

  /// Prompt text above the visibility selector
  ///
  /// In en, this message translates to:
  /// **'Who can see this shelf?'**
  String get createShelfVisibilityPrompt;

  /// Public visibility option
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get createShelfVisibilityPublic;

  /// Private visibility option
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get createShelfVisibilityPrivate;

  /// Mutuals-only visibility option
  ///
  /// In en, this message translates to:
  /// **'Mutuals'**
  String get createShelfVisibilityMutuals;

  /// Create shelf button label
  ///
  /// In en, this message translates to:
  /// **'Create Shelf'**
  String get createShelfSave;

  /// Visibility: anyone can see
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// Visibility: only users who follow each other
  ///
  /// In en, this message translates to:
  /// **'Mutuals'**
  String get visibilityMutual;

  /// Visibility: only the owner
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get visibilitySecret;

  /// Watch progress mode: whole movie
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watchModeWatched;

  /// Watch progress mode: minutes watched
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get watchModeMinutes;

  /// Watch progress mode: percentage watched
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get watchModePercent;

  /// Where the movie was watched
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get watchVenueCinema;

  /// Where the movie was watched
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get watchVenueStreaming;

  /// Where the movie was watched
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get watchVenueTv;

  /// Where the movie was watched (DVD, Blu-ray...)
  ///
  /// In en, this message translates to:
  /// **'Physical media'**
  String get watchVenuePhysicalMedia;

  /// Where the movie was watched
  ///
  /// In en, this message translates to:
  /// **'Festival'**
  String get watchVenueFestival;

  /// Where the movie was watched
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get watchVenueOther;

  /// Movie status
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watchStatusWatched;

  /// Movie status
  ///
  /// In en, this message translates to:
  /// **'Want to watch'**
  String get watchStatusWantToWatch;

  /// Name of the fixed shelf with watched movies
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get systemShelfWatched;

  /// Name of the fixed watchlist shelf
  ///
  /// In en, this message translates to:
  /// **'Want to watch'**
  String get systemShelfWatchlist;

  /// Rating label: a favorite movie (replaces the heart)
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get ratingLabelFavorite;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Loved it'**
  String get ratingLabelLoved;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Liked it'**
  String get ratingLabelLiked;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get ratingLabelNeutral;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Not for me'**
  String get ratingLabelNotForMe;

  /// Rating label: gave up midway
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get ratingLabelAbandoned;

  /// Rating label: paused, will come back later
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get ratingLabelOnHold;

  /// Shelf ordering: keep saved positions
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get shelfSortManual;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get shelfSortTitle;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get shelfSortDirector;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'Release year'**
  String get shelfSortReleaseYear;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get shelfSortAddedNewest;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'First added'**
  String get shelfSortAddedOldest;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get shelfSortUpdatedNewest;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'Watched first'**
  String get shelfSortWatchedFirst;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'Watched last'**
  String get shelfSortWatchedLast;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'Most progress'**
  String get shelfSortProgressHighest;

  /// Shelf ordering
  ///
  /// In en, this message translates to:
  /// **'By rating'**
  String get shelfSortRatingHighest;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Curiosity'**
  String get emotionCuriosity;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get emotionInspiration;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get emotionReflection;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get emotionRelaxation;

  /// Emotion: emotionally touched
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get emotionMoved;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Nostalgia'**
  String get emotionNostalgia;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get emotionGratitude;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Affection'**
  String get emotionAffection;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Surprise'**
  String get emotionSurprise;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Passion'**
  String get emotionPassion;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get emotionFun;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Joy'**
  String get emotionJoy;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Humor'**
  String get emotionHumor;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Freak-out'**
  String get emotionFreakOut;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get emotionAnxiety;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Distress'**
  String get emotionDistress;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Tension'**
  String get emotionTension;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Distraction'**
  String get emotionDistraction;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Confusion'**
  String get emotionConfusion;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Suspicion'**
  String get emotionSuspicion;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Irritation'**
  String get emotionIrritation;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Anger'**
  String get emotionAnger;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Indignation'**
  String get emotionIndignation;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Fear'**
  String get emotionFear;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Vulnerability'**
  String get emotionVulnerability;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Embarrassment'**
  String get emotionEmbarrassment;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Frustration'**
  String get emotionFrustration;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Sadness'**
  String get emotionSadness;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Melancholy'**
  String get emotionMelancholy;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Tiredness'**
  String get emotionTiredness;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Boredom'**
  String get emotionBoredom;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get emotionConnection;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get emotionFocus;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get emotionIntensity;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Enthusiasm'**
  String get emotionEnthusiasm;

  /// Emotion: thrilled, adrenaline
  ///
  /// In en, this message translates to:
  /// **'Thrill'**
  String get emotionExcitement;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Euphoria'**
  String get emotionEuphoria;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Shock'**
  String get emotionShock;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Horror'**
  String get emotionHorror;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Disgust'**
  String get emotionDisgust;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Devastation'**
  String get emotionDevastation;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Grudge'**
  String get emotionGrudge;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Indifference'**
  String get emotionIndifference;

  /// Emotion
  ///
  /// In en, this message translates to:
  /// **'Apathy'**
  String get emotionApathy;

  /// Button that ends the session on this device
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get editProfileLogout;

  /// Logout confirmation title
  ///
  /// In en, this message translates to:
  /// **'Log out of Muuvie?'**
  String get editProfileLogoutConfirmTitle;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'You can log back in anytime.'**
  String get editProfileLogoutConfirmMessage;

  /// Placeholder title for features arriving in later phases
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Bottom nav: activity feed of the people you follow
  ///
  /// In en, this message translates to:
  /// **'Atts'**
  String get navAtts;

  /// Bottom nav: marathons and film clubs, like a cinema schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navProgramacao;

  /// Bottom nav: movie search and browsing
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalogo;

  /// Bottom nav: news articles
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get navNoticias;

  /// Direct messages icon in the Atts app bar
  ///
  /// In en, this message translates to:
  /// **'Whispers'**
  String get attsWhispers;

  /// Programação top tab
  ///
  /// In en, this message translates to:
  /// **'Marathons'**
  String get programacaoMaratonasTab;

  /// Programação top tab
  ///
  /// In en, this message translates to:
  /// **'Film clubs'**
  String get programacaoCineClubesTab;

  /// Filter: only events the user joined
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get programacaoParticipatingFilter;

  /// Placeholder until marathons ship
  ///
  /// In en, this message translates to:
  /// **'Movie marathons with challenges and deadlines will show up here.'**
  String get programacaoMaratonasComingSoon;

  /// Placeholder until film clubs ship
  ///
  /// In en, this message translates to:
  /// **'Film clubs: one movie, one period and a discussion day.'**
  String get programacaoCineClubesComingSoon;

  /// Screen reader label of a color swatch
  ///
  /// In en, this message translates to:
  /// **'Color {index} of {total}'**
  String colorPickerOption(int index, int total);

  /// How many emotions are selected
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} emotions'**
  String emotionPickerCount(int count, int max);

  /// Minutes watched of the runtime
  ///
  /// In en, this message translates to:
  /// **'{watched} of {total} min'**
  String movieProgressMinutes(int watched, int total);

  /// Title of the shelf form when editing
  ///
  /// In en, this message translates to:
  /// **'Edit shelf'**
  String get editShelfTitle;

  /// Saves a shelf of someone else
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get shelfSave;

  /// Shown on the form of Watched / Watchlist
  ///
  /// In en, this message translates to:
  /// **'Default shelf: it can\'t be renamed or deleted'**
  String get systemShelfLockedHint;

  /// Shelf menu action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get shelfEdit;

  /// Shelf menu action
  ///
  /// In en, this message translates to:
  /// **'Delete shelf'**
  String get shelfDelete;

  /// Delete shelf confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String shelfDeleteConfirmTitle(String name);

  /// Delete shelf confirmation message
  ///
  /// In en, this message translates to:
  /// **'The movies stay in your history.'**
  String get shelfDeleteConfirmMessage;

  /// Shelf menu action
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get shelfPin;

  /// Shelf menu action
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get shelfUnpin;

  /// Action to drag shelves into a new order
  ///
  /// In en, this message translates to:
  /// **'Reorder shelves'**
  String get shelfReorder;

  /// Ends reorder mode
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get shelfReorderDone;

  /// Screen reader label of the pinned icon
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get shelfPinned;

  /// Shelf counter
  ///
  /// In en, this message translates to:
  /// **'{watched}/{total} watched'**
  String shelfWatchedOfTotal(int watched, int total);

  /// Create shelf button
  ///
  /// In en, this message translates to:
  /// **'New shelf'**
  String get shelfNew;

  /// Add movies to the shelf
  ///
  /// In en, this message translates to:
  /// **'Add movies'**
  String get shelfAddMovies;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get shelfFilterWatched;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'Not watched'**
  String get shelfFilterNotWatched;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'Decade'**
  String get shelfFilterDecade;

  /// Selected decade, e.g. 1980s
  ///
  /// In en, this message translates to:
  /// **'{decade}s'**
  String shelfFilterDecadeValue(int decade);

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get shelfFilterGenre;

  /// Clears one filter
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get shelfFilterAny;

  /// Clears every filter
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get shelfFilterClear;

  /// Empty state with filters on
  ///
  /// In en, this message translates to:
  /// **'No movies match these filters'**
  String get shelfEmptyFiltered;

  /// Sort menu title
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get shelfSortBy;

  /// Sorts now and keeps the result as the manual order
  ///
  /// In en, this message translates to:
  /// **'Apply only once'**
  String get shelfSortApplyOnce;

  /// Applies the chosen order
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get shelfSortApply;

  /// Drag movies into a manual order
  ///
  /// In en, this message translates to:
  /// **'Reorder movies'**
  String get shelfManualOrder;

  /// Movie menu action
  ///
  /// In en, this message translates to:
  /// **'Remove from shelf'**
  String get shelfMovieRemove;

  /// Movie menu action
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get shelfMovieMoveTo;

  /// Movie menu action
  ///
  /// In en, this message translates to:
  /// **'Copy to…'**
  String get shelfMovieCopyTo;

  /// Shelf menu action
  ///
  /// In en, this message translates to:
  /// **'Move all to…'**
  String get shelfMoveAll;

  /// Shelf menu action
  ///
  /// In en, this message translates to:
  /// **'Copy all to…'**
  String get shelfCopyAll;

  /// Title of the target shelf picker
  ///
  /// In en, this message translates to:
  /// **'Choose a shelf'**
  String get shelfPickTarget;

  /// Confirmation when removing from Watched
  ///
  /// In en, this message translates to:
  /// **'Unmark as watched?'**
  String get shelfUnmarkWatchedTitle;

  /// Confirmation when removing from Watched
  ///
  /// In en, this message translates to:
  /// **'Your logs of this movie are kept.'**
  String get shelfUnmarkWatchedMessage;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Unmark'**
  String get shelfUnmarkWatchedConfirm;

  /// Snackbar when a shelf action fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t finish that. Try again.'**
  String get shelfActionError;

  /// Movie detail action
  ///
  /// In en, this message translates to:
  /// **'Add to shelf…'**
  String get addToShelvesAction;

  /// Multi-select sheet title
  ///
  /// In en, this message translates to:
  /// **'Add to shelves'**
  String get addToShelvesTitle;

  /// Multi-select sheet button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addToShelvesSave;

  /// Snackbar after adding
  ///
  /// In en, this message translates to:
  /// **'Saved to {count, plural, =1{1 shelf} other{{count} shelves}}'**
  String addToShelvesSaved(int count);

  /// Movie action that opens the session form
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get watchLogAction;

  /// Title of the session form
  ///
  /// In en, this message translates to:
  /// **'Log a session'**
  String get watchLogTitle;

  /// Title of the session form when editing
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get watchLogEditTitle;

  /// Session form field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get watchLogDate;

  /// Session form section: watched / minutes / percent
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get watchLogProgress;

  /// Percent watched in the session form
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String watchLogPercentValue(int percent);

  /// Minutes watched when the runtime is unknown
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String watchLogMinutesValue(int minutes);

  /// Session form section
  ///
  /// In en, this message translates to:
  /// **'Where you watched'**
  String get watchLogVenue;

  /// Session form field
  ///
  /// In en, this message translates to:
  /// **'Service or theater (optional)'**
  String get watchLogProvider;

  /// Session form section
  ///
  /// In en, this message translates to:
  /// **'How did it feel?'**
  String get watchLogEmotions;

  /// Session form button
  ///
  /// In en, this message translates to:
  /// **'Add GIF'**
  String get watchLogAddGif;

  /// Session form button
  ///
  /// In en, this message translates to:
  /// **'Remove GIF'**
  String get watchLogRemoveGif;

  /// Session form field
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get watchLogComment;

  /// Session and rating form switch
  ///
  /// In en, this message translates to:
  /// **'Contains spoilers'**
  String get watchLogSpoiler;

  /// Session form section
  ///
  /// In en, this message translates to:
  /// **'Who can see it'**
  String get watchLogVisibility;

  /// Session form button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get watchLogSave;

  /// Snackbar after logging
  ///
  /// In en, this message translates to:
  /// **'Session logged'**
  String get watchLogSaved;

  /// Snackbar when logging fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the session. Try again.'**
  String get watchLogError;

  /// GIF picker search field
  ///
  /// In en, this message translates to:
  /// **'Search GIFs'**
  String get gifSearchHint;

  /// GIF picker section
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get gifRecent;

  /// GIF picker error
  ///
  /// In en, this message translates to:
  /// **'GIF search is unavailable right now.'**
  String get gifSearchUnavailable;

  /// GIF picker title
  ///
  /// In en, this message translates to:
  /// **'Pick a GIF'**
  String get gifPickerTitle;

  /// Screen reader label of a GIF in a session
  ///
  /// In en, this message translates to:
  /// **'GIF'**
  String get gifLabel;

  /// Title of the rating form
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get ratingTitle;

  /// Question above the rating labels
  ///
  /// In en, this message translates to:
  /// **'Which option best reflects your final rating?'**
  String get ratingPrompt;

  /// Rating form field
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get ratingReview;

  /// Rating form switch
  ///
  /// In en, this message translates to:
  /// **'Create a 100% session'**
  String get ratingCreateLog;

  /// Rating form button
  ///
  /// In en, this message translates to:
  /// **'Save rating'**
  String get ratingSave;

  /// Rating form button
  ///
  /// In en, this message translates to:
  /// **'Remove rating'**
  String get ratingRemove;

  /// Snackbar when rating fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the rating. Try again.'**
  String get ratingError;

  /// Movie action that opens a new cycle
  ///
  /// In en, this message translates to:
  /// **'Watch again'**
  String get rewatchAction;

  /// Snackbar after starting a rewatch
  ///
  /// In en, this message translates to:
  /// **'Rewatch started'**
  String get rewatchStarted;

  /// Profile header card and movie toggle
  ///
  /// In en, this message translates to:
  /// **'Watching now'**
  String get watchingNowTitle;

  /// Progress when the runtime is unknown
  ///
  /// In en, this message translates to:
  /// **'{percent}% watched'**
  String watchProgressPercent(int percent);

  /// Snackbar when a movie action fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update. Try again.'**
  String get watchStateError;

  /// Title of a movie's session history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// History summary
  ///
  /// In en, this message translates to:
  /// **'{minutes} min watched'**
  String historyMinutes(int minutes);

  /// History summary
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String historySessions(int count);

  /// History summary
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No rewatches} =1{1 rewatch} other{{count} rewatches}}'**
  String historyRewatches(int count);

  /// History header of cycle 1
  ///
  /// In en, this message translates to:
  /// **'First watch'**
  String get historyFirstWatch;

  /// History header of a rewatch cycle
  ///
  /// In en, this message translates to:
  /// **'Rewatch {number}'**
  String historyRewatch(int number);

  /// Empty history
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get historyEmpty;

  /// Session menu action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get historyEdit;

  /// Session menu action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDelete;

  /// Confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get historyDeleteTitle;

  /// Confirmation message
  ///
  /// In en, this message translates to:
  /// **'The progress is recalculated. The movie stays in Watched.'**
  String get historyDeleteMessage;

  /// Hidden spoiler text
  ///
  /// In en, this message translates to:
  /// **'Spoiler. Tap to show'**
  String get spoilerReveal;

  /// Comments sheet of a session or rating
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get threadCommentsTitle;

  /// Comment field hint
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get threadCommentHint;

  /// Comment send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get threadCommentSend;

  /// Comment menu action
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get threadCommentDelete;

  /// Empty comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get threadCommentsEmpty;

  /// Snackbar when commenting fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the comment. Try again.'**
  String get threadCommentError;

  /// Edit profile section with the import buttons
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get editProfileImportSection;

  /// Title of the import screens
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importTitle;

  /// Explanation on the import start screen
  ///
  /// In en, this message translates to:
  /// **'Bring your Filmow history: watched movies go to Watched, your watchlist to Want to watch and your lists become shelves. Nothing is saved before you confirm.'**
  String get importIntro;

  /// Button that opens the Filmow login and starts the import
  ///
  /// In en, this message translates to:
  /// **'Sign in to Filmow and import'**
  String get importStartFilmow;

  /// Title of the alert shown before the Filmow login
  ///
  /// In en, this message translates to:
  /// **'Wait after signing in'**
  String get importFilmowWaitTitle;

  /// Alert and banner telling the user to wait for the Filmow login screen to close by itself
  ///
  /// In en, this message translates to:
  /// **'After you sign in to Filmow, you MUST wait for the screen to close on its own. Don\'t close it yourself, or the import won\'t start.'**
  String get importFilmowWaitMessage;

  /// Button that dismisses the Filmow login alert
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get importFilmowWaitConfirm;

  /// Header of the import history
  ///
  /// In en, this message translates to:
  /// **'Previous imports'**
  String get importHistoryTitle;

  /// Snackbar when another import is running
  ///
  /// In en, this message translates to:
  /// **'You already have an import running.'**
  String get importInProgress;

  /// Snackbar when starting the import fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the import. Try again.'**
  String get importStartError;

  /// Snackbar when confirming or cancelling fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get importActionError;

  /// Status of an import job
  ///
  /// In en, this message translates to:
  /// **'{status, select, pending{Starting} reading{Reading} preview{Waiting for you} importing{Importing} done{Done} failed{Failed} cancelled{Cancelled} other{}}'**
  String importStatusLabel(String status);

  /// Import job while reading the source
  ///
  /// In en, this message translates to:
  /// **'Reading your Filmow profile'**
  String get importReadingTitle;

  /// Import job while reading the source
  ///
  /// In en, this message translates to:
  /// **'This can take a few minutes. You can leave this screen: the preview will be waiting for you here.'**
  String get importReadingMessage;

  /// Import preview header
  ///
  /// In en, this message translates to:
  /// **'Ready to import'**
  String get importPreviewTitle;

  /// Import preview count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie → Watched} other{{count} movies → Watched}}'**
  String importPreviewWatched(int count);

  /// Import preview count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie → Want to watch} other{{count} movies → Want to watch}}'**
  String importPreviewWatchlist(int count);

  /// Import preview count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 favorite becomes Favorite} other{{count} favorites become Favorite}}'**
  String importPreviewFavorites(int count);

  /// Import preview count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dated session} other{{count} dated sessions}}'**
  String importPreviewLogs(int count);

  /// Header of the lists to choose on the preview
  ///
  /// In en, this message translates to:
  /// **'Lists → shelves'**
  String get importPreviewLists;

  /// Preview without lists
  ///
  /// In en, this message translates to:
  /// **'No lists found on your profile.'**
  String get importPreviewNoLists;

  /// Visibility selector on the preview
  ///
  /// In en, this message translates to:
  /// **'Who can see the new shelves and sessions'**
  String get importPreviewVisibility;

  /// Confirms the preview
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importConfirm;

  /// Cancels before writing
  ///
  /// In en, this message translates to:
  /// **'Cancel import'**
  String get importCancel;

  /// Import job while writing
  ///
  /// In en, this message translates to:
  /// **'Importing your history'**
  String get importImportingTitle;

  /// Import progress
  ///
  /// In en, this message translates to:
  /// **'{processed} of {total}'**
  String importImportingProgress(int processed, int total);

  /// Import job while writing
  ///
  /// In en, this message translates to:
  /// **'You can leave this screen: we\'ll let you know when it\'s done.'**
  String get importImportingMessage;

  /// Import report header
  ///
  /// In en, this message translates to:
  /// **'Import finished'**
  String get importDoneTitle;

  /// Import report count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 list became a shelf} other{{count} lists became shelves}}'**
  String importDoneShelves(int count);

  /// Import report count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie you already had was kept as it was} other{{count} movies you already had were kept as they were}}'**
  String importDoneKept(int count);

  /// Opens the confirmation queue
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Review 1 movie} other{Review {count} movies}}'**
  String importReviewUnmatched(int count);

  /// Starts a new import (reimporting does not duplicate)
  ///
  /// In en, this message translates to:
  /// **'Import again'**
  String get importAgain;

  /// Import job failed
  ///
  /// In en, this message translates to:
  /// **'The import failed'**
  String get importFailedTitle;

  /// Import job cancelled
  ///
  /// In en, this message translates to:
  /// **'Import cancelled'**
  String get importCancelledTitle;

  /// Import job cancelled
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved.'**
  String get importCancelledMessage;

  /// Title of the confirmation queue
  ///
  /// In en, this message translates to:
  /// **'Confirm movies'**
  String get importUnmatchedTitle;

  /// Confirmation queue explanation
  ///
  /// In en, this message translates to:
  /// **'We weren\'t sure about these movies. They are already on your shelves: pick the right one or skip.'**
  String get importUnmatchedHint;

  /// Keeps the movie as imported
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get importUnmatchedSkip;

  /// Unmatched movie without TMDB candidates
  ///
  /// In en, this message translates to:
  /// **'No suggestions found.'**
  String get importUnmatchedNoCandidates;

  /// Resolved unmatched movie
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get importUnmatchedMatched;

  /// Skipped unmatched movie
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get importUnmatchedSkipped;

  /// Empty confirmation queue
  ///
  /// In en, this message translates to:
  /// **'Every movie was matched.'**
  String get importUnmatchedEmpty;

  /// Snackbar when an import finishes in the background
  ///
  /// In en, this message translates to:
  /// **'Your Filmow import is done'**
  String get importFinishedSnack;

  /// Snackbar action that opens the import report
  ///
  /// In en, this message translates to:
  /// **'See report'**
  String get importSeeReport;

  /// Call to action on the empty Watched shelf
  ///
  /// In en, this message translates to:
  /// **'Already use Filmow? Bring your history'**
  String get watchedEmptyImport;

  /// Tooltip of the create locadora button
  ///
  /// In en, this message translates to:
  /// **'New locadora'**
  String get locadoraNew;

  /// Title of the edit locadora bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Edit locadora'**
  String get editLocadoraTitle;

  /// Locadora menu action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get locadoraEdit;

  /// Locadora menu action
  ///
  /// In en, this message translates to:
  /// **'Delete locadora'**
  String get locadoraDelete;

  /// Delete locadora confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String locadoraDeleteConfirmTitle(String name);

  /// Delete locadora confirmation message
  ///
  /// In en, this message translates to:
  /// **'The shelves stay on your profile.'**
  String get locadoraDeleteConfirmMessage;

  /// Starts drag-to-reorder of the locadoras
  ///
  /// In en, this message translates to:
  /// **'Reorder locadoras'**
  String get locadoraReorder;

  /// Empty Locadoras tab title
  ///
  /// In en, this message translates to:
  /// **'No locadoras yet'**
  String get locadoraEmptyTitle;

  /// Empty Locadoras tab message on my profile
  ///
  /// In en, this message translates to:
  /// **'Group your shelves like the aisles of a video store.'**
  String get locadoraEmptyMessage;

  /// Empty Locadoras tab message on another profile
  ///
  /// In en, this message translates to:
  /// **'Nothing to show here yet.'**
  String get locadoraEmptyOtherMessage;

  /// Locadora form switch
  ///
  /// In en, this message translates to:
  /// **'Hide its shelves from the Shelves tab'**
  String get locadoraHideInProfile;

  /// Locadora form switch
  ///
  /// In en, this message translates to:
  /// **'Hide its shelves from the filters'**
  String get locadoraHideInFilters;

  /// Owner line in the locadora header
  ///
  /// In en, this message translates to:
  /// **'by @{username}'**
  String locadoraByOwner(String username);

  /// Opens the shelf picker of a locadora
  ///
  /// In en, this message translates to:
  /// **'Choose shelves'**
  String get locadoraChooseShelves;

  /// Empty locadora detail
  ///
  /// In en, this message translates to:
  /// **'This locadora has no shelves yet.'**
  String get locadoraNoShelves;

  /// Title of the shelf picker
  ///
  /// In en, this message translates to:
  /// **'Shelves in the locadora'**
  String get locadoraPickShelvesTitle;

  /// Shelf picker without shelves
  ///
  /// In en, this message translates to:
  /// **'Create a shelf first.'**
  String get locadoraPickShelvesEmpty;

  /// A shelf without movies inside a locadora
  ///
  /// In en, this message translates to:
  /// **'Empty shelf'**
  String get locadoraShelfEmpty;

  /// Progress of a locadora
  ///
  /// In en, this message translates to:
  /// **'{watched} of {total} movies watched'**
  String locadoraProgress(int watched, int total);

  /// Opens a shelf from a locadora
  ///
  /// In en, this message translates to:
  /// **'Open shelf'**
  String get locadoraOpenShelf;

  /// Profile tab with the configurable highlights
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get profileTabHighlights;

  /// Profile tab and counter of watch sessions
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get profileTabLogs;

  /// Counter of watched movies on the profile header
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get profileStatWatched;

  /// Counter of CineClubes on the profile header
  ///
  /// In en, this message translates to:
  /// **'CineClubes'**
  String get profileStatCineclubes;

  /// Shown when the profile owner follows the viewer
  ///
  /// In en, this message translates to:
  /// **'Follows you'**
  String get profileFollowsYou;

  /// Own profile without a handle
  ///
  /// In en, this message translates to:
  /// **'Pick your @ so friends can find you'**
  String get profilePickHandleTip;

  /// Unknown id or @handle
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// Share button of the profile header
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get profileShare;

  /// Text shared with the profile link
  ///
  /// In en, this message translates to:
  /// **'{name} on Muuvie: {link}'**
  String profileShareText(String name, String link);

  /// Watched counter of a discovered profile
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no movies watched} =1{1 movie watched} other{{count} movies watched}}'**
  String profileWatchedCount(int count);

  /// Opens the highlights editor
  ///
  /// In en, this message translates to:
  /// **'Edit highlights'**
  String get highlightsEdit;

  /// Empty highlights on the own profile
  ///
  /// In en, this message translates to:
  /// **'Show off your taste'**
  String get highlightsEmptyOwnTitle;

  /// Empty highlights on the own profile
  ///
  /// In en, this message translates to:
  /// **'Pick a top 4, a shelf, a locadora and a soundtrack.'**
  String get highlightsEmptyOwnMessage;

  /// Empty highlights on another profile
  ///
  /// In en, this message translates to:
  /// **'Nothing highlighted yet.'**
  String get highlightsEmptyOther;

  /// Title of a highlight section
  ///
  /// In en, this message translates to:
  /// **'{type, select, top4{Top 4} shelf{Featured shelf} locadora{Featured locadora} soundtrack{Soundtrack} other{Highlight}}'**
  String highlightTitle(String type);

  /// Opens the soundtrack link, in the service of the link
  ///
  /// In en, this message translates to:
  /// **'{service, select, youtubeMusic{Listen on YouTube Music} other{Listen on Spotify}}'**
  String highlightSoundtrackOpen(String service);

  /// Configures an empty highlight
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get highlightChoose;

  /// Changes a configured highlight
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get highlightChange;

  /// Highlight without configuration
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get highlightNotSet;

  /// Hint of the top 4 picker
  ///
  /// In en, this message translates to:
  /// **'Pick up to 4 movies you watched, in order.'**
  String get highlightTop4Pick;

  /// Movies picked for the top 4
  ///
  /// In en, this message translates to:
  /// **'{count} of 4'**
  String highlightTop4Count(int count);

  /// Top 4 picker without watched movies
  ///
  /// In en, this message translates to:
  /// **'Mark movies as watched to pick your top 4.'**
  String get highlightTop4Empty;

  /// Field of the soundtrack link
  ///
  /// In en, this message translates to:
  /// **'Spotify or YouTube Music link'**
  String get highlightSoundtrackHint;

  /// Invalid soundtrack link
  ///
  /// In en, this message translates to:
  /// **'Paste a link from open.spotify.com or music.youtube.com'**
  String get highlightSoundtrackInvalid;

  /// Saving the highlights failed
  ///
  /// In en, this message translates to:
  /// **'Could not save the highlights'**
  String get highlightsSaveError;

  /// Empty Registros tab on the own profile
  ///
  /// In en, this message translates to:
  /// **'Your sessions show up here.'**
  String get diaryEmptyOwn;

  /// Empty Registros tab on another profile
  ///
  /// In en, this message translates to:
  /// **'No sessions to show.'**
  String get diaryEmptyOther;

  /// Saves the profile or the highlights
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editProfileSave;

  /// Saving the profile failed
  ///
  /// In en, this message translates to:
  /// **'Could not save the profile'**
  String get editProfileSaveError;

  /// The backend refused a field
  ///
  /// In en, this message translates to:
  /// **'Check the fields: a link or an image may be invalid'**
  String get editProfileInvalidField;

  /// Display name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileDisplayNameLabel;

  /// Handle field
  ///
  /// In en, this message translates to:
  /// **'@handle'**
  String get editProfileHandleLabel;

  /// Placeholder of the handle field
  ///
  /// In en, this message translates to:
  /// **'5 to 30 letters, digits, . or _'**
  String get editProfileHandleHint;

  /// Handle check in progress
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get editProfileHandleChecking;

  /// Handle is free
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get editProfileHandleAvailable;

  /// Handle used by someone else
  ///
  /// In en, this message translates to:
  /// **'This @ is already taken'**
  String get editProfileHandleTaken;

  /// Handle with an invalid format
  ///
  /// In en, this message translates to:
  /// **'Use 5 to 30 lowercase letters, digits, dots or underscores'**
  String get editProfileHandleInvalid;

  /// Pronouns field
  ///
  /// In en, this message translates to:
  /// **'Pronouns'**
  String get editProfilePronounsLabel;

  /// Placeholder of the pronouns field
  ///
  /// In en, this message translates to:
  /// **'e.g. she/her'**
  String get editProfilePronounsPlaceholder;

  /// Links section
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get editProfileLinksLabel;

  /// Adds a link field
  ///
  /// In en, this message translates to:
  /// **'Add link'**
  String get editProfileAddLink;

  /// Accent color section
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get editProfileAccentLabel;

  /// Use the app accent color
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get editProfileAccentDefault;

  /// Images section
  ///
  /// In en, this message translates to:
  /// **'Photo and banner'**
  String get editProfileImagesLabel;

  /// There is no upload yet
  ///
  /// In en, this message translates to:
  /// **'Paste an image link. Uploading files comes later.'**
  String get editProfileImagesHint;

  /// Avatar URL field
  ///
  /// In en, this message translates to:
  /// **'Photo link'**
  String get editProfileAvatarUrlLabel;

  /// Banner URL field
  ///
  /// In en, this message translates to:
  /// **'Banner link'**
  String get editProfileBannerUrlLabel;

  /// Discovery section of new releases
  ///
  /// In en, this message translates to:
  /// **'In theaters and new'**
  String get discoverReleases;

  /// Discovery section of public shelves
  ///
  /// In en, this message translates to:
  /// **'Most popular shelves'**
  String get discoverShelves;

  /// Discovery section of public locadoras
  ///
  /// In en, this message translates to:
  /// **'Community locadoras'**
  String get discoverLocadoras;

  /// Discovery section of profiles
  ///
  /// In en, this message translates to:
  /// **'Cinéfilos to follow'**
  String get discoverProfiles;

  /// Browse section of the catalog
  ///
  /// In en, this message translates to:
  /// **'Explore the catalog'**
  String get discoverExplore;

  /// Empty discovery list
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get discoverEmpty;

  /// Curated profile
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get discoverFeatured;

  /// Search results tab
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get searchTabMovies;

  /// Source filter without a source
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get newsAllSources;

  /// Mark of an article already opened
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get newsRead;

  /// Movies quoted by an article
  ///
  /// In en, this message translates to:
  /// **'Movies in this story'**
  String get newsMoviesTitle;

  /// Adds a movie to Quero ver
  ///
  /// In en, this message translates to:
  /// **'Want to watch'**
  String get newsWantToWatch;

  /// Movie already on Quero ver
  ///
  /// In en, this message translates to:
  /// **'In Want to watch'**
  String get newsInWantToWatch;

  /// Movie already watched
  ///
  /// In en, this message translates to:
  /// **'Already watched'**
  String get newsWatched;

  /// Opens the shelves picker
  ///
  /// In en, this message translates to:
  /// **'Add to shelf'**
  String get newsAddToShelf;

  /// Snack after adding a movie to Quero ver
  ///
  /// In en, this message translates to:
  /// **'{title} is in Want to watch'**
  String newsAddedToWatchlist(String title);

  /// Adding to Quero ver failed
  ///
  /// In en, this message translates to:
  /// **'Could not add the movie'**
  String get newsWantToWatchError;

  /// Movies directed by a person
  ///
  /// In en, this message translates to:
  /// **'Directed'**
  String get personDirected;

  /// Movies a person acted in
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get personActed;

  /// Person without known movies
  ///
  /// In en, this message translates to:
  /// **'No movies from the catalog yet.'**
  String get personNoCredits;

  /// Atts filter: me and the people I follow
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get attsScopeAll;

  /// Atts filter: only the people I follow
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get attsScopeFollowing;

  /// Atts filter: only my activities
  ///
  /// In en, this message translates to:
  /// **'Just me'**
  String get attsScopeMe;

  /// Empty Atts feed title
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get attsEmptyTitle;

  /// Empty feed of the people I follow
  ///
  /// In en, this message translates to:
  /// **'Follow people to see what they watch.'**
  String get attsEmptyFollowing;

  /// Empty feed of my own activities
  ///
  /// In en, this message translates to:
  /// **'What you log, rate and create shows up here.'**
  String get attsEmptyMe;

  /// Screen reader label of the whispers button with a badge
  ///
  /// In en, this message translates to:
  /// **'Whispers, {count} unread'**
  String attsWhispersUnread(int count);

  /// Atts app bar button that opens my follow lists
  ///
  /// In en, this message translates to:
  /// **'Following and followers'**
  String get attsFollowsAction;

  /// Feed: after the user name, before the movie title
  ///
  /// In en, this message translates to:
  /// **'logged a session of'**
  String get activityVerbSession;

  /// Feed: finished a movie
  ///
  /// In en, this message translates to:
  /// **'watched'**
  String get activityVerbFinished;

  /// Feed: finished a rewatch
  ///
  /// In en, this message translates to:
  /// **'rewatched'**
  String get activityVerbRewatched;

  /// Feed: rated a movie
  ///
  /// In en, this message translates to:
  /// **'rated'**
  String get activityVerbRating;

  /// Feed: new shelf
  ///
  /// In en, this message translates to:
  /// **'created the shelf'**
  String get activityVerbNewShelf;

  /// Feed: shelf featured on the profile
  ///
  /// In en, this message translates to:
  /// **'featured the shelf'**
  String get activityVerbFeaturedShelf;

  /// Feed: new locadora (collection of shelves)
  ///
  /// In en, this message translates to:
  /// **'opened the locadora'**
  String get activityVerbNewLocadora;

  /// Feed: watching now
  ///
  /// In en, this message translates to:
  /// **'is watching'**
  String get activityVerbWatchingNow;

  /// Feed: finished an import
  ///
  /// In en, this message translates to:
  /// **'imported their movies from {source}'**
  String activityVerbImported(String source);

  /// Feed: a type this version does not know
  ///
  /// In en, this message translates to:
  /// **'did something new'**
  String get activityVerbOther;

  /// Feed: movies an import added
  ///
  /// In en, this message translates to:
  /// **'{watched} watched · {watchlist} to watch'**
  String activityImportCounts(int watched, int watchlist);

  /// Give an amei (like) to an activity
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get activityLove;

  /// Take back an amei
  ///
  /// In en, this message translates to:
  /// **'Remove love'**
  String get activityUnlove;

  /// Screen reader count of amei
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 love} other{{count} loves}}'**
  String activityLovesCount(int count);

  /// Menu of my activity
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get activityMoreOptions;

  /// Hide my activity from everyone else's feed
  ///
  /// In en, this message translates to:
  /// **'Hide from others'**
  String get activityHide;

  /// Show a hidden activity again
  ///
  /// In en, this message translates to:
  /// **'Show it again'**
  String get activityShow;

  /// Label of a hidden activity
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get activityHidden;

  /// After hiding an activity
  ///
  /// In en, this message translates to:
  /// **'Only you see it now'**
  String get activityHiddenSnack;

  /// Relative time: less than a minute
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeNow;

  /// Relative time in minutes
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String timeMinutes(int count);

  /// Relative time in hours
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String timeHours(int count);

  /// Relative time in days
  ///
  /// In en, this message translates to:
  /// **'{count} d'**
  String timeDays(int count);

  /// Follow someone who already follows you
  ///
  /// In en, this message translates to:
  /// **'Follow back'**
  String get followBackLabel;

  /// Follow rate limit reached
  ///
  /// In en, this message translates to:
  /// **'Too many follows in a row. Try again in a minute.'**
  String get followRateLimited;

  /// Follow or unfollow failed
  ///
  /// In en, this message translates to:
  /// **'Could not update the follow'**
  String get followError;

  /// Empty followers list
  ///
  /// In en, this message translates to:
  /// **'No followers yet.'**
  String get followsEmptyFollowers;

  /// Empty following list
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet.'**
  String get followsEmptyFollowing;

  /// Empty conversations list
  ///
  /// In en, this message translates to:
  /// **'No whispers yet'**
  String get whispersEmptyTitle;

  /// How to start a conversation
  ///
  /// In en, this message translates to:
  /// **'Whisper from the profile of someone who follows you back.'**
  String get whispersEmptyMessage;

  /// Open the conversation with a mutual from their profile
  ///
  /// In en, this message translates to:
  /// **'Whisper'**
  String get whisperAction;

  /// Message input hint
  ///
  /// In en, this message translates to:
  /// **'Write a whisper'**
  String get whisperHint;

  /// Send a whisper
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get whisperSend;

  /// Conversation read-only notice
  ///
  /// In en, this message translates to:
  /// **'You can only whisper while you follow each other.'**
  String get whisperDisabled;

  /// System message: the mutual follow ended
  ///
  /// In en, this message translates to:
  /// **'You no longer follow each other. This conversation is read-only.'**
  String get whisperMutualLost;

  /// System message: the mutual follow is back
  ///
  /// In en, this message translates to:
  /// **'You follow each other again.'**
  String get whisperMutualRestored;

  /// Sending a whisper failed
  ///
  /// In en, this message translates to:
  /// **'Could not send. Try again.'**
  String get whisperSendError;

  /// Whisper rate limit reached
  ///
  /// In en, this message translates to:
  /// **'Slow down: too many whispers in a minute.'**
  String get whisperRateLimited;

  /// Preview of my last whisper
  ///
  /// In en, this message translates to:
  /// **'You: {body}'**
  String whisperYou(String body);

  /// Empty conversation
  ///
  /// In en, this message translates to:
  /// **'Say hi to {name}'**
  String whisperStart(String name);

  /// Unread messages of a conversation
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread} other{{count} unread}}'**
  String whisperUnread(int count);

  /// Movie detail: sessions and ratings of the people I follow
  ///
  /// In en, this message translates to:
  /// **'From people you follow'**
  String get movieFollowingActivity;

  /// Programação: search field of the maratona list
  ///
  /// In en, this message translates to:
  /// **'Search marathons'**
  String get maratonaSearchHint;

  /// Maratona list filter and badge: curated maratonas
  ///
  /// In en, this message translates to:
  /// **'Curated'**
  String get maratonaFilterCurated;

  /// Maratona list filter: only maratonas without a password
  ///
  /// In en, this message translates to:
  /// **'No password'**
  String get maratonaFilterOpen;

  /// Maratona list filter: also finished maratonas
  ///
  /// In en, this message translates to:
  /// **'Include finished'**
  String get maratonaFilterFinished;

  /// Maratona list filter: maratonas I created or co-own
  ///
  /// In en, this message translates to:
  /// **'Created by me'**
  String get maratonaFilterMine;

  /// Button that opens the maratona editor
  ///
  /// In en, this message translates to:
  /// **'Create marathon'**
  String get maratonaCreate;

  /// Maratona list: nothing found
  ///
  /// In en, this message translates to:
  /// **'No marathons here'**
  String get maratonaListEmptyTitle;

  /// Maratona list: nothing found
  ///
  /// In en, this message translates to:
  /// **'Create one or change the filters.'**
  String get maratonaListEmptyMessage;

  /// Maratona list with Participando on: nothing joined
  ///
  /// In en, this message translates to:
  /// **'You have not joined a marathon yet.'**
  String get maratonaParticipatingEmpty;

  /// Maratona status: open to join, not started
  ///
  /// In en, this message translates to:
  /// **'Starts soon'**
  String get maratonaStatusUpcoming;

  /// Maratona status: running
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get maratonaStatusActive;

  /// Maratona status: ended
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get maratonaStatusFinished;

  /// Maratona status: cancelled by the owner
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get maratonaStatusCancelled;

  /// Period of a maratona
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String maratonaPeriod(String start, String end);

  /// How many people joined a maratona
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String maratonaParticipants(int count);

  /// A number of challenges
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 challenge} other{{count} challenges}}'**
  String maratonaChallengesCount(int count);

  /// Badge: the user takes part in the maratona
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get maratonaJoined;

  /// Badge: joining asks for a password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get maratonaLocked;

  /// Maratona detail tab
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get maratonaTabAbout;

  /// Maratona detail tab and editor step
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get maratonaTabChallenges;

  /// Maratona detail tab: the shelf created on joining
  ///
  /// In en, this message translates to:
  /// **'My queue'**
  String get maratonaTabQueue;

  /// Maratona detail tab: movies suggested per challenge
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get maratonaTabDiscovery;

  /// Maratona detail tab
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get maratonaTabRanking;

  /// Button: join the maratona
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get maratonaJoin;

  /// Button: leave the maratona
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get maratonaLeave;

  /// Confirmation before leaving
  ///
  /// In en, this message translates to:
  /// **'Leave this marathon?'**
  String get maratonaLeaveTitle;

  /// Confirmation before leaving
  ///
  /// In en, this message translates to:
  /// **'Your queue shelf and the challenges you marked will be removed.'**
  String get maratonaLeaveMessage;

  /// Join sheet title
  ///
  /// In en, this message translates to:
  /// **'Join the marathon'**
  String get maratonaJoinTitle;

  /// Join sheet: pick a level
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get maratonaJoinLevel;

  /// Join sheet: pick a team
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get maratonaJoinTeam;

  /// Join sheet: no team option
  ///
  /// In en, this message translates to:
  /// **'No team'**
  String get maratonaNoTeam;

  /// Join sheet: password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get maratonaPassword;

  /// Join failed: wrong password
  ///
  /// In en, this message translates to:
  /// **'Wrong password.'**
  String get maratonaWrongPassword;

  /// Action on a finished or cancelled maratona
  ///
  /// In en, this message translates to:
  /// **'This marathon is not open.'**
  String get maratonaClosed;

  /// Generic maratona action failure
  ///
  /// In en, this message translates to:
  /// **'Could not complete. Try again.'**
  String get maratonaActionError;

  /// Who created the maratona
  ///
  /// In en, this message translates to:
  /// **'By {name}'**
  String maratonaOwnerBy(String name);

  /// People who also run the maratona
  ///
  /// In en, this message translates to:
  /// **'Co-owners'**
  String get maratonaCoOwners;

  /// Section of the maratona detail
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get maratonaLevels;

  /// Section of the maratona detail and ranking
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get maratonaTeams;

  /// Section of the maratona detail
  ///
  /// In en, this message translates to:
  /// **'Prizes'**
  String get maratonaPrizes;

  /// Section: what people did in the maratona
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get maratonaProgressFeed;

  /// Empty activity of a maratona
  ///
  /// In en, this message translates to:
  /// **'Nothing happened yet.'**
  String get maratonaProgressEmpty;

  /// My progress in a maratona
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} challenges'**
  String maratonaMyProgress(int done, int total);

  /// Link to the maratona community
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get maratonaSocialLink;

  /// Edit the maratona
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get maratonaEdit;

  /// Owner action: cancel the maratona
  ///
  /// In en, this message translates to:
  /// **'Cancel marathon'**
  String get maratonaCancel;

  /// Confirmation before cancelling a maratona
  ///
  /// In en, this message translates to:
  /// **'Nobody will be able to join or mark challenges. This cannot be undone.'**
  String get maratonaCancelMessage;

  /// Confirm cancelling a maratona
  ///
  /// In en, this message translates to:
  /// **'Cancel it'**
  String get maratonaCancelConfirm;

  /// Dismiss a destructive confirmation
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get maratonaKeep;

  /// A challenge completed by its criteria
  ///
  /// In en, this message translates to:
  /// **'Checked automatically'**
  String get maratonaChallengeAuto;

  /// A challenge without criteria
  ///
  /// In en, this message translates to:
  /// **'Marked by hand'**
  String get maratonaChallengeManual;

  /// A daily challenge
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get maratonaChallengeDaily;

  /// A category only for teams
  ///
  /// In en, this message translates to:
  /// **'Team challenges'**
  String get maratonaTeamOnly;

  /// A challenge the user completed
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get maratonaChallengeDone;

  /// A challenge the user has not completed
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get maratonaChallengeOpen;

  /// Tie a movie to a challenge
  ///
  /// In en, this message translates to:
  /// **'Mark with a movie'**
  String get maratonaLinkMovie;

  /// Movie picker source
  ///
  /// In en, this message translates to:
  /// **'From your queue'**
  String get maratonaLinkFromQueue;

  /// Movie picker source
  ///
  /// In en, this message translates to:
  /// **'From your watched movies'**
  String get maratonaLinkFromWatched;

  /// Untie a movie from a challenge
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get maratonaUnlink;

  /// A movie tied by a logged session
  ///
  /// In en, this message translates to:
  /// **'from a session'**
  String get maratonaLinkAuto;

  /// Challenge without movies
  ///
  /// In en, this message translates to:
  /// **'No movie yet.'**
  String get maratonaLinksEmpty;

  /// Marking outside the period
  ///
  /// In en, this message translates to:
  /// **'Challenges can be marked while the marathon runs.'**
  String get maratonaNotRunning;

  /// Marking without joining
  ///
  /// In en, this message translates to:
  /// **'Join to mark challenges.'**
  String get maratonaJoinToMark;

  /// Empty movie picker
  ///
  /// In en, this message translates to:
  /// **'No movies here.'**
  String get maratonaPickerEmpty;

  /// Empty maratona queue
  ///
  /// In en, this message translates to:
  /// **'Your queue is empty. Add movies from Discover.'**
  String get maratonaQueueEmpty;

  /// Open the queue shelf
  ///
  /// In en, this message translates to:
  /// **'Open shelf'**
  String get maratonaQueueOpen;

  /// Queue tab without joining
  ///
  /// In en, this message translates to:
  /// **'Join to get a queue.'**
  String get maratonaQueueJoin;

  /// Add a suggested movie to the queue
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get maratonaAddToQueue;

  /// Movie added to the queue
  ///
  /// In en, this message translates to:
  /// **'Added to your queue'**
  String get maratonaAddedToQueue;

  /// Discovery: challenge selector
  ///
  /// In en, this message translates to:
  /// **'Pick a challenge'**
  String get maratonaDiscoveryPick;

  /// Discovery without criteria challenges
  ///
  /// In en, this message translates to:
  /// **'No challenge here has criteria to suggest movies.'**
  String get maratonaDiscoveryNone;

  /// Ranking segment
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get maratonaRankingUsers;

  /// Empty ranking
  ///
  /// In en, this message translates to:
  /// **'No one has completed a challenge yet.'**
  String get maratonaRankingEmpty;

  /// Position in the ranking
  ///
  /// In en, this message translates to:
  /// **'#{position}'**
  String maratonaRankingPosition(int position);

  /// Members of a team
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String maratonaTeamMembers(int count);

  /// Editor title when creating
  ///
  /// In en, this message translates to:
  /// **'New marathon'**
  String get maratonaEditorNewTitle;

  /// Editor title when editing
  ///
  /// In en, this message translates to:
  /// **'Edit marathon'**
  String get maratonaEditorEditTitle;

  /// Editor start option
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get maratonaEditorFromScratch;

  /// Editor start: templates section
  ///
  /// In en, this message translates to:
  /// **'Or start from a template'**
  String get maratonaEditorTemplates;

  /// Length of a template
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String maratonaTemplateDays(int count);

  /// Editor step
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get maratonaStepDetails;

  /// Editor step
  ///
  /// In en, this message translates to:
  /// **'Levels and teams'**
  String get maratonaStepLevels;

  /// Editor step
  ///
  /// In en, this message translates to:
  /// **'Prizes and privacy'**
  String get maratonaStepPrizes;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get maratonaFieldTitle;

  /// Editor field: the slug of /m/<slug>
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get maratonaFieldSlug;

  /// Help under the address field
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers and hyphens: /m/{slug}'**
  String maratonaSlugHelp(String slug);

  /// Slug already used
  ///
  /// In en, this message translates to:
  /// **'This address is taken.'**
  String get maratonaSlugTaken;

  /// Slug format error
  ///
  /// In en, this message translates to:
  /// **'Use 3 to 50 lowercase letters, numbers or hyphens.'**
  String get maratonaSlugInvalid;

  /// Slug is free
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get maratonaSlugAvailable;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get maratonaFieldDescription;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get maratonaFieldStart;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Ends on'**
  String get maratonaFieldEnd;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get maratonaFieldColor;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Logo (image link)'**
  String get maratonaFieldLogo;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Community link'**
  String get maratonaFieldSocial;

  /// Editor action
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get maratonaAddCategory;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get maratonaCategoryName;

  /// Editor action
  ///
  /// In en, this message translates to:
  /// **'Add challenge'**
  String get maratonaAddChallenge;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get maratonaChallengeDescription;

  /// Editor: criteria of a challenge
  ///
  /// In en, this message translates to:
  /// **'Automatic criteria'**
  String get maratonaCriteria;

  /// Editor: challenge without criteria
  ///
  /// In en, this message translates to:
  /// **'No criteria: marked by hand'**
  String get maratonaCriteriaNone;

  /// Criteria builder field
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get maratonaCriteriaGenres;

  /// Criteria builder field
  ///
  /// In en, this message translates to:
  /// **'Decades'**
  String get maratonaCriteriaDecades;

  /// Criteria builder field
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get maratonaCriteriaCountries;

  /// Criteria builder field
  ///
  /// In en, this message translates to:
  /// **'Original language'**
  String get maratonaCriteriaLanguages;

  /// Criteria builder field
  ///
  /// In en, this message translates to:
  /// **'At least (minutes)'**
  String get maratonaCriteriaRuntimeMin;

  /// Criteria builder field
  ///
  /// In en, this message translates to:
  /// **'At most (minutes)'**
  String get maratonaCriteriaRuntimeMax;

  /// Criteria builder field
  ///
  /// In en, this message translates to:
  /// **'Minimum TMDB score'**
  String get maratonaCriteriaVote;

  /// Hint of the countries and languages fields
  ///
  /// In en, this message translates to:
  /// **'Codes separated by commas, like BR, FR'**
  String get maratonaCriteriaCodesHint;

  /// Criteria builder: rules the builder does not edit
  ///
  /// In en, this message translates to:
  /// **'Other criteria of this challenge are kept.'**
  String get maratonaCriteriaKept;

  /// Criteria builder: confirm
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get maratonaCriteriaApply;

  /// Criteria builder: remove the criteria
  ///
  /// In en, this message translates to:
  /// **'Clear criteria'**
  String get maratonaCriteriaClear;

  /// Editor field of a level
  ///
  /// In en, this message translates to:
  /// **'Challenges to complete'**
  String get maratonaMinChallenges;

  /// Editor action
  ///
  /// In en, this message translates to:
  /// **'Add level'**
  String get maratonaAddLevel;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Level name'**
  String get maratonaLevelName;

  /// Editor: no levels
  ///
  /// In en, this message translates to:
  /// **'Without levels, finishing every challenge completes the marathon.'**
  String get maratonaDefaultLevel;

  /// Editor action
  ///
  /// In en, this message translates to:
  /// **'Add team'**
  String get maratonaAddTeam;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Team name'**
  String get maratonaTeamName;

  /// Editor action
  ///
  /// In en, this message translates to:
  /// **'Add prize'**
  String get maratonaAddPrize;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Prize'**
  String get maratonaPrizeTitle;

  /// Editor field
  ///
  /// In en, this message translates to:
  /// **'Password to join (optional)'**
  String get maratonaFieldPassword;

  /// Editor: password help when editing
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep the current password.'**
  String get maratonaKeepPassword;

  /// Editor switch
  ///
  /// In en, this message translates to:
  /// **'Remove password'**
  String get maratonaRemovePassword;

  /// Editor: save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get maratonaSave;

  /// Editor: next step
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get maratonaNext;

  /// Editor: previous step
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get maratonaBack;

  /// Editor: remove an item
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get maratonaRemove;

  /// Editor validation
  ///
  /// In en, this message translates to:
  /// **'Add at least {min} challenges.'**
  String maratonaMinChallengesError(int min);

  /// Editor validation
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get maratonaRequired;

  /// Editor validation
  ///
  /// In en, this message translates to:
  /// **'The end must be on or after the start.'**
  String get maratonaPeriodError;

  /// Editor: editing after the start
  ///
  /// In en, this message translates to:
  /// **'The marathon started: only texts, color, logo, link and prizes can change.'**
  String get maratonaStartedNote;

  /// Editor save failure
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check the fields and try again.'**
  String get maratonaSaveError;

  /// Feed: created a maratona
  ///
  /// In en, this message translates to:
  /// **'created the marathon'**
  String get activityVerbCreatedMaratona;

  /// Feed: joined a maratona
  ///
  /// In en, this message translates to:
  /// **'joined the marathon'**
  String get activityVerbJoinedMaratona;

  /// Feed: completed a maratona challenge
  ///
  /// In en, this message translates to:
  /// **'completed a challenge in'**
  String get activityVerbFinishedChallenge;

  /// Feed: finished a maratona at a level
  ///
  /// In en, this message translates to:
  /// **'finished the marathon'**
  String get activityVerbFinishedMaratona;

  /// Feed: level reached in a maratona
  ///
  /// In en, this message translates to:
  /// **'Level {level} · {done} of {total} challenges'**
  String activityMaratonaLevel(String level, int done, int total);

  /// Load the next page of a maratona list
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get maratonaLoadMore;

  /// Feed verb: created a CineClube
  ///
  /// In en, this message translates to:
  /// **'created the film club'**
  String get activityVerbCreatedCineClube;

  /// Feed verb: joined a CineClube
  ///
  /// In en, this message translates to:
  /// **'joined the film club'**
  String get activityVerbJoinedCineClube;

  /// Editor: add a session (a movie) to the cycle
  ///
  /// In en, this message translates to:
  /// **'Add movie'**
  String get cineclubeAddSession;

  /// Owner menu and dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel film club'**
  String get cineclubeCancel;

  /// Cancel dialog text
  ///
  /// In en, this message translates to:
  /// **'Nobody will be able to join or change it anymore.'**
  String get cineclubeCancelMessage;

  /// Snack when joining a closed CineClube
  ///
  /// In en, this message translates to:
  /// **'This film club is not open.'**
  String get cineclubeClosed;

  /// Movies of a cycle the user finished
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} movies'**
  String cineclubeCompletedSessions(int done, int total);

  /// Button to create a CineClube
  ///
  /// In en, this message translates to:
  /// **'Create film club'**
  String get cineclubeCreate;

  /// Accessibility label of the current session
  ///
  /// In en, this message translates to:
  /// **'Now showing'**
  String get cineclubeCurrentSession;

  /// Badge: a CineClube with several movies
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cineclubeCycle;

  /// Editor help about cycles
  ///
  /// In en, this message translates to:
  /// **'With more than one movie it becomes a cycle: one movie after another, each with its own period and discussion day.'**
  String get cineclubeCycleHelp;

  /// Link of the debate
  ///
  /// In en, this message translates to:
  /// **'Discussion link (call or chat)'**
  String get cineclubeDebateLink;

  /// Debate day of a session
  ///
  /// In en, this message translates to:
  /// **'Discussion on {date}'**
  String cineclubeDebateOn(String date);

  /// Editor title when editing
  ///
  /// In en, this message translates to:
  /// **'Edit film club'**
  String get cineclubeEditorEditTitle;

  /// Editor title when creating
  ///
  /// In en, this message translates to:
  /// **'New film club'**
  String get cineclubeEditorNewTitle;

  /// Editor date field
  ///
  /// In en, this message translates to:
  /// **'Discussion day'**
  String get cineclubeFieldDebate;

  /// Participants filter: no filter
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get cineclubeFilterAll;

  /// Editor error after the start
  ///
  /// In en, this message translates to:
  /// **'New and changed movies have to start after today.'**
  String get cineclubeFutureSessionError;

  /// Accessibility label of a GIF in a log
  ///
  /// In en, this message translates to:
  /// **'GIF'**
  String get cineclubeGif;

  /// Join button
  ///
  /// In en, this message translates to:
  /// **'Join the film club'**
  String get cineclubeJoin;

  /// Snack after joining
  ///
  /// In en, this message translates to:
  /// **'You joined. The movie is on your Want to watch.'**
  String get cineclubeJoined;

  /// Leave dialog text
  ///
  /// In en, this message translates to:
  /// **'The movie stays on your Want to watch.'**
  String get cineclubeLeaveMessage;

  /// Leave dialog title
  ///
  /// In en, this message translates to:
  /// **'Leave the film club?'**
  String get cineclubeLeaveTitle;

  /// Empty CineClube list
  ///
  /// In en, this message translates to:
  /// **'Create one and invite people to watch a movie together.'**
  String get cineclubeListEmptyMessage;

  /// Empty CineClube list title
  ///
  /// In en, this message translates to:
  /// **'No film clubs here'**
  String get cineclubeListEmptyTitle;

  /// Editor section with one session
  ///
  /// In en, this message translates to:
  /// **'Movie and dates'**
  String get cineclubeMovieAndDates;

  /// Editor error
  ///
  /// In en, this message translates to:
  /// **'Pick the movie of each session.'**
  String get cineclubeMovieRequired;

  /// Editor error
  ///
  /// In en, this message translates to:
  /// **'The movies of a cycle cannot overlap.'**
  String get cineclubeOverlapError;

  /// Empty participants list
  ///
  /// In en, this message translates to:
  /// **'Nobody here yet'**
  String get cineclubeParticipantsEmpty;

  /// Empty list with Participating on
  ///
  /// In en, this message translates to:
  /// **'You have not joined any film club yet.'**
  String get cineclubeParticipatingEmpty;

  /// Editor: session without a movie yet
  ///
  /// In en, this message translates to:
  /// **'Pick a movie'**
  String get cineclubePickMovie;

  /// Participant progress
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get cineclubeProgressCompleted;

  /// Empty progress tab
  ///
  /// In en, this message translates to:
  /// **'Sessions logged by the participants during the period show up here.'**
  String get cineclubeProgressEmptyMessage;

  /// Empty progress tab title
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get cineclubeProgressEmptyTitle;

  /// Participant progress
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get cineclubeProgressPending;

  /// Participant progress
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get cineclubeProgressWatching;

  /// Movie runtime
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String cineclubeRuntime(int minutes);

  /// Editor save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get cineclubeSave;

  /// Search field of the list
  ///
  /// In en, this message translates to:
  /// **'Search film clubs'**
  String get cineclubeSearchHint;

  /// Movie picker search field
  ///
  /// In en, this message translates to:
  /// **'Search a movie'**
  String get cineclubeSearchMovie;

  /// A movie of a cycle
  ///
  /// In en, this message translates to:
  /// **'{number}. {title}'**
  String cineclubeSessionLabel(int number, String title);

  /// Editor: session heading
  ///
  /// In en, this message translates to:
  /// **'Movie {number}'**
  String cineclubeSessionNumber(int number);

  /// Editor: a session that cannot change
  ///
  /// In en, this message translates to:
  /// **'Already started'**
  String get cineclubeSessionStarted;

  /// Section with the sessions of a cycle
  ///
  /// In en, this message translates to:
  /// **'Movies of the cycle'**
  String get cineclubeSessions;

  /// How many movies a CineClube has
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie} other{{count} movies}}'**
  String cineclubeSessionsCount(int count);

  /// Link of the CineClube
  ///
  /// In en, this message translates to:
  /// **'muuvie.app/c/{slug}'**
  String cineclubeSlugHelp(String slug);

  /// Log hidden by the spoiler gate
  ///
  /// In en, this message translates to:
  /// **'Comment hidden until you finish the movie or the discussion day comes.'**
  String get cineclubeSpoilerHidden;

  /// About tab note on spoilers
  ///
  /// In en, this message translates to:
  /// **'Comments stay hidden until you watch it, or until the discussion.'**
  String get cineclubeSpoilerNote;

  /// Detail tab
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get cineclubeTabParticipants;

  /// Detail tab
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get cineclubeTabProgress;

  /// Partial session in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min watched'**
  String cineclubeWatchedMinutes(int minutes);

  /// Partial session in percent
  ///
  /// In en, this message translates to:
  /// **'{percent}% watched'**
  String cineclubeWatchedPercent(int percent);

  /// Watch providers section
  ///
  /// In en, this message translates to:
  /// **'Where to watch'**
  String get cineclubeWhereToWatch;

  /// Goal dialog title
  ///
  /// In en, this message translates to:
  /// **'Movies goal for the year'**
  String get chartsGoalTitle;

  /// Goal dialog button
  ///
  /// In en, this message translates to:
  /// **'Save goal'**
  String get chartsGoalSave;

  /// Goal dialog error
  ///
  /// In en, this message translates to:
  /// **'Type a number between 1 and 5000.'**
  String get chartsGoalInvalid;

  /// Goal card without a goal
  ///
  /// In en, this message translates to:
  /// **'Set how many movies you want to watch in {year}.'**
  String chartsGoalPrompt(String year);

  /// Goal card button
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get chartsGoalSet;

  /// Goal progress
  ///
  /// In en, this message translates to:
  /// **'{watched} of {target} movies in {year}'**
  String chartsGoalProgress(int watched, int target, String year);

  /// Goal card when done
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get chartsGoalReached;

  /// Charts tab empty
  ///
  /// In en, this message translates to:
  /// **'No sessions this year'**
  String get chartsEmptyTitle;

  /// Charts tab empty message
  ///
  /// In en, this message translates to:
  /// **'Sessions logged in the year show up here as charts.'**
  String get chartsEmptyMessage;

  /// Button to the retrospective
  ///
  /// In en, this message translates to:
  /// **'See the {year} retrospective'**
  String chartsOpenRetrospective(String year);

  /// Charts total
  ///
  /// In en, this message translates to:
  /// **'movies'**
  String get chartsMovies;

  /// Charts total
  ///
  /// In en, this message translates to:
  /// **'hours in front of the screen'**
  String get chartsHours;

  /// Charts total
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get chartsSessions;

  /// Charts total
  ///
  /// In en, this message translates to:
  /// **'rewatches'**
  String get chartsRewatches;

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Movies per month'**
  String get chartsMonths;

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get chartsGenres;

  /// Donut slice with the rest
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get chartsOthers;

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Decades'**
  String get chartsDecades;

  /// A decade
  ///
  /// In en, this message translates to:
  /// **'{decade}s'**
  String chartsDecade(String decade);

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get chartsCountries;

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get chartsLanguages;

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Where you watched'**
  String get chartsVenues;

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Directors'**
  String get chartsDirectors;

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get chartsEmotions;

  /// Charts section: finished movies by rating label
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get chartsRatings;

  /// Heatmap title
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get chartsCalendar;

  /// Heatmap accessibility label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sessions on 1 day} other{Sessions on {count} days}}'**
  String chartsCalendarSummary(int count);

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share this story'**
  String get retrospectiveShare;

  /// Text shared with the image
  ///
  /// In en, this message translates to:
  /// **'My {year} in movies on Muuvie'**
  String retrospectiveShareText(String year);

  /// Retrospective without data
  ///
  /// In en, this message translates to:
  /// **'No movies finished this year yet'**
  String get retrospectiveEmpty;

  /// First story
  ///
  /// In en, this message translates to:
  /// **'Your year at the movies'**
  String get retrospectiveIntro;

  /// Unit after a number of movies
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{movie} other{movies}}'**
  String retrospectiveMovies(int count);

  /// Unit after a number of hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{hour in front of the screen} other{hours in front of the screen}}'**
  String retrospectiveHours(int count);

  /// Rewatches of the year
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{And 1 rewatch} other{And {count} rewatches}}'**
  String retrospectiveRewatches(int count);

  /// Story title
  ///
  /// In en, this message translates to:
  /// **'Your genres'**
  String get retrospectiveTopGenres;

  /// Story title
  ///
  /// In en, this message translates to:
  /// **'Directors you watched the most'**
  String get retrospectiveTopDirectors;

  /// Story title
  ///
  /// In en, this message translates to:
  /// **'Faces you saw the most'**
  String get retrospectiveTopActors;

  /// Story title
  ///
  /// In en, this message translates to:
  /// **'The emotion of your year'**
  String get retrospectiveEmotion;

  /// Story title
  ///
  /// In en, this message translates to:
  /// **'Your favorite movie'**
  String get retrospectiveFavorite;

  /// Story title
  ///
  /// In en, this message translates to:
  /// **'Your most movie-filled month'**
  String get retrospectiveBestMonth;

  /// Maratonas of the year
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 maratona finished} other{{count} maratonas finished}}'**
  String retrospectiveMaratonas(int count);

  /// CineClubes of the year
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 film club} other{{count} film clubs}}'**
  String retrospectiveCineclubes(int count);

  /// Goal story
  ///
  /// In en, this message translates to:
  /// **'Goal of {target} movies reached!'**
  String retrospectiveGoalReached(int target);

  /// Goal story
  ///
  /// In en, this message translates to:
  /// **'{watched} of the {target} movies of your goal'**
  String retrospectiveGoalProgress(int watched, int target);

  /// Last story
  ///
  /// In en, this message translates to:
  /// **'See you at the next session'**
  String get retrospectiveOutro;

  /// Feed verb: a new vaquinha
  ///
  /// In en, this message translates to:
  /// **'unlocked the vaquinha'**
  String get activityVerbUnlockedBichinho;

  /// Shelter title
  ///
  /// In en, this message translates to:
  /// **'Vaquinha da Bombonière'**
  String get petShelterTitle;

  /// Profile shortcut before the starter
  ///
  /// In en, this message translates to:
  /// **'Adopt a vaquinha'**
  String get petAdopt;

  /// Starter pack title
  ///
  /// In en, this message translates to:
  /// **'Pick your popcorn bucket'**
  String get petStarterTitle;

  /// Starter pack text
  ///
  /// In en, this message translates to:
  /// **'Your vaquinha grows with the minutes you watch and the sessions you log. The first choice is for good.'**
  String get petStarterMessage;

  /// Starter confirmation
  ///
  /// In en, this message translates to:
  /// **'Adopt {name}?'**
  String petStarterConfirmTitle(String name);

  /// Starter confirmation text
  ///
  /// In en, this message translates to:
  /// **'The first vaquinha cannot be changed later. Others unlock as you watch.'**
  String get petStarterConfirmMessage;

  /// Starter confirmation button
  ///
  /// In en, this message translates to:
  /// **'Adopt'**
  String get petStarterConfirm;

  /// Vaquinha level
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String petLevel(int level);

  /// XP toward the next level
  ///
  /// In en, this message translates to:
  /// **'{xp} of {next} XP'**
  String petXp(int xp, int next);

  /// How XP works
  ///
  /// In en, this message translates to:
  /// **'Each finished movie gives 20 XP, plus 1 for every 10 minutes. Imports do not count.'**
  String get petXpHelp;

  /// Unlocked vaquinhas
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vaquinha} other{{count} vaquinhas}}'**
  String petUnlocked(int count);

  /// Locked vaquinhas section
  ///
  /// In en, this message translates to:
  /// **'To unlock'**
  String get petLocked;

  /// Pin a vaquinha
  ///
  /// In en, this message translates to:
  /// **'Show on my profile'**
  String get petPin;

  /// Rarity
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get petRarityStarter;

  /// Rarity
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get petRarityCommon;

  /// Rarity
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get petRarityRare;

  /// Rarity
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get petRarityLegendary;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Sweet popcorn'**
  String get petPipocaDoce;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Salty popcorn'**
  String get petPipocaSalgada;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Caramel popcorn'**
  String get petPipocaCaramelo;

  /// Starter description
  ///
  /// In en, this message translates to:
  /// **'Loves romance and animation.'**
  String get petPipocaDoceAbout;

  /// Starter description
  ///
  /// In en, this message translates to:
  /// **'Never misses a thriller.'**
  String get petPipocaSalgadaAbout;

  /// Starter description
  ///
  /// In en, this message translates to:
  /// **'Collects classics.'**
  String get petPipocaCarameloAbout;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Clapperboard'**
  String get petClaquete;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get petIngresso;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Little ghost'**
  String get petFantasminha;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Little robot'**
  String get petRobozinho;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Usher'**
  String get petLanterninha;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Film reel'**
  String get petRoloDeFilme;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Dinosaur'**
  String get petDinossauro;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Owl'**
  String get petCoruja;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Trophy'**
  String get petTrofeu;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Projector'**
  String get petProjetor;

  /// Vaquinha name
  ///
  /// In en, this message translates to:
  /// **'Statuette'**
  String get petEstatueta;

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'Starter pack'**
  String get petRuleStarter;

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Watch 1 movie} other{Watch {count} movies}}'**
  String petRuleMovies(int count);

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'Watch {count} minutes'**
  String petRuleMinutes(int count);

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'Watch {count} horror movies'**
  String petRuleHorror(int count);

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'Watch {count} sci-fi movies'**
  String petRuleSciFi(int count);

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'Watch {count} movies from before {year}'**
  String petRuleOldMovies(int count, String year);

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Finish a maratona} other{Finish {count} maratonas}}'**
  String petRuleMaratonas(int count);

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Join a film club} other{Join {count} film clubs}}'**
  String petRuleCineclubes(int count);

  /// Unlock rule
  ///
  /// In en, this message translates to:
  /// **'Complete {count} missions'**
  String petRuleMissions(int count);

  /// Missions title
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missionsTitle;

  /// Missions week
  ///
  /// In en, this message translates to:
  /// **'Week of {start} to {end}'**
  String missionsWeek(String start, String end);

  /// Missions help
  ///
  /// In en, this message translates to:
  /// **'Three new missions every Monday. Their XP goes to your pinned vaquinha.'**
  String get missionsHelp;

  /// Mission reward
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String missionXp(int xp);

  /// Mission done
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get missionDone;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Log {count} sessions'**
  String missionSessions(int count);

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Finish {count} movies'**
  String missionMovies(int count);

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Log {count} sessions with emotions'**
  String missionEmotions(int count);

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Watch a movie of 2h30 or more'**
  String get missionLongMovie;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Watch a movie from before 1970'**
  String get missionClassic;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Watch a documentary'**
  String get missionDocumentary;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Watch a horror movie'**
  String get missionHorror;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Watch an animation'**
  String get missionAnimation;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Watch a movie from Asia'**
  String get missionAsia;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Watch a movie from Africa'**
  String get missionAfrica;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Watch a Brazilian movie'**
  String get missionBrazil;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Join a film club'**
  String get missionCineclube;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Complete a maratona challenge'**
  String get missionChallenge;

  /// Diary title
  ///
  /// In en, this message translates to:
  /// **'Caderninho'**
  String get diaryTitle;

  /// Diary: today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get diaryToday;

  /// Diary navigation
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get diaryPreviousDay;

  /// Diary navigation
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get diaryNextDay;

  /// Diary mood section
  ///
  /// In en, this message translates to:
  /// **'How was your day?'**
  String get diaryMood;

  /// Diary goals section
  ///
  /// In en, this message translates to:
  /// **'Goals ({count} of {max})'**
  String diaryGoals(int count, int max);

  /// Diary add goal
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get diaryAddGoal;

  /// Diary dialog button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get diaryAdd;

  /// Diary goal hint
  ///
  /// In en, this message translates to:
  /// **'Watch Rashomon'**
  String get diaryGoalHint;

  /// Diary empty goals
  ///
  /// In en, this message translates to:
  /// **'No goals for this day.'**
  String get diaryNoGoals;

  /// Drag handle label
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get diaryReorder;

  /// Diary note section
  ///
  /// In en, this message translates to:
  /// **'Desabafo'**
  String get diaryNote;

  /// Diary note hint
  ///
  /// In en, this message translates to:
  /// **'Write whatever you want about today'**
  String get diaryNoteHint;

  /// Diary privacy note
  ///
  /// In en, this message translates to:
  /// **'Only you see your Caderninho.'**
  String get diaryPrivate;

  /// Diary saved
  ///
  /// In en, this message translates to:
  /// **'Day saved'**
  String get diarySaved;

  /// Diary unsaved dialog
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get diaryDiscardTitle;

  /// Diary unsaved dialog text
  ///
  /// In en, this message translates to:
  /// **'The changes of this day will be lost.'**
  String get diaryDiscardMessage;

  /// Diary unsaved dialog button
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get diaryDiscard;

  /// Diary year button
  ///
  /// In en, this message translates to:
  /// **'Year of moods'**
  String get diaryYearTitle;

  /// Diary year sheet title
  ///
  /// In en, this message translates to:
  /// **'Your {year} in moods'**
  String diaryYearOf(String year);

  /// Diary year days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day written} other{{count} days written}}'**
  String diaryYearDays(int count);

  /// Diary top mood
  ///
  /// In en, this message translates to:
  /// **'most of all: {mood}'**
  String diaryYearTop(String mood);

  /// Diary category
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get diaryCategoryMovie;

  /// Diary category
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get diaryCategoryShort;

  /// Diary category
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get diaryCategorySeries;

  /// Diary category
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get diaryCategoryStudy;

  /// Diary category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get diaryCategoryOther;

  /// Mood
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moodGreat;

  /// Mood
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// Mood
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// Mood
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get moodBad;

  /// Mood
  ///
  /// In en, this message translates to:
  /// **'Awful'**
  String get moodAwful;

  /// Watch party title
  ///
  /// In en, this message translates to:
  /// **'Watch party'**
  String get partyTitle;

  /// Watch party intro
  ///
  /// In en, this message translates to:
  /// **'Press play at the same time as your friends: create a room, share the code and start the countdown.'**
  String get partyIntro;

  /// Create a watch party
  ///
  /// In en, this message translates to:
  /// **'Create a room'**
  String get partyCreate;

  /// Watch party title field
  ///
  /// In en, this message translates to:
  /// **'What are you watching?'**
  String get partyFieldTitle;

  /// Join a watch party
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get partyJoin;

  /// Watch party code field
  ///
  /// In en, this message translates to:
  /// **'Room code'**
  String get partyFieldCode;

  /// Watch party not found
  ///
  /// In en, this message translates to:
  /// **'No room with this code.'**
  String get partyNotFound;

  /// Watch party full
  ///
  /// In en, this message translates to:
  /// **'This room is full.'**
  String get partyFull;

  /// Watch party closed
  ///
  /// In en, this message translates to:
  /// **'The room was closed'**
  String get partyClosed;

  /// Accessibility label of the code
  ///
  /// In en, this message translates to:
  /// **'Room code {code}'**
  String partyCodeLabel(String code);

  /// Copy the code
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get partyCopyCode;

  /// Code copied snack
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get partyCodeCopied;

  /// Watch party members
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person in the room} other{{count} people in the room}}'**
  String partyMembers(int count);

  /// Before the countdown
  ///
  /// In en, this message translates to:
  /// **'Waiting for the host to start the countdown'**
  String get partyWaiting;

  /// Before the countdown, seen by the host
  ///
  /// In en, this message translates to:
  /// **'When everyone is ready, start the countdown'**
  String get partyWaitingHost;

  /// Host button
  ///
  /// In en, this message translates to:
  /// **'Start the countdown'**
  String get partyStart;

  /// Host button
  ///
  /// In en, this message translates to:
  /// **'Restart the countdown'**
  String get partyRestart;

  /// Countdown option
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{In 1 second} other{In {seconds} seconds}}'**
  String partyStartIn(int seconds);

  /// Countdown accessibility
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{1 second left} other{{seconds} seconds left}}'**
  String partySecondsLeft(int seconds);

  /// Countdown done
  ///
  /// In en, this message translates to:
  /// **'Play!'**
  String get partyPlay;

  /// Empty chat
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get partyNoMessages;

  /// Chat field
  ///
  /// In en, this message translates to:
  /// **'Say something'**
  String get partyMessageHint;

  /// Send message
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get partySend;

  /// Poster game title
  ///
  /// In en, this message translates to:
  /// **'Poster game'**
  String get posterGameTitle;

  /// Poster accessibility
  ///
  /// In en, this message translates to:
  /// **'A blurred movie poster'**
  String get posterGameHint;

  /// Poster game question
  ///
  /// In en, this message translates to:
  /// **'Which movie is it?'**
  String get posterGameQuestion;

  /// Poster game score
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String posterGameScore(int points);

  /// Poster game streak
  ///
  /// In en, this message translates to:
  /// **'Streak: {count}'**
  String posterGameStreak(int count);

  /// Right answer
  ///
  /// In en, this message translates to:
  /// **'Right!'**
  String get posterGameRight;

  /// Wrong answer
  ///
  /// In en, this message translates to:
  /// **'It was {title}'**
  String posterGameWrong(String title);

  /// Next round
  ///
  /// In en, this message translates to:
  /// **'Next poster'**
  String get posterGameNext;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Muuvie is a movie marathon'**
  String get onboardingWelcomeTitle;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Keep what you watch, take on challenges and watch together with other movie lovers.'**
  String get onboardingWelcomeText;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Shelves and locadoras'**
  String get onboardingShelvesTitle;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Watched and Want to watch are always there. Create your own shelves and group them in locadoras.'**
  String get onboardingShelvesText;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Log every session'**
  String get onboardingLogsTitle;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Stars, emotions, a GIF and a comment for every movie, with who can see each one.'**
  String get onboardingLogsText;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Maratonas and film clubs'**
  String get onboardingProgramacaoTitle;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Join maratonas with challenges that complete themselves, and film clubs with a discussion day and no spoilers.'**
  String get onboardingProgramacaoText;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Friends and a vaquinha'**
  String get onboardingSocialTitle;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Follow people, send Sussurros and raise a vaquinha that grows with every movie.'**
  String get onboardingSocialText;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Bring your history'**
  String get onboardingImportTitle;

  /// Onboarding panel
  ///
  /// In en, this message translates to:
  /// **'Import what you watched, your watchlist and your lists from Filmow. Nothing you made here is overwritten.'**
  String get onboardingImportText;

  /// Onboarding import button
  ///
  /// In en, this message translates to:
  /// **'Import from Filmow'**
  String get onboardingImportFilmow;

  /// Onboarding suggestions
  ///
  /// In en, this message translates to:
  /// **'Showing now'**
  String get onboardingSuggestionsTitle;

  /// Onboarding suggestions
  ///
  /// In en, this message translates to:
  /// **'Open maratonas and film clubs you can join today.'**
  String get onboardingSuggestionsText;

  /// Onboarding without suggestions
  ///
  /// In en, this message translates to:
  /// **'Nothing open right now. Create the first one in Programação!'**
  String get onboardingSuggestionsEmpty;

  /// Onboarding skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Onboarding next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Onboarding last button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// Onboarding dots
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// Settings import
  ///
  /// In en, this message translates to:
  /// **'Import movies'**
  String get settingsImport;

  /// Settings import hint
  ///
  /// In en, this message translates to:
  /// **'From Filmow, without overwriting what you made here'**
  String get settingsImportHint;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Push switch
  ///
  /// In en, this message translates to:
  /// **'Sussurros'**
  String get settingsNotifyMessages;

  /// Push switch
  ///
  /// In en, this message translates to:
  /// **'New followers'**
  String get settingsNotifyFollowers;

  /// Push switch
  ///
  /// In en, this message translates to:
  /// **'Loves on my activities'**
  String get settingsNotifyLoves;

  /// Push switch
  ///
  /// In en, this message translates to:
  /// **'Maratonas I joined'**
  String get settingsNotifyMaratonas;

  /// Push switch
  ///
  /// In en, this message translates to:
  /// **'Discussion day of my film clubs'**
  String get settingsNotifyCineclubes;

  /// Settings warning when the system blocks push
  ///
  /// In en, this message translates to:
  /// **'Notifications are off on this device'**
  String get settingsPushOff;

  /// Below settingsPushOff
  ///
  /// In en, this message translates to:
  /// **'Allow them to get Sussurros and alerts with the app closed. If nothing happens, turn them on in the device settings.'**
  String get settingsPushOffHint;

  /// Asks the system for the push permission
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get settingsPushAllow;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Muuvie'**
  String get settingsAbout;

  /// Settings onboarding
  ///
  /// In en, this message translates to:
  /// **'See the introduction again'**
  String get settingsShowIntro;

  /// Settings logout
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// Logout dialog
  ///
  /// In en, this message translates to:
  /// **'Log out of Muuvie?'**
  String get settingsLogoutTitle;

  /// Movie detail tab with everything people logged about the movie (F12.2)
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get movieDetailRecordsTab;

  /// Empty Logs tab
  ///
  /// In en, this message translates to:
  /// **'Nobody logged this movie yet. Be the first!'**
  String get movieRecordsEmpty;

  /// Community watched count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody watched it yet} =1{1 person watched} other{{count} people watched}}'**
  String movieCommunityWatched(int count);

  /// Community Quero ver count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody wants to watch it yet} =1{1 person wants to watch} other{{count} people want to watch}}'**
  String movieCommunityWantToWatch(int count);

  /// Maratonas and CineClubes the movie is in
  ///
  /// In en, this message translates to:
  /// **'In the Programação'**
  String get movieEventsTitle;

  /// Challenges of a maratona the movie completes
  ///
  /// In en, this message translates to:
  /// **'Counts for: {challenges}'**
  String movieEventCountsFor(String challenges);

  /// Writers label
  ///
  /// In en, this message translates to:
  /// **'Written by'**
  String get movieDetailWrittenBy;

  /// Opens the YouTube trailer
  ///
  /// In en, this message translates to:
  /// **'Watch trailer'**
  String get movieDetailTrailer;

  /// Movie actions
  ///
  /// In en, this message translates to:
  /// **'Create a CineClube with this movie'**
  String get movieDetailCreateCineClube;

  /// Movie actions: synced session
  ///
  /// In en, this message translates to:
  /// **'Watch together'**
  String get movieDetailWatchParty;

  /// Comunidade tab filter: ratings
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get movieActivitiesRatings;

  /// Comunidade tab filter: sessions
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get movieActivitiesUpdates;

  /// Comunidade tab filter: ratings and sessions
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get movieActivitiesEverything;

  /// Comunidade tab filter: people
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get movieActivitiesEveryone;

  /// Comunidade tab filter: people I follow
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get movieActivitiesFollowing;

  /// Comunidade tab filter: my own
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get movieActivitiesOnlyMe;

  /// Movie detail section with the ratings by label
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get movieCommunityTitle;

  /// Public custom shelves with the movie
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 shelf} other{In {count} shelves}}'**
  String movieCommunityShelves(int count);

  /// Most picked emotions of the public sessions
  ///
  /// In en, this message translates to:
  /// **'How people felt'**
  String get movieCommunityFeelings;

  /// Movie detail section with the latest written ratings
  ///
  /// In en, this message translates to:
  /// **'Recent ratings'**
  String get movieRecentRatings;

  /// Opens the Comunidade tab on ratings
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get movieRecentRatingsAll;

  /// Public custom shelves holding the movie
  ///
  /// In en, this message translates to:
  /// **'Shelves with this movie'**
  String get movieShelvesTitle;

  /// Empty list of shelves with the movie
  ///
  /// In en, this message translates to:
  /// **'No public shelf has this movie yet.'**
  String get movieShelvesEmpty;

  /// Owner of a shelf
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String movieShelvesBy(String name);

  /// Expands the synopsis on the movie detail
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get movieDetailReadMore;

  /// Collapses the synopsis on the movie detail
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get movieDetailReadLess;

  /// No description provided for @movieStatWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get movieStatWatched;

  /// No description provided for @movieStatWantToWatch.
  ///
  /// In en, this message translates to:
  /// **'Want to watch'**
  String get movieStatWantToWatch;

  /// No description provided for @movieStatShelves.
  ///
  /// In en, this message translates to:
  /// **'Shelves'**
  String get movieStatShelves;

  /// No description provided for @movieEmotionsAll.
  ///
  /// In en, this message translates to:
  /// **'See all ({count})'**
  String movieEmotionsAll(int count);

  /// No description provided for @movieTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get movieTimelineTitle;

  /// No description provided for @movieTimelineSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get movieTimelineSessions;

  /// No description provided for @movieTimelineMonth.
  ///
  /// In en, this message translates to:
  /// **'{month}: {sessions} sessions, {ratings} ratings'**
  String movieTimelineMonth(String month, int sessions, int ratings);

  /// No description provided for @movieShelvesSection.
  ///
  /// In en, this message translates to:
  /// **'On shelves'**
  String get movieShelvesSection;

  /// No description provided for @movieMaratonasSection.
  ///
  /// In en, this message translates to:
  /// **'Maratonas it counted in'**
  String get movieMaratonasSection;

  /// No description provided for @cineclubeStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get cineclubeStatusFinished;

  /// No description provided for @movieCommunityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody did anything with this movie yet.'**
  String get movieCommunityEmpty;

  /// Movies with the most people logging them this week
  ///
  /// In en, this message translates to:
  /// **'Trending on Muuvie'**
  String get discoverTrending;

  /// Movies with the most Favoritado and Adorei labels
  ///
  /// In en, this message translates to:
  /// **'Most loved on Muuvie'**
  String get discoverMostLoved;

  /// Genre chips at the top of the catalog
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get discoverGenres;

  /// A catalog section that failed to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this section'**
  String get discoverSectionError;

  /// Shown while the movie search has fewer than 3 letters
  ///
  /// In en, this message translates to:
  /// **'Type at least 3 letters'**
  String get searchMinLetters;

  /// Heading of the recent searches
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecent;

  /// Clears the recent searches
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get searchClearRecent;

  /// Removes one recent search
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get searchRemoveRecent;

  /// Search results tab
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get searchTabPeople;

  /// Owner line of a shelf of someone else
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String shelfByOwner(String name);

  /// State of a saved shelf; tapping unsaves it
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get shelfSavedLabel;

  /// Saving or unsaving a shelf failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the saved shelves. Try again.'**
  String get shelfSaveError;

  /// Accessibility hint of the owner line of a shelf or locadora
  ///
  /// In en, this message translates to:
  /// **'Open {name}\'s profile'**
  String shelfOpenOwnerProfile(String name);

  /// Title of the saved shelves list
  ///
  /// In en, this message translates to:
  /// **'Saved shelves'**
  String get savedShelvesTitle;

  /// Opens the saved shelves from my Estantes tab
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedShelvesAction;

  /// Empty saved shelves list
  ///
  /// In en, this message translates to:
  /// **'Shelves you save from other people show up here.'**
  String get savedShelvesEmpty;
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
