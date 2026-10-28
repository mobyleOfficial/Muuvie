import 'package:core/core.dart';

import 'package:common/app_localizations.dart';

/// Localized labels for the shared vocabulary in `package:core`.
///
/// Exhaustive switches make a new enum value fail to compile until it has a label.
extension VocabularyLabels on AppLocalizations {
  String contentVisibility(ContentVisibility visibility) =>
      switch (visibility) {
        ContentVisibility.public => visibilityPublic,
        ContentVisibility.mutual => visibilityMutual,
        ContentVisibility.secret => visibilitySecret,
      };

  String watchMode(WatchMode mode) => switch (mode) {
    WatchMode.watched => watchModeWatched,
    WatchMode.minutes => watchModeMinutes,
    WatchMode.percent => watchModePercent,
  };

  String watchVenue(WatchVenue venue) => switch (venue) {
    WatchVenue.cinema => watchVenueCinema,
    WatchVenue.streaming => watchVenueStreaming,
    WatchVenue.tv => watchVenueTv,
    WatchVenue.physicalMedia => watchVenuePhysicalMedia,
    WatchVenue.festival => watchVenueFestival,
    WatchVenue.other => watchVenueOther,
  };

  String watchStatus(WatchStatus status) => switch (status) {
    WatchStatus.watched => watchStatusWatched,
    WatchStatus.wantToWatch => watchStatusWantToWatch,
  };

  String systemShelf(SystemShelfType type) => switch (type) {
    SystemShelfType.watched => systemShelfWatched,
    SystemShelfType.watchlist => systemShelfWatchlist,
  };

  /// Shelf name to show: system shelves are stored in Portuguese, so they use the label.
  String shelfName(SystemShelfType? type, String name) =>
      type == null ? name : systemShelf(type);

  String rating(Rating rating) => switch (rating) {
    Rating.favorite => ratingLabelFavorite,
    Rating.loved => ratingLabelLoved,
    Rating.liked => ratingLabelLiked,
    Rating.neutral => ratingLabelNeutral,
    Rating.notForMe => ratingLabelNotForMe,
    Rating.abandoned => ratingLabelAbandoned,
    Rating.onHold => ratingLabelOnHold,
  };

  String shelfSort(ShelfSort sort) => switch (sort) {
    ShelfSort.manual => shelfSortManual,
    ShelfSort.title => shelfSortTitle,
    ShelfSort.director => shelfSortDirector,
    ShelfSort.releaseYear => shelfSortReleaseYear,
    ShelfSort.addedNewest => shelfSortAddedNewest,
    ShelfSort.addedOldest => shelfSortAddedOldest,
    ShelfSort.updatedNewest => shelfSortUpdatedNewest,
    ShelfSort.watchedFirst => shelfSortWatchedFirst,
    ShelfSort.watchedLast => shelfSortWatchedLast,
    ShelfSort.progressHighest => shelfSortProgressHighest,
    ShelfSort.ratingHighest => shelfSortRatingHighest,
  };

  String emotion(Emotion emotion) => switch (emotion) {
    Emotion.curiosity => emotionCuriosity,
    Emotion.inspiration => emotionInspiration,
    Emotion.reflection => emotionReflection,
    Emotion.relaxation => emotionRelaxation,
    Emotion.moved => emotionMoved,
    Emotion.nostalgia => emotionNostalgia,
    Emotion.gratitude => emotionGratitude,
    Emotion.affection => emotionAffection,
    Emotion.surprise => emotionSurprise,
    Emotion.passion => emotionPassion,
    Emotion.fun => emotionFun,
    Emotion.joy => emotionJoy,
    Emotion.humor => emotionHumor,
    Emotion.freakOut => emotionFreakOut,
    Emotion.anxiety => emotionAnxiety,
    Emotion.distress => emotionDistress,
    Emotion.tension => emotionTension,
    Emotion.distraction => emotionDistraction,
    Emotion.confusion => emotionConfusion,
    Emotion.suspicion => emotionSuspicion,
    Emotion.irritation => emotionIrritation,
    Emotion.anger => emotionAnger,
    Emotion.indignation => emotionIndignation,
    Emotion.fear => emotionFear,
    Emotion.vulnerability => emotionVulnerability,
    Emotion.embarrassment => emotionEmbarrassment,
    Emotion.frustration => emotionFrustration,
    Emotion.sadness => emotionSadness,
    Emotion.melancholy => emotionMelancholy,
    Emotion.tiredness => emotionTiredness,
    Emotion.boredom => emotionBoredom,
    Emotion.connection => emotionConnection,
    Emotion.focus => emotionFocus,
    Emotion.intensity => emotionIntensity,
    Emotion.enthusiasm => emotionEnthusiasm,
    Emotion.excitement => emotionExcitement,
    Emotion.euphoria => emotionEuphoria,
    Emotion.shock => emotionShock,
    Emotion.horror => emotionHorror,
    Emotion.disgust => emotionDisgust,
    Emotion.devastation => emotionDevastation,
    Emotion.grudge => emotionGrudge,
    Emotion.indifference => emotionIndifference,
    Emotion.apathy => emotionApathy,
  };
}
