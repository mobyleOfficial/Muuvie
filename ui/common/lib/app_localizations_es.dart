// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Muuvie';

  @override
  String get home => 'Inicio';

  @override
  String get search => 'Buscar';

  @override
  String get profile => 'Perfil';

  @override
  String get moviesTab => 'Películas';

  @override
  String get reviewsTab => 'Reseñas';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String movieRelease(String date) {
    return 'Estreno: $date';
  }

  @override
  String movieRating(String rating) {
    return 'Puntuación: $rating';
  }

  @override
  String movieRuntime(int minutes) {
    return 'Duración: $minutes min';
  }

  @override
  String movieGenres(String genres) {
    return 'Géneros: $genres';
  }

  @override
  String get socialTab => 'Social';

  @override
  String get newUserActivityTab => 'Nueva Actividad';

  @override
  String get searchHint => 'Películas, personas, estantes y más';

  @override
  String get searchBrowse => 'Explorar';

  @override
  String get searchBrowseReleaseDate => 'Fecha de estreno';

  @override
  String get searchBrowseGenre => 'Género';

  @override
  String get searchBrowseCountryAndLanguage => 'País e idioma';

  @override
  String get searchBrowseGenreCountryLanguage => 'Género, País e Idioma';

  @override
  String get searchBrowseCountry => 'País';

  @override
  String get searchBrowseLanguage => 'Idioma';

  @override
  String get searchBrowseService => 'Servicio';

  @override
  String get searchBrowseMostPopular => 'Más populares';

  @override
  String get searchBrowseMostAnticipated => 'Más esperadas';

  @override
  String get searchBrowseFeaturedLists => 'Listas destacadas';

  @override
  String get profileTabProfile => 'Perfil';

  @override
  String get profileTabDiary => 'Diario';

  @override
  String get profileTabReviews => 'Reseñas';

  @override
  String get profileTabLists => 'Listas';

  @override
  String get profileTabWatchlist => 'Ver después';

  @override
  String get profileTabShelves => 'Estantes';

  @override
  String get profileTabLocadoras => 'Locadoras';

  @override
  String locadoraShelvesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estantes',
      one: '1 estante',
    );
    return '$_temp0';
  }

  @override
  String locadoraMoviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count películas',
      one: '1 película',
    );
    return '$_temp0';
  }

  @override
  String get profileTabMarathons => 'Maratones';

  @override
  String get profileTabHistory => 'Historial';

  @override
  String get profileTabParticipations => 'Participaciones';

  @override
  String get profileTabCharts => 'Gráficos';

  @override
  String shelfWatchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vistas',
      one: '1 vista',
    );
    return '$_temp0';
  }

  @override
  String shelfMoviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count películas',
      one: '1 película',
    );
    return '$_temp0';
  }

  @override
  String get profileFollowers => 'Seguidores';

  @override
  String get profileFollowing => 'Siguiendo';

  @override
  String get profileMoviesWatched => 'Vistas';

  @override
  String get profileMoviesWatchedTitle => 'Películas vistas';

  @override
  String get profileFollowingTitle => 'Siguiendo';

  @override
  String get profileFollowersTitle => 'Seguidores';

  @override
  String get profileEmptyMoviesWatched => 'Aún no has visto películas';

  @override
  String get profileEmptyFollowing => 'Aún no sigues a nadie';

  @override
  String get profileEmptyFollowers => 'Aún no tienes seguidores';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get editProfileUsernameLabel => 'Nombre de usuario';

  @override
  String get editProfileUsernamePlaceholder => 'Ingresa tu nombre de usuario';

  @override
  String get editProfileBioLabel => 'Bio';

  @override
  String get editProfileBioPlaceholder => 'Cuéntanos sobre ti';

  @override
  String get editProfileChangePhoto => 'Cambiar foto';

  @override
  String get profileRecentMovies => 'Películas recientes';

  @override
  String get profileFavoriteMovies => 'Películas favoritas';

  @override
  String get profileRecentActivity => 'Actividad reciente';

  @override
  String get profileMoviesSection => 'Películas';

  @override
  String get profileReviewsSection => 'Reseñas';

  @override
  String get profileWatchlistSection => 'Watchlist';

  @override
  String get profileSeeAll => 'Ver todo';

  @override
  String get socialFriendsTab => 'Amigos';

  @override
  String get socialActivitiesTab => 'Actividades';

  @override
  String get socialNoFriends => 'Aún no tienes amigos';

  @override
  String get moviesListListsTab => 'Listas';

  @override
  String get moviesListArticlesTab => 'Artículos';

  @override
  String get moviesListPopularThisWeek => 'Populares esta semana';

  @override
  String movieListDetailMoviesTab(int count) {
    return '$count Películas';
  }

  @override
  String movieListDetailCommentsTab(int count) {
    return '$count Comentarios';
  }

  @override
  String get movieListDetailCommentsPlaceholder => 'Comentarios próximamente';

  @override
  String get newUserActivityDraftsSection => 'Borradores';

  @override
  String get newUserActivityRecentSection => 'Recientes';

  @override
  String get profileFollow => 'Seguir';

  @override
  String get reviewDetailsBodyTitle => 'Mi reseña';

  @override
  String get noResults => 'No se encontraron resultados';

  @override
  String get movieReviewTitle => 'Reseña';

  @override
  String get movieReviewNameHint => 'Título de la reseña';

  @override
  String get movieReviewAddReview => 'Agregar una reseña...';

  @override
  String get movieReviewRewatch => 'Revisión';

  @override
  String get movieReviewFirstTime => 'Primera vez';

  @override
  String get movieReviewTags => 'Etiquetas';

  @override
  String get movieReviewTagMasterpiece => 'Obra maestra';

  @override
  String get movieReviewTagOverrated => 'Sobrevalorada';

  @override
  String get movieReviewTagUnderrated => 'Infravalorada';

  @override
  String get movieReviewTagMustWatch => 'Imprescindible';

  @override
  String get movieReviewTagDisappointing => 'Decepcionante';

  @override
  String get movieReviewTagFeelGood => 'Para sentirse bien';

  @override
  String get movieReviewTagMindBending => 'Desconcertante';

  @override
  String get movieReviewTagEmotional => 'Emotiva';

  @override
  String get movieReviewSend => 'Enviar reseña';

  @override
  String get deleteDraftTitle => 'Eliminar borrador?';

  @override
  String get deleteDraftContent =>
      'Este borrador se eliminará permanentemente.';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reviewEditorTitle => 'Escribir una reseña';

  @override
  String get reviewEditorPlaceholder => 'Empieza a escribir tu reseña...';

  @override
  String get reviewEditorClear => 'Borrar todo';

  @override
  String get reviewEditorClearConfirmTitle => '¿Borrar reseña?';

  @override
  String get reviewEditorClearConfirmContent => 'Se eliminará todo el texto.';

  @override
  String get reviewDetailsAddReview => 'Agregar una reseña...';

  @override
  String get movieListDetailShowGridView => 'Mostrar vista de cuadrícula';

  @override
  String get movieListDetailShowListView => 'Mostrar vista de lista';

  @override
  String get emptyStateErrorTitle => 'Algo salió mal';

  @override
  String get emptyStateErrorMessage =>
      'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';

  @override
  String get emptyStateRetry => 'Reintentar';

  @override
  String get emptyStateNoItemsTitle => 'Nada aquí todavía';

  @override
  String get emptyStateNoItemsMessage => 'No hay elementos para mostrar.';

  @override
  String get clearSearch => 'Limpiar';

  @override
  String get submitReviewTitle => 'Enviar Reseña';

  @override
  String get submitReviewContent =>
      '¿Estás seguro de que quieres enviar esta reseña? Se publicará y el borrador se eliminará.';

  @override
  String get submit => 'Enviar';

  @override
  String get submittingReview => 'Enviando reseña...';

  @override
  String get submissionFailed => 'Error al enviar';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get ratingRequired => 'Por favor selecciona una calificación';

  @override
  String get reviewBodyRequired => 'Por favor escribe una reseña';

  @override
  String get tagsRequired => 'Por favor selecciona al menos una etiqueta';

  @override
  String get movieDetailWhereToWatch => 'Dónde Ver';

  @override
  String get movieDetailSynopsis => 'Sinopsis';

  @override
  String get movieDetailUnmatched =>
      'No encontramos esta película en nuestro catálogo. Los datos vienen de Filmow y pueden estar incompletos.';

  @override
  String get movieDetailCast => 'Reparto';

  @override
  String get movieDetailReviews => 'Reseñas';

  @override
  String get movieDetailSimilar => 'Películas Similares';

  @override
  String movieDetailLikes(int count) {
    return '$count me gusta';
  }

  @override
  String movieDetailReviewCount(int count) {
    return '$count reseñas';
  }

  @override
  String movieDetailListCount(int count) {
    return '$count listas';
  }

  @override
  String get movieDetailDirectedBy => 'Dirigida por';

  @override
  String movieDetailMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get movieDetailSeeAll => 'Ver todo';

  @override
  String get movieDetailAboutTab => 'Acerca de';

  @override
  String movieDetailMovieReviews(String title) {
    return 'Reseñas de $title';
  }

  @override
  String get comments => 'Comentarios';

  @override
  String get noComments => 'Sin comentarios aún';

  @override
  String get loadMore => 'Cargar más comentarios';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get reviewDetailsShare => 'Compartir reseña';

  @override
  String get reviewDetailsLike => 'Me gusta';

  @override
  String get reviewDetailsUnlike => 'Quitar me gusta';

  @override
  String get reviewDetailsLikeError =>
      'No se pudo actualizar el me gusta. Inténtalo de nuevo.';

  @override
  String reviewDetailsLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
      zero: 'Aún no hay me gusta',
    );
    return '$_temp0';
  }

  @override
  String get reviewDetailsCommentsTitle => 'Comentarios';

  @override
  String reviewDetailsViewAllComments(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get reviewDetailsNoComments => 'Aún no hay comentarios';

  @override
  String get reviewDetailsOtherReviewsForMovie =>
      'Otras reseñas de esta película';

  @override
  String reviewDetailsMoreFromAuthor(String author) {
    return 'Más reseñas de $author';
  }

  @override
  String reviewDetailsBy(String author) {
    return 'por $author';
  }

  @override
  String get reviewDetailsAnonymousAuthor => 'Anónimo';

  @override
  String get reviewDetailsNoBody => 'Sin texto de reseña';

  @override
  String get reviewDetailsLoadCommentsError =>
      'No se pudieron cargar los comentarios';

  @override
  String get reviewDetailsLoadRelatedError =>
      'No se pudieron cargar las reseñas relacionadas';

  @override
  String get loginSubtitle =>
      'Inicia sesión para descubrir y reseñar películas';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithFacebook => 'Continuar con Facebook';

  @override
  String get articleDetailShare => 'Compartir artículo';

  @override
  String get loginEmail => 'Correo electrónico';

  @override
  String get loginEmailHint => 'Ingresa tu correo electrónico';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginPasswordHint => 'Ingresa tu contraseña';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get signUpNickname => 'Apodo';

  @override
  String get signUpNicknameHint => 'Elige un apodo';

  @override
  String get createAccountButton => 'Crear Cuenta';

  @override
  String get emailValidationError =>
      'Por favor ingresa un correo electrónico válido';

  @override
  String get passwordValidationError =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordTooLongError =>
      'La contraseña debe tener como máximo 72 caracteres';

  @override
  String get nicknameValidationError => 'Por favor ingresa un apodo';

  @override
  String get nicknameTooLongError =>
      'El apodo debe tener como máximo 30 caracteres';

  @override
  String get nicknameTakenError => 'Este apodo ya está en uso';

  @override
  String get signUpConflictError => 'Este email o apodo ya está en uso.';

  @override
  String get signUpBadRequestError =>
      'Verifica tus datos e inténtalo de nuevo.';

  @override
  String get signUpNetworkError =>
      'Sin conexión a internet. Inténtalo de nuevo.';

  @override
  String get signUpServerError =>
      'Error del servidor. Inténtalo de nuevo más tarde.';

  @override
  String get loginError => 'Usuario o contraseña incorrectos.';

  @override
  String get loginGenericError =>
      'Algo salió mal, inténtalo de nuevo más tarde.';

  @override
  String get loginWelcomeTitle => '¡Qué bueno verte!';

  @override
  String get loginNoAccount => '¿Eres nuevo en Muuvie?';

  @override
  String get loginCreateAccountLink => 'Crea una cuenta';

  @override
  String get signUpHeadline => 'Consigue tu entrada';

  @override
  String get signUpSubtitle => 'Crea tu cuenta en menos de un minuto.';

  @override
  String get signUpHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get signUpNicknameChecking => 'Comprobando disponibilidad…';

  @override
  String get signUpNicknameAvailable => 'Apodo disponible';

  @override
  String get signUpPasswordHelper => 'Al menos 8 caracteres';

  @override
  String get passwordShow => 'Mostrar contraseña';

  @override
  String get passwordHide => 'Ocultar contraseña';

  @override
  String get movieDetailWriteReview => 'Escribir una Reseña';

  @override
  String get movieDetailCreateList => 'Crear una Lista';

  @override
  String get movieDetailActions => 'Acciones';

  @override
  String get movieDetailWantToWatch => 'Quiero Ver';

  @override
  String get movieDetailWatched => 'Vista';

  @override
  String get movieDetailYourRating => 'Tu valoración';

  @override
  String get movieListDeleteTitle => 'Eliminar Lista';

  @override
  String get movieListDeleteContent =>
      '¿Estás seguro de que quieres eliminar esta lista? Esta acción no se puede deshacer.';

  @override
  String get movieListDoneEditing => 'Terminar edición';

  @override
  String get movieListEditList => 'Editar lista';

  @override
  String get movieListDeleteTooltip => 'Eliminar lista';

  @override
  String get createListTitle => 'Nueva Lista';

  @override
  String get createListSave => 'Guardar';

  @override
  String get createListAddMovies => 'Agregar Películas';

  @override
  String get createListNoMovies => 'Aún no se han agregado películas';

  @override
  String get createListNameHint => 'Nombre';

  @override
  String get createListDescriptionHint => 'Descripción';

  @override
  String get createListMoviesSection => 'PELÍCULAS';

  @override
  String createListMoviesCount(int count) {
    return 'PELÍCULAS ($count)';
  }

  @override
  String get editProfileFilmowLogin => 'Iniciar sesión en Filmow';

  @override
  String get editProfileImportFilmow => 'Importar datos de Filmow';

  @override
  String get editProfileImportLetterboxd => 'Importar datos de Letterboxd';

  @override
  String get followLabel => 'Seguir';

  @override
  String get followingLabel => 'Siguiendo';

  @override
  String get unfollowLabel => 'Dejar de seguir';

  @override
  String routeReviewsTitle(String title) {
    return 'Reseñas de $title';
  }

  @override
  String get routeReviews => 'Reseñas';

  @override
  String get routeReleaseDate => 'Fecha de Estreno';

  @override
  String get routeBrowse => 'Explorar';

  @override
  String get routeMostPopular => 'Más Populares';

  @override
  String get routeMostAnticipated => 'Más Esperadas';

  @override
  String get routeFeaturedLists => 'Listas Destacadas';

  @override
  String get addShelvesSearchHint => 'Buscar estantes...';

  @override
  String get addShelvesEmptyState => 'Busca estantes para agregar';

  @override
  String get createLocadoraTitle => 'Nueva Locadora';

  @override
  String get createLocadoraNamePrompt => '¿Cómo se llama tu locadora?';

  @override
  String get createLocadoraNameHint => 'Nombre';

  @override
  String get createLocadoraDescriptionPrompt =>
      'Describe tu locadora (opcional)';

  @override
  String get createLocadoraDescriptionHint => 'Descripción';

  @override
  String get createLocadoraVisibilityPrompt =>
      '¿Quién puede ver esta locadora?';

  @override
  String get createLocadoraSave => 'Crear Locadora';

  @override
  String get createShelfTitle => 'Nueva Estantería';

  @override
  String get createShelfNamePrompt => '¿Cómo se llama tu estantería?';

  @override
  String get createShelfNameHint => 'Nombre';

  @override
  String get createShelfDescriptionPrompt =>
      'Describe tu estantería (opcional)';

  @override
  String get createShelfDescriptionHint => 'Descripción';

  @override
  String get createShelfColorPrompt => 'Elige un color para tu estantería';

  @override
  String get createShelfVisibilityPrompt => '¿Quién puede ver esta estantería?';

  @override
  String get createShelfVisibilityPublic => 'Público';

  @override
  String get createShelfVisibilityPrivate => 'Privado';

  @override
  String get createShelfVisibilityMutuals => 'Mutuos';

  @override
  String get createShelfSave => 'Crear Estantería';

  @override
  String get visibilityPublic => 'Público';

  @override
  String get visibilityMutual => 'Mutuos';

  @override
  String get visibilitySecret => 'Secreto';

  @override
  String get watchModeWatched => 'Visto';

  @override
  String get watchModeMinutes => 'Minutos';

  @override
  String get watchModePercent => 'Porcentaje';

  @override
  String get watchVenueCinema => 'Cine';

  @override
  String get watchVenueStreaming => 'Streaming';

  @override
  String get watchVenueTv => 'TV';

  @override
  String get watchVenuePhysicalMedia => 'Formato físico';

  @override
  String get watchVenueFestival => 'Festival';

  @override
  String get watchVenueOther => 'Otro';

  @override
  String get watchStatusWatched => 'Visto';

  @override
  String get watchStatusWantToWatch => 'Quiero ver';

  @override
  String get systemShelfWatched => 'Ya la vi';

  @override
  String get systemShelfWatchlist => 'Quiero ver';

  @override
  String get ratingLabelFavorite => 'Favorito';

  @override
  String get ratingLabelLoved => 'Me encantó';

  @override
  String get ratingLabelLiked => 'Me gustó';

  @override
  String get ratingLabelNeutral => 'Neutral';

  @override
  String get ratingLabelNotForMe => 'No fue para mí';

  @override
  String get ratingLabelAbandoned => 'Abandonado';

  @override
  String get ratingLabelOnHold => 'En pausa';

  @override
  String get shelfSortManual => 'Manual';

  @override
  String get shelfSortTitle => 'Título';

  @override
  String get shelfSortDirector => 'Director';

  @override
  String get shelfSortReleaseYear => 'Año de estreno';

  @override
  String get shelfSortAddedNewest => 'Agregados recientemente';

  @override
  String get shelfSortAddedOldest => 'Agregados primero';

  @override
  String get shelfSortUpdatedNewest => 'Actualizados recientemente';

  @override
  String get shelfSortWatchedFirst => 'Vistos primero';

  @override
  String get shelfSortWatchedLast => 'Vistos al final';

  @override
  String get shelfSortProgressHighest => 'Mayor progreso';

  @override
  String get shelfSortRatingHighest => 'Por valoración';

  @override
  String get emotionCuriosity => 'Curiosidad';

  @override
  String get emotionInspiration => 'Inspiración';

  @override
  String get emotionReflection => 'Reflexión';

  @override
  String get emotionRelaxation => 'Relajación';

  @override
  String get emotionMoved => 'Conmoción';

  @override
  String get emotionNostalgia => 'Nostalgia';

  @override
  String get emotionGratitude => 'Gratitud';

  @override
  String get emotionAffection => 'Cariño';

  @override
  String get emotionSurprise => 'Sorpresa';

  @override
  String get emotionPassion => 'Pasión';

  @override
  String get emotionFun => 'Diversión';

  @override
  String get emotionJoy => 'Alegría';

  @override
  String get emotionHumor => 'Humor';

  @override
  String get emotionFreakOut => 'Locura';

  @override
  String get emotionAnxiety => 'Ansiedad';

  @override
  String get emotionDistress => 'Angustia';

  @override
  String get emotionTension => 'Tensión';

  @override
  String get emotionDistraction => 'Distracción';

  @override
  String get emotionConfusion => 'Confusión';

  @override
  String get emotionSuspicion => 'Desconfianza';

  @override
  String get emotionIrritation => 'Irritación';

  @override
  String get emotionAnger => 'Rabia';

  @override
  String get emotionIndignation => 'Indignación';

  @override
  String get emotionFear => 'Miedo';

  @override
  String get emotionVulnerability => 'Vulnerabilidad';

  @override
  String get emotionEmbarrassment => 'Vergüenza';

  @override
  String get emotionFrustration => 'Frustración';

  @override
  String get emotionSadness => 'Tristeza';

  @override
  String get emotionMelancholy => 'Melancolía';

  @override
  String get emotionTiredness => 'Cansancio';

  @override
  String get emotionBoredom => 'Aburrimiento';

  @override
  String get emotionConnection => 'Conexión';

  @override
  String get emotionFocus => 'Concentración';

  @override
  String get emotionIntensity => 'Intensidad';

  @override
  String get emotionEnthusiasm => 'Entusiasmo';

  @override
  String get emotionExcitement => 'Emoción';

  @override
  String get emotionEuphoria => 'Euforia';

  @override
  String get emotionShock => 'Impacto';

  @override
  String get emotionHorror => 'Horror';

  @override
  String get emotionDisgust => 'Asco';

  @override
  String get emotionDevastation => 'Devastación';

  @override
  String get emotionGrudge => 'Rencor';

  @override
  String get emotionIndifference => 'Indiferencia';

  @override
  String get emotionApathy => 'Apatía';

  @override
  String get editProfileLogout => 'Cerrar sesión';

  @override
  String get editProfileLogoutConfirmTitle => '¿Cerrar sesión en Muuvie?';

  @override
  String get editProfileLogoutConfirmMessage =>
      'Puedes volver a iniciar sesión cuando quieras.';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get navAtts => 'Social';

  @override
  String get navProgramacao => 'Programación';

  @override
  String get navCatalogo => 'Catálogo';

  @override
  String get navNoticias => 'Noticias';

  @override
  String get attsWhispers => 'Susurros';

  @override
  String get programacaoMaratonasTab => 'Maratones';

  @override
  String get programacaoCineClubesTab => 'Cineclubes';

  @override
  String get programacaoParticipatingFilter => 'Participando';

  @override
  String get programacaoMaratonasComingSoon =>
      'Aquí aparecerán maratones de películas con desafíos y plazos.';

  @override
  String get programacaoCineClubesComingSoon =>
      'Cineclubes: una película, un período y un día de debate.';

  @override
  String colorPickerOption(int index, int total) {
    return 'Color $index de $total';
  }

  @override
  String emotionPickerCount(int count, int max) {
    return '$count de $max emociones';
  }

  @override
  String movieProgressMinutes(int watched, int total) {
    return '$watched de $total min';
  }

  @override
  String get editShelfTitle => 'Editar estante';

  @override
  String get shelfSave => 'Guardar';

  @override
  String get systemShelfLockedHint =>
      'Estante predeterminada: no se puede renombrar ni eliminar';

  @override
  String get shelfEdit => 'Editar';

  @override
  String get shelfDelete => 'Eliminar estante';

  @override
  String shelfDeleteConfirmTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get shelfDeleteConfirmMessage =>
      'Las películas siguen en tu historial.';

  @override
  String get shelfPin => 'Fijar arriba';

  @override
  String get shelfUnpin => 'Desfijar';

  @override
  String get shelfReorder => 'Reordenar estantes';

  @override
  String get shelfReorderDone => 'Listo';

  @override
  String get shelfPinned => 'Fijada';

  @override
  String shelfWatchedOfTotal(int watched, int total) {
    return '$watched/$total vistas';
  }

  @override
  String get shelfNew => 'Nueva estante';

  @override
  String get shelfAddMovies => 'Añadir películas';

  @override
  String get shelfFilterWatched => 'Vistas';

  @override
  String get shelfFilterNotWatched => 'No vistas';

  @override
  String get shelfFilterDecade => 'Década';

  @override
  String shelfFilterDecadeValue(int decade) {
    return 'Años $decade';
  }

  @override
  String get shelfFilterGenre => 'Género';

  @override
  String get shelfFilterAny => 'Cualquiera';

  @override
  String get shelfFilterClear => 'Quitar filtros';

  @override
  String get shelfEmptyFiltered => 'Ninguna película con estos filtros';

  @override
  String get shelfSortBy => 'Ordenar por';

  @override
  String get shelfSortApplyOnce => 'Aplicar solo una vez';

  @override
  String get shelfSortApply => 'Aplicar';

  @override
  String get shelfManualOrder => 'Reordenar películas';

  @override
  String get shelfMovieRemove => 'Quitar de la estante';

  @override
  String get shelfMovieMoveTo => 'Mover a…';

  @override
  String get shelfMovieCopyTo => 'Copiar a…';

  @override
  String get shelfMoveAll => 'Mover todas a…';

  @override
  String get shelfCopyAll => 'Copiar todas a…';

  @override
  String get shelfPickTarget => 'Elige la estante';

  @override
  String get shelfUnmarkWatchedTitle => '¿Desmarcar como vista?';

  @override
  String get shelfUnmarkWatchedMessage =>
      'Tus registros de esta película se conservan.';

  @override
  String get shelfUnmarkWatchedConfirm => 'Desmarcar';

  @override
  String get shelfActionError => 'No se pudo completar. Inténtalo de nuevo.';

  @override
  String get addToShelvesAction => 'Añadir a la estante…';

  @override
  String get addToShelvesTitle => 'Añadir a estantes';

  @override
  String get addToShelvesSave => 'Guardar';

  @override
  String addToShelvesSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estantes',
      one: '1 estante',
    );
    return 'Guardada en $_temp0';
  }

  @override
  String get watchLogAction => 'Registrar sesión';

  @override
  String get watchLogTitle => 'Registrar sesión';

  @override
  String get watchLogEditTitle => 'Editar registro';

  @override
  String get watchLogDate => 'Fecha';

  @override
  String get watchLogProgress => 'Progreso';

  @override
  String watchLogPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String watchLogMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get watchLogVenue => 'Dónde la viste';

  @override
  String get watchLogProvider => 'Servicio o cine (opcional)';

  @override
  String get watchLogEmotions => '¿Cómo fue?';

  @override
  String get watchLogAddGif => 'Añadir GIF';

  @override
  String get watchLogRemoveGif => 'Quitar GIF';

  @override
  String get watchLogComment => 'Comentario (opcional)';

  @override
  String get watchLogSpoiler => 'Contiene spoilers';

  @override
  String get watchLogVisibility => 'Quién puede verlo';

  @override
  String get watchLogSave => 'Guardar';

  @override
  String get watchLogSaved => 'Sesión registrada';

  @override
  String get watchLogError =>
      'No se pudo guardar el registro. Inténtalo de nuevo.';

  @override
  String get gifSearchHint => 'Buscar GIFs';

  @override
  String get gifRecent => 'Recientes';

  @override
  String get gifSearchUnavailable =>
      'La búsqueda de GIFs no está disponible ahora.';

  @override
  String get gifPickerTitle => 'Elige un GIF';

  @override
  String get gifLabel => 'GIF';

  @override
  String get ratingTitle => 'Calificar';

  @override
  String get ratingPrompt => '¿Qué opción refleja mejor tu valoración final?';

  @override
  String get ratingReview => 'Comentario (opcional)';

  @override
  String get ratingCreateLog => 'Crear una sesión al 100%';

  @override
  String get ratingSave => 'Guardar calificación';

  @override
  String get ratingRemove => 'Quitar calificación';

  @override
  String get ratingError =>
      'No se pudo guardar la calificación. Inténtalo de nuevo.';

  @override
  String get rewatchAction => 'Ver de nuevo';

  @override
  String get rewatchStarted => 'Revisionado iniciado';

  @override
  String get watchingNowTitle => 'Viendo ahora';

  @override
  String watchProgressPercent(int percent) {
    return '$percent% visto';
  }

  @override
  String get watchStateError => 'No se pudo actualizar. Inténtalo de nuevo.';

  @override
  String get historyTitle => 'Historial';

  @override
  String historyMinutes(int minutes) {
    return '$minutes min vistos';
  }

  @override
  String historySessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '1 sesión',
    );
    return '$_temp0';
  }

  @override
  String historyRewatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisionados',
      one: '1 revisionado',
      zero: 'Sin revisionados',
    );
    return '$_temp0';
  }

  @override
  String get historyFirstWatch => 'Primera vez';

  @override
  String historyRewatch(int number) {
    return 'Revisionado $number';
  }

  @override
  String get historyEmpty => 'Aún no hay registros';

  @override
  String get historyEdit => 'Editar';

  @override
  String get historyDelete => 'Eliminar';

  @override
  String get historyDeleteTitle => '¿Eliminar este registro?';

  @override
  String get historyDeleteMessage =>
      'El progreso se recalcula. La película sigue en Ya la vi.';

  @override
  String get spoilerReveal => 'Spoiler. Toca para ver';

  @override
  String get threadCommentsTitle => 'Comentarios';

  @override
  String get threadCommentHint => 'Escribe un comentario';

  @override
  String get threadCommentSend => 'Enviar';

  @override
  String get threadCommentDelete => 'Eliminar comentario';

  @override
  String get threadCommentsEmpty => 'Aún no hay comentarios';

  @override
  String get threadCommentError =>
      'No se pudo enviar el comentario. Inténtalo de nuevo.';

  @override
  String get editProfileImportSection => 'Importar datos';

  @override
  String get importTitle => 'Importar';

  @override
  String get importIntro =>
      'Trae tu historial de Filmow: las películas vistas van a Ya la vi, tus pendientes a Quiero ver y tus listas se convierten en estantes. No se guarda nada antes de que confirmes.';

  @override
  String get importStartFilmow => 'Entrar en Filmow e importar';

  @override
  String get importFilmowWaitTitle => 'Espera después de iniciar sesión';

  @override
  String get importFilmowWaitMessage =>
      'Después de iniciar sesión en Filmow, DEBES esperar a que la pantalla se cierre sola. No la cierres, o la importación no empezará.';

  @override
  String get importFilmowWaitConfirm => 'Entendido';

  @override
  String get importHistoryTitle => 'Importaciones anteriores';

  @override
  String get importInProgress => 'Ya tienes una importación en curso.';

  @override
  String get importStartError =>
      'No se pudo iniciar la importación. Inténtalo de nuevo.';

  @override
  String get importActionError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String importStatusLabel(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Comenzando',
      'reading': 'Leyendo',
      'preview': 'Esperándote',
      'importing': 'Importando',
      'done': 'Terminada',
      'failed': 'Falló',
      'cancelled': 'Cancelada',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get importReadingTitle => 'Leyendo tu perfil de Filmow';

  @override
  String get importReadingMessage =>
      'Esto puede tardar unos minutos. Puedes salir de esta pantalla: la vista previa te estará esperando aquí.';

  @override
  String get importPreviewTitle => 'Listo para importar';

  @override
  String importPreviewWatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count películas → Ya la vi',
      one: '1 película → Ya la vi',
    );
    return '$_temp0';
  }

  @override
  String importPreviewWatchlist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count películas → Quiero ver',
      one: '1 película → Quiero ver',
    );
    return '$_temp0';
  }

  @override
  String importPreviewFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritas quedan como Favorito',
      one: '1 favorita queda como Favorito',
    );
    return '$_temp0';
  }

  @override
  String importPreviewLogs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones con fecha',
      one: '1 sesión con fecha',
    );
    return '$_temp0';
  }

  @override
  String get importPreviewLists => 'Listas → estantes';

  @override
  String get importPreviewNoLists => 'No se encontraron listas en tu perfil.';

  @override
  String get importPreviewVisibility =>
      'Quién ve los estantes y sesiones nuevos';

  @override
  String get importConfirm => 'Importar';

  @override
  String get importCancel => 'Cancelar importación';

  @override
  String get importImportingTitle => 'Importando tu historial';

  @override
  String importImportingProgress(int processed, int total) {
    return '$processed de $total';
  }

  @override
  String get importImportingMessage =>
      'Puedes salir de esta pantalla: te avisamos cuando termine.';

  @override
  String get importDoneTitle => 'Importación terminada';

  @override
  String importDoneShelves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas se convirtieron en estantes',
      one: '1 lista se convirtió en estante',
    );
    return '$_temp0';
  }

  @override
  String importDoneKept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count películas que ya tenías quedaron como estaban',
      one: '1 película que ya tenías quedó como estaba',
    );
    return '$_temp0';
  }

  @override
  String importReviewUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Revisar $count películas',
      one: 'Revisar 1 película',
    );
    return '$_temp0';
  }

  @override
  String get importAgain => 'Importar de nuevo';

  @override
  String get importFailedTitle => 'La importación falló';

  @override
  String get importCancelledTitle => 'Importación cancelada';

  @override
  String get importCancelledMessage => 'No se guardó nada.';

  @override
  String get importUnmatchedTitle => 'Confirmar películas';

  @override
  String get importUnmatchedHint =>
      'No estuvimos seguros sobre estas películas. Ya están en tus estantes: elige la correcta u omítela.';

  @override
  String get importUnmatchedSkip => 'Omitir';

  @override
  String get importUnmatchedNoCandidates => 'No se encontraron sugerencias.';

  @override
  String get importUnmatchedMatched => 'Confirmada';

  @override
  String get importUnmatchedSkipped => 'Omitida';

  @override
  String get importUnmatchedEmpty => 'Todas las películas fueron encontradas.';

  @override
  String get importFinishedSnack => 'Tu importación de Filmow terminó';

  @override
  String get importSeeReport => 'Ver informe';

  @override
  String get watchedEmptyImport => '¿Ya usas Filmow? Trae tu historial';

  @override
  String get locadoraNew => 'Nueva locadora';

  @override
  String get editLocadoraTitle => 'Editar locadora';

  @override
  String get locadoraEdit => 'Editar';

  @override
  String get locadoraDelete => 'Eliminar locadora';

  @override
  String locadoraDeleteConfirmTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get locadoraDeleteConfirmMessage =>
      'Las estantes siguen en tu perfil.';

  @override
  String get locadoraReorder => 'Reordenar locadoras';

  @override
  String get locadoraEmptyTitle => 'Aún no hay locadoras';

  @override
  String get locadoraEmptyMessage =>
      'Agrupa tus estantes como los pasillos de un videoclub.';

  @override
  String get locadoraEmptyOtherMessage => 'Todavía no hay nada para mostrar.';

  @override
  String get locadoraHideInProfile =>
      'Ocultar sus estantes de la pestaña Estantes';

  @override
  String get locadoraHideInFilters => 'Ocultar sus estantes de los filtros';

  @override
  String locadoraByOwner(String username) {
    return 'de @$username';
  }

  @override
  String get locadoraChooseShelves => 'Elegir estantes';

  @override
  String get locadoraNoShelves => 'Esta locadora aún no tiene estantes.';

  @override
  String get locadoraPickShelvesTitle => 'Estantes de la locadora';

  @override
  String get locadoraPickShelvesEmpty => 'Crea una estante primero.';

  @override
  String get locadoraShelfEmpty => 'Estante vacía';

  @override
  String locadoraProgress(int watched, int total) {
    return '$watched de $total películas vistas';
  }

  @override
  String get locadoraOpenShelf => 'Abrir estante';

  @override
  String get profileTabHighlights => 'Destacados';

  @override
  String get profileTabLogs => 'Registros';

  @override
  String get profileStatWatched => 'Vistas';

  @override
  String get profileStatCineclubes => 'CineClubes';

  @override
  String get profileFollowsYou => 'Te sigue';

  @override
  String get profilePickHandleTip =>
      'Elige tu @ para que tus amigos te encuentren';

  @override
  String get profileNotFound => 'Perfil no encontrado';

  @override
  String get profileShare => 'Compartir perfil';

  @override
  String profileShareText(String name, String link) {
    return '$name en Muuvie: $link';
  }

  @override
  String profileWatchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count películas vistas',
      one: '1 película vista',
      zero: 'ninguna película vista',
    );
    return '$_temp0';
  }

  @override
  String get highlightsEdit => 'Editar destacados';

  @override
  String get highlightsEmptyOwnTitle => 'Muestra tu gusto';

  @override
  String get highlightsEmptyOwnMessage =>
      'Elige un top 4, un estante, una locadora y una banda sonora.';

  @override
  String get highlightsEmptyOther => 'Nada destacado todavía.';

  @override
  String highlightTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'top4': 'Top 4',
      'shelf': 'Estante destacado',
      'locadora': 'Locadora destacada',
      'soundtrack': 'Banda sonora',
      'other': 'Destacado',
    });
    return '$_temp0';
  }

  @override
  String highlightSoundtrackOpen(String service) {
    String _temp0 = intl.Intl.selectLogic(service, {
      'youtubeMusic': 'Escuchar en YouTube Music',
      'other': 'Escuchar en Spotify',
    });
    return '$_temp0';
  }

  @override
  String get highlightChoose => 'Elegir';

  @override
  String get highlightChange => 'Cambiar';

  @override
  String get highlightNotSet => 'Sin definir';

  @override
  String get highlightTop4Pick =>
      'Elige hasta 4 películas que viste, en orden.';

  @override
  String highlightTop4Count(int count) {
    return '$count de 4';
  }

  @override
  String get highlightTop4Empty =>
      'Marca películas como vistas para elegir tu top 4.';

  @override
  String get highlightSoundtrackHint => 'Enlace de Spotify o de YouTube Music';

  @override
  String get highlightSoundtrackInvalid =>
      'Pega un enlace de open.spotify.com o de music.youtube.com';

  @override
  String get highlightsSaveError => 'No se pudieron guardar los destacados';

  @override
  String get diaryEmptyOwn => 'Tus registros aparecen aquí.';

  @override
  String get diaryEmptyOther => 'Ningún registro para mostrar.';

  @override
  String get editProfileSave => 'Guardar';

  @override
  String get editProfileSaveError => 'No se pudo guardar el perfil';

  @override
  String get editProfileInvalidField =>
      'Revisa los campos: algún enlace o imagen puede no ser válido';

  @override
  String get editProfileDisplayNameLabel => 'Nombre';

  @override
  String get editProfileHandleLabel => '@ (nombre de usuario)';

  @override
  String get editProfileHandleHint => '5 a 30 letras, números, . o _';

  @override
  String get editProfileHandleChecking => 'Verificando…';

  @override
  String get editProfileHandleAvailable => 'Disponible';

  @override
  String get editProfileHandleTaken => 'Este @ ya está en uso';

  @override
  String get editProfileHandleInvalid =>
      'Usa de 5 a 30 letras minúsculas, números, puntos o _';

  @override
  String get editProfilePronounsLabel => 'Pronombres';

  @override
  String get editProfilePronounsPlaceholder => 'ej.: ella';

  @override
  String get editProfileLinksLabel => 'Enlaces';

  @override
  String get editProfileAddLink => 'Agregar enlace';

  @override
  String get editProfileAccentLabel => 'Color de acento';

  @override
  String get editProfileAccentDefault => 'Predeterminado';

  @override
  String get editProfileImagesLabel => 'Foto y banner';

  @override
  String get editProfileImagesHint =>
      'Pega el enlace de una imagen. Subir archivos llegará después.';

  @override
  String get editProfileAvatarUrlLabel => 'Enlace de la foto';

  @override
  String get editProfileBannerUrlLabel => 'Enlace del banner';

  @override
  String get discoverReleases => 'En cartelera y estrenos';

  @override
  String get discoverShelves => 'Estantes más populares';

  @override
  String get discoverLocadoras => 'Locadoras de la comunidad';

  @override
  String get discoverProfiles => 'Cinéfilos para seguir';

  @override
  String get discoverExplore => 'Explorar el catálogo';

  @override
  String get discoverEmpty => 'Nada por aquí todavía.';

  @override
  String get discoverFeatured => 'Destacado';

  @override
  String get searchTabMovies => 'Películas';

  @override
  String get newsAllSources => 'Todas';

  @override
  String get newsRead => 'Leído';

  @override
  String get newsMoviesTitle => 'Películas citadas';

  @override
  String get newsWantToWatch => 'Quiero ver';

  @override
  String get newsInWantToWatch => 'En Quiero ver';

  @override
  String get newsWatched => 'Ya la vi';

  @override
  String get newsAddToShelf => 'Agregar al estante';

  @override
  String newsAddedToWatchlist(String title) {
    return '$title está en Quiero ver';
  }

  @override
  String get newsWantToWatchError => 'No se pudo agregar la película';

  @override
  String get personDirected => 'Dirección';

  @override
  String get personActed => 'Actuación';

  @override
  String get personNoCredits => 'Ninguna película del catálogo todavía.';

  @override
  String get attsScopeAll => 'Todos';

  @override
  String get attsScopeFollowing => 'Siguiendo';

  @override
  String get attsScopeMe => 'Solo yo';

  @override
  String get attsEmptyTitle => 'Nada por aquí todavía';

  @override
  String get attsEmptyFollowing => 'Sigue a personas para ver lo que ven.';

  @override
  String get attsEmptyMe => 'Lo que registras, calificas y creas aparece aquí.';

  @override
  String attsWhispersUnread(int count) {
    return 'Susurros, $count sin leer';
  }

  @override
  String get attsFollowsAction => 'Siguiendo y seguidores';

  @override
  String get activityVerbSession => 'registró una sesión de';

  @override
  String get activityVerbFinished => 'vio';

  @override
  String get activityVerbRewatched => 'volvió a ver';

  @override
  String get activityVerbRating => 'calificó';

  @override
  String get activityVerbNewShelf => 'creó el estante';

  @override
  String get activityVerbFeaturedShelf => 'destacó el estante';

  @override
  String get activityVerbNewLocadora => 'abrió la locadora';

  @override
  String get activityVerbWatchingNow => 'está viendo';

  @override
  String activityVerbImported(String source) {
    return 'importó sus películas de $source';
  }

  @override
  String get activityVerbOther => 'hizo algo nuevo';

  @override
  String activityImportCounts(int watched, int watchlist) {
    return '$watched vistas · $watchlist por ver';
  }

  @override
  String get activityLove => 'Me encanta';

  @override
  String get activityUnlove => 'Quitar me encanta';

  @override
  String activityLovesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me encanta',
      one: '1 me encanta',
    );
    return '$_temp0';
  }

  @override
  String get activityMoreOptions => 'Más opciones';

  @override
  String get activityHide => 'Ocultar a los demás';

  @override
  String get activityShow => 'Mostrar de nuevo';

  @override
  String get activityHidden => 'Oculta';

  @override
  String get activityHiddenSnack => 'Ahora solo tú lo ves';

  @override
  String get timeNow => 'ahora';

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
  String get followBackLabel => 'Seguir también';

  @override
  String get followRateLimited =>
      'Demasiados seguimientos seguidos. Inténtalo en un minuto.';

  @override
  String get followError => 'No se pudo actualizar el seguimiento';

  @override
  String get followsEmptyFollowers => 'Aún sin seguidores.';

  @override
  String get followsEmptyFollowing => 'Aún no sigue a nadie.';

  @override
  String get whispersEmptyTitle => 'Ningún susurro todavía';

  @override
  String get whispersEmptyMessage =>
      'Envía un susurro desde el perfil de quien te sigue también.';

  @override
  String get whisperAction => 'Susurrar';

  @override
  String get whisperHint => 'Escribe un susurro';

  @override
  String get whisperSend => 'Enviar';

  @override
  String get whisperDisabled =>
      'Solo pueden susurrarse mientras se siguen mutuamente.';

  @override
  String get whisperMutualLost =>
      'Ya no se siguen. Esta conversación es solo de lectura.';

  @override
  String get whisperMutualRestored => 'Volvieron a seguirse.';

  @override
  String get whisperSendError => 'No se pudo enviar. Inténtalo de nuevo.';

  @override
  String get whisperRateLimited =>
      'Más despacio: demasiados susurros en un minuto.';

  @override
  String whisperYou(String body) {
    return 'Tú: $body';
  }

  @override
  String whisperStart(String name) {
    return 'Saluda a $name';
  }

  @override
  String whisperUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin leer',
      one: '1 sin leer',
    );
    return '$_temp0';
  }

  @override
  String get movieFollowingActivity => 'De quienes sigues';

  @override
  String get maratonaSearchHint => 'Buscar maratones';

  @override
  String get maratonaFilterCurated => 'Curaduría';

  @override
  String get maratonaFilterOpen => 'Sin contraseña';

  @override
  String get maratonaFilterFinished => 'Incluir finalizados';

  @override
  String get maratonaFilterMine => 'Creados por mí';

  @override
  String get maratonaCreate => 'Crear maratón';

  @override
  String get maratonaListEmptyTitle => 'No hay maratones aquí';

  @override
  String get maratonaListEmptyMessage => 'Crea uno o cambia los filtros.';

  @override
  String get maratonaParticipatingEmpty => 'Aún no te uniste a ningún maratón.';

  @override
  String get maratonaStatusUpcoming => 'Próximamente';

  @override
  String get maratonaStatusActive => 'En curso';

  @override
  String get maratonaStatusFinished => 'Finalizado';

  @override
  String get maratonaStatusCancelled => 'Cancelado';

  @override
  String maratonaPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String maratonaParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String maratonaChallengesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count desafíos',
      one: '1 desafío',
    );
    return '$_temp0';
  }

  @override
  String get maratonaJoined => 'Participando';

  @override
  String get maratonaLocked => 'Con contraseña';

  @override
  String get maratonaTabAbout => 'Acerca de';

  @override
  String get maratonaTabChallenges => 'Desafíos';

  @override
  String get maratonaTabQueue => 'Mi fila';

  @override
  String get maratonaTabDiscovery => 'Descubrir';

  @override
  String get maratonaTabRanking => 'Clasificación';

  @override
  String get maratonaJoin => 'Participar';

  @override
  String get maratonaLeave => 'Salir';

  @override
  String get maratonaLeaveTitle => '¿Salir del maratón?';

  @override
  String get maratonaLeaveMessage =>
      'Tu fila y los desafíos marcados se eliminarán.';

  @override
  String get maratonaJoinTitle => 'Unirse al maratón';

  @override
  String get maratonaJoinLevel => 'Nivel';

  @override
  String get maratonaJoinTeam => 'Equipo';

  @override
  String get maratonaNoTeam => 'Sin equipo';

  @override
  String get maratonaPassword => 'Contraseña';

  @override
  String get maratonaWrongPassword => 'Contraseña incorrecta.';

  @override
  String get maratonaClosed => 'Este maratón no está abierto.';

  @override
  String get maratonaActionError => 'No se pudo completar. Intenta de nuevo.';

  @override
  String maratonaOwnerBy(String name) {
    return 'Por $name';
  }

  @override
  String get maratonaCoOwners => 'Corresponsables';

  @override
  String get maratonaLevels => 'Niveles';

  @override
  String get maratonaTeams => 'Equipos';

  @override
  String get maratonaPrizes => 'Premios';

  @override
  String get maratonaProgressFeed => 'Actividad';

  @override
  String get maratonaProgressEmpty => 'Aún no pasó nada.';

  @override
  String maratonaMyProgress(int done, int total) {
    return '$done de $total desafíos';
  }

  @override
  String get maratonaSocialLink => 'Comunidad';

  @override
  String get maratonaEdit => 'Editar';

  @override
  String get maratonaCancel => 'Cancelar maratón';

  @override
  String get maratonaCancelMessage =>
      'Nadie podrá unirse ni marcar desafíos. No se puede deshacer.';

  @override
  String get maratonaCancelConfirm => 'Cancelar maratón';

  @override
  String get maratonaKeep => 'Mantener';

  @override
  String get maratonaChallengeAuto => 'Se completa solo';

  @override
  String get maratonaChallengeManual => 'Se marca a mano';

  @override
  String get maratonaChallengeDaily => 'Diario';

  @override
  String get maratonaTeamOnly => 'Desafíos de equipo';

  @override
  String get maratonaChallengeDone => 'Completado';

  @override
  String get maratonaChallengeOpen => 'Pendiente';

  @override
  String get maratonaLinkMovie => 'Marcar con una película';

  @override
  String get maratonaLinkFromQueue => 'De tu fila';

  @override
  String get maratonaLinkFromWatched => 'De tus vistas';

  @override
  String get maratonaUnlink => 'Quitar';

  @override
  String get maratonaLinkAuto => 'por un registro';

  @override
  String get maratonaLinksEmpty => 'Aún no hay películas.';

  @override
  String get maratonaNotRunning =>
      'Puedes marcar desafíos mientras el maratón está en curso.';

  @override
  String get maratonaJoinToMark => 'Únete para marcar desafíos.';

  @override
  String get maratonaPickerEmpty => 'No hay películas aquí.';

  @override
  String get maratonaQueueEmpty =>
      'Tu fila está vacía. Agrega películas desde Descubrir.';

  @override
  String get maratonaQueueOpen => 'Abrir estante';

  @override
  String get maratonaQueueJoin => 'Únete para tener una fila.';

  @override
  String get maratonaAddToQueue => 'Agregar a la fila';

  @override
  String get maratonaAddedToQueue => 'Agregado a tu fila';

  @override
  String get maratonaDiscoveryPick => 'Elige un desafío';

  @override
  String get maratonaDiscoveryNone =>
      'Ningún desafío de este maratón tiene criterios para sugerir películas.';

  @override
  String get maratonaRankingUsers => 'Participantes';

  @override
  String get maratonaRankingEmpty => 'Nadie completó un desafío todavía.';

  @override
  String maratonaRankingPosition(int position) {
    return '$position.º';
  }

  @override
  String maratonaTeamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get maratonaEditorNewTitle => 'Nuevo maratón';

  @override
  String get maratonaEditorEditTitle => 'Editar maratón';

  @override
  String get maratonaEditorFromScratch => 'Empezar de cero';

  @override
  String get maratonaEditorTemplates => 'O empieza con una plantilla';

  @override
  String maratonaTemplateDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get maratonaStepDetails => 'Datos';

  @override
  String get maratonaStepLevels => 'Niveles y equipos';

  @override
  String get maratonaStepPrizes => 'Premios y privacidad';

  @override
  String get maratonaFieldTitle => 'Título';

  @override
  String get maratonaFieldSlug => 'Dirección';

  @override
  String maratonaSlugHelp(String slug) {
    return 'Letras, números y guiones: /m/$slug';
  }

  @override
  String get maratonaSlugTaken => 'Esta dirección ya existe.';

  @override
  String get maratonaSlugInvalid =>
      'Usa de 3 a 50 letras minúsculas, números o guiones.';

  @override
  String get maratonaSlugAvailable => 'Disponible';

  @override
  String get maratonaFieldDescription => 'Descripción';

  @override
  String get maratonaFieldStart => 'Empieza el';

  @override
  String get maratonaFieldEnd => 'Termina el';

  @override
  String get maratonaFieldColor => 'Color';

  @override
  String get maratonaFieldLogo => 'Logo (enlace de la imagen)';

  @override
  String get maratonaFieldSocial => 'Enlace de la comunidad';

  @override
  String get maratonaAddCategory => 'Agregar categoría';

  @override
  String get maratonaCategoryName => 'Nombre de la categoría';

  @override
  String get maratonaAddChallenge => 'Agregar desafío';

  @override
  String get maratonaChallengeDescription => 'Desafío';

  @override
  String get maratonaCriteria => 'Criterio automático';

  @override
  String get maratonaCriteriaNone => 'Sin criterio: se marca a mano';

  @override
  String get maratonaCriteriaGenres => 'Géneros';

  @override
  String get maratonaCriteriaDecades => 'Décadas';

  @override
  String get maratonaCriteriaCountries => 'Países';

  @override
  String get maratonaCriteriaLanguages => 'Idioma original';

  @override
  String get maratonaCriteriaRuntimeMin => 'Al menos (minutos)';

  @override
  String get maratonaCriteriaRuntimeMax => 'Como máximo (minutos)';

  @override
  String get maratonaCriteriaVote => 'Nota mínima en TMDB';

  @override
  String get maratonaCriteriaCodesHint =>
      'Códigos separados por comas, como BR, FR';

  @override
  String get maratonaCriteriaKept =>
      'Se mantienen los demás criterios de este desafío.';

  @override
  String get maratonaCriteriaApply => 'Aplicar';

  @override
  String get maratonaCriteriaClear => 'Borrar criterio';

  @override
  String get maratonaMinChallenges => 'Desafíos para completar';

  @override
  String get maratonaAddLevel => 'Agregar nivel';

  @override
  String get maratonaLevelName => 'Nombre del nivel';

  @override
  String get maratonaDefaultLevel =>
      'Sin niveles, completar todos los desafíos completa el maratón.';

  @override
  String get maratonaAddTeam => 'Agregar equipo';

  @override
  String get maratonaTeamName => 'Nombre del equipo';

  @override
  String get maratonaAddPrize => 'Agregar premio';

  @override
  String get maratonaPrizeTitle => 'Premio';

  @override
  String get maratonaFieldPassword => 'Contraseña para unirse (opcional)';

  @override
  String get maratonaKeepPassword =>
      'Déjalo vacío para mantener la contraseña actual.';

  @override
  String get maratonaRemovePassword => 'Quitar contraseña';

  @override
  String get maratonaSave => 'Guardar';

  @override
  String get maratonaNext => 'Siguiente';

  @override
  String get maratonaBack => 'Atrás';

  @override
  String get maratonaRemove => 'Quitar';

  @override
  String maratonaMinChallengesError(int min) {
    return 'Agrega al menos $min desafíos.';
  }

  @override
  String get maratonaRequired => 'Obligatorio';

  @override
  String get maratonaPeriodError =>
      'El final debe ser el mismo día del inicio o después.';

  @override
  String get maratonaStartedNote =>
      'El maratón empezó: solo se pueden cambiar textos, color, logo, enlace y premios.';

  @override
  String get maratonaSaveError =>
      'No se pudo guardar. Revisa los campos e intenta de nuevo.';

  @override
  String get activityVerbCreatedMaratona => 'creó el maratón';

  @override
  String get activityVerbJoinedMaratona => 'se unió al maratón';

  @override
  String get activityVerbFinishedChallenge => 'completó un desafío en';

  @override
  String get activityVerbFinishedMaratona => 'completó el maratón';

  @override
  String activityMaratonaLevel(String level, int done, int total) {
    return 'Nivel $level · $done de $total desafíos';
  }

  @override
  String get maratonaLoadMore => 'Cargar más';

  @override
  String get activityVerbCreatedCineClube => 'creó el cineclub';

  @override
  String get activityVerbJoinedCineClube => 'se unió al cineclub';

  @override
  String get cineclubeAddSession => 'Agregar película';

  @override
  String get cineclubeCancel => 'Cancelar cineclub';

  @override
  String get cineclubeCancelMessage =>
      'Nadie más podrá unirse ni cambiar nada.';

  @override
  String get cineclubeClosed => 'Este cineclub no está abierto.';

  @override
  String cineclubeCompletedSessions(int done, int total) {
    return '$done de $total películas';
  }

  @override
  String get cineclubeCreate => 'Crear cineclub';

  @override
  String get cineclubeCurrentSession => 'En cartelera';

  @override
  String get cineclubeCycle => 'Ciclo';

  @override
  String get cineclubeCycleHelp =>
      'Con más de una película se vuelve un ciclo: una película tras otra, cada una con su período y su día de debate.';

  @override
  String get cineclubeDebateLink => 'Enlace del debate (llamada o chat)';

  @override
  String cineclubeDebateOn(String date) {
    return 'Debate el $date';
  }

  @override
  String get cineclubeEditorEditTitle => 'Editar cineclub';

  @override
  String get cineclubeEditorNewTitle => 'Nuevo cineclub';

  @override
  String get cineclubeFieldDebate => 'Día del debate';

  @override
  String get cineclubeFilterAll => 'Todos';

  @override
  String get cineclubeFutureSessionError =>
      'Las películas nuevas o cambiadas tienen que empezar después de hoy.';

  @override
  String get cineclubeGif => 'GIF';

  @override
  String get cineclubeJoin => 'Unirse al cineclub';

  @override
  String get cineclubeJoined => 'Te uniste. La película está en tu Quiero ver.';

  @override
  String get cineclubeLeaveMessage => 'La película sigue en tu Quiero ver.';

  @override
  String get cineclubeLeaveTitle => '¿Salir del cineclub?';

  @override
  String get cineclubeListEmptyMessage =>
      'Crea uno e invita a la gente a ver una película juntos.';

  @override
  String get cineclubeListEmptyTitle => 'No hay cineclubes aquí';

  @override
  String get cineclubeMovieAndDates => 'Película y fechas';

  @override
  String get cineclubeMovieRequired => 'Elige la película de cada sesión.';

  @override
  String get cineclubeOverlapError =>
      'Las películas de un ciclo no pueden superponerse.';

  @override
  String get cineclubeParticipantsEmpty => 'Nadie por aquí todavía';

  @override
  String get cineclubeParticipatingEmpty =>
      'Todavía no te uniste a ningún cineclub.';

  @override
  String get cineclubePickMovie => 'Elegir película';

  @override
  String get cineclubeProgressCompleted => 'La vio';

  @override
  String get cineclubeProgressEmptyMessage =>
      'Las sesiones que registren los participantes en el período aparecen aquí.';

  @override
  String get cineclubeProgressEmptyTitle => 'Ninguna sesión todavía';

  @override
  String get cineclubeProgressPending => 'No empezó';

  @override
  String get cineclubeProgressWatching => 'Viendo';

  @override
  String cineclubeRuntime(int minutes) {
    return '$minutes min';
  }

  @override
  String get cineclubeSave => 'Guardar';

  @override
  String get cineclubeSearchHint => 'Buscar cineclubes';

  @override
  String get cineclubeSearchMovie => 'Buscar una película';

  @override
  String cineclubeSessionLabel(int number, String title) {
    return '$number. $title';
  }

  @override
  String cineclubeSessionNumber(int number) {
    return 'Película $number';
  }

  @override
  String get cineclubeSessionStarted => 'Ya empezó';

  @override
  String get cineclubeSessions => 'Películas del ciclo';

  @override
  String cineclubeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count películas',
      one: '1 película',
    );
    return '$_temp0';
  }

  @override
  String cineclubeSlugHelp(String slug) {
    return 'muuvie.app/c/$slug';
  }

  @override
  String get cineclubeSpoilerHidden =>
      'Comentario oculto hasta que termines la película o llegue el día del debate.';

  @override
  String get cineclubeSpoilerNote =>
      'Los comentarios quedan ocultos hasta que la veas, o hasta el debate.';

  @override
  String get cineclubeTabParticipants => 'Participantes';

  @override
  String get cineclubeTabProgress => 'Progreso';

  @override
  String cineclubeWatchedMinutes(int minutes) {
    return '$minutes min vistos';
  }

  @override
  String cineclubeWatchedPercent(int percent) {
    return '$percent% visto';
  }

  @override
  String get cineclubeWhereToWatch => 'Dónde ver';

  @override
  String get chartsGoalTitle => 'Meta de películas del año';

  @override
  String get chartsGoalSave => 'Guardar meta';

  @override
  String get chartsGoalInvalid => 'Escribe un número entre 1 y 5000.';

  @override
  String chartsGoalPrompt(String year) {
    return 'Define cuántas películas quieres ver en $year.';
  }

  @override
  String get chartsGoalSet => 'Definir meta';

  @override
  String chartsGoalProgress(int watched, int target, String year) {
    return '$watched de $target películas en $year';
  }

  @override
  String get chartsGoalReached => '¡Meta cumplida!';

  @override
  String get chartsEmptyTitle => 'Ninguna sesión este año';

  @override
  String get chartsEmptyMessage =>
      'Las sesiones registradas en el año aparecen aquí en gráficos.';

  @override
  String chartsOpenRetrospective(String year) {
    return 'Ver la retrospectiva de $year';
  }

  @override
  String get chartsMovies => 'películas';

  @override
  String get chartsHours => 'horas frente a la pantalla';

  @override
  String get chartsSessions => 'sesiones';

  @override
  String get chartsRewatches => 'revistas';

  @override
  String get chartsMonths => 'Películas por mes';

  @override
  String get chartsGenres => 'Géneros';

  @override
  String get chartsOthers => 'Otros';

  @override
  String get chartsDecades => 'Décadas';

  @override
  String chartsDecade(String decade) {
    return 'Años $decade';
  }

  @override
  String get chartsCountries => 'Países';

  @override
  String get chartsLanguages => 'Idiomas';

  @override
  String get chartsVenues => 'Dónde las viste';

  @override
  String get chartsDirectors => 'Directores';

  @override
  String get chartsEmotions => 'Emociones';

  @override
  String get chartsRatings => 'Valoraciones';

  @override
  String get chartsCalendar => 'Calendario';

  @override
  String chartsCalendarSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sesiones en $count días',
      one: 'Sesiones en 1 día',
    );
    return '$_temp0';
  }

  @override
  String get retrospectiveShare => 'Compartir esta historia';

  @override
  String retrospectiveShareText(String year) {
    return 'Mi $year en películas en Muuvie';
  }

  @override
  String get retrospectiveEmpty =>
      'Todavía ninguna película terminada este año';

  @override
  String get retrospectiveIntro => 'Tu año en el cine';

  @override
  String retrospectiveMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'películas',
      one: 'película',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'horas frente a la pantalla',
      one: 'hora frente a la pantalla',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveRewatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Y $count películas revistas',
      one: 'Y 1 película revista',
    );
    return '$_temp0';
  }

  @override
  String get retrospectiveTopGenres => 'Tus géneros';

  @override
  String get retrospectiveTopDirectors => 'Quién más viste en la dirección';

  @override
  String get retrospectiveTopActors => 'Caras que más viste';

  @override
  String get retrospectiveEmotion => 'La emoción de tu año';

  @override
  String get retrospectiveFavorite => 'Tu película favorita';

  @override
  String get retrospectiveBestMonth => 'Tu mes más cinéfilo';

  @override
  String retrospectiveMaratonas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maratones terminadas',
      one: '1 maratón terminada',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveCineclubes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cineclubes',
      one: '1 cineclub',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveGoalReached(int target) {
    return '¡Meta de $target películas cumplida!';
  }

  @override
  String retrospectiveGoalProgress(int watched, int target) {
    return '$watched de las $target películas de tu meta';
  }

  @override
  String get retrospectiveOutro => 'Hasta la próxima sesión';

  @override
  String get activityVerbUnlockedBichinho => 'desbloqueó la vaquinha';

  @override
  String get petShelterTitle => 'Vaquinha de la Bombonière';

  @override
  String get petAdopt => 'Adoptar una vaquinha';

  @override
  String get petStarterTitle => 'Elige tu balde de palomitas';

  @override
  String get petStarterMessage =>
      'Tu vaquinha crece con los minutos que ves y las sesiones que registras. La primera elección es para siempre.';

  @override
  String petStarterConfirmTitle(String name) {
    return '¿Adoptar $name?';
  }

  @override
  String get petStarterConfirmMessage =>
      'La primera vaquinha no se puede cambiar después. Los demás se desbloquean viendo.';

  @override
  String get petStarterConfirm => 'Adoptar';

  @override
  String petLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String petXp(int xp, int next) {
    return '$xp de $next XP';
  }

  @override
  String get petXpHelp =>
      'Cada película terminada da 20 XP, más 1 cada 10 minutos. Las importaciones no cuentan.';

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
  String get petLocked => 'Por desbloquear';

  @override
  String get petPin => 'Mostrar en mi perfil';

  @override
  String get petRarityStarter => 'Inicial';

  @override
  String get petRarityCommon => 'Común';

  @override
  String get petRarityRare => 'Raro';

  @override
  String get petRarityLegendary => 'Legendario';

  @override
  String get petPipocaDoce => 'Palomitas dulces';

  @override
  String get petPipocaSalgada => 'Palomitas saladas';

  @override
  String get petPipocaCaramelo => 'Palomitas de caramelo';

  @override
  String get petPipocaDoceAbout => 'Ama el romance y la animación.';

  @override
  String get petPipocaSalgadaAbout => 'No se pierde un suspenso.';

  @override
  String get petPipocaCarameloAbout => 'Colecciona clásicos.';

  @override
  String get petClaquete => 'Claqueta';

  @override
  String get petIngresso => 'Entrada';

  @override
  String get petFantasminha => 'Fantasmita';

  @override
  String get petRobozinho => 'Robotito';

  @override
  String get petLanterninha => 'Acomodador';

  @override
  String get petRoloDeFilme => 'Rollo de película';

  @override
  String get petDinossauro => 'Dinosaurio';

  @override
  String get petCoruja => 'Búho';

  @override
  String get petTrofeu => 'Trofeo';

  @override
  String get petProjetor => 'Proyector';

  @override
  String get petEstatueta => 'Estatuilla';

  @override
  String get petRuleStarter => 'Paquete inicial';

  @override
  String petRuleMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mira $count películas',
      one: 'Mira 1 película',
    );
    return '$_temp0';
  }

  @override
  String petRuleMinutes(int count) {
    return 'Mira $count minutos';
  }

  @override
  String petRuleHorror(int count) {
    return 'Mira $count películas de terror';
  }

  @override
  String petRuleSciFi(int count) {
    return 'Mira $count películas de ciencia ficción';
  }

  @override
  String petRuleOldMovies(int count, String year) {
    return 'Mira $count películas de antes de $year';
  }

  @override
  String petRuleMaratonas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Termina $count maratones',
      one: 'Termina una maratón',
    );
    return '$_temp0';
  }

  @override
  String petRuleCineclubes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Únete a $count cineclubes',
      one: 'Únete a un cineclub',
    );
    return '$_temp0';
  }

  @override
  String petRuleMissions(int count) {
    return 'Cumple $count misiones';
  }

  @override
  String get missionsTitle => 'Misiones';

  @override
  String missionsWeek(String start, String end) {
    return 'Semana del $start al $end';
  }

  @override
  String get missionsHelp =>
      'Tres misiones nuevas cada lunes. El XP va a tu vaquinha destacada.';

  @override
  String missionXp(int xp) {
    return '+$xp XP';
  }

  @override
  String get missionDone => '¡Cumplida!';

  @override
  String missionSessions(int count) {
    return 'Registra $count sesiones';
  }

  @override
  String missionMovies(int count) {
    return 'Termina $count películas';
  }

  @override
  String missionEmotions(int count) {
    return 'Registra $count sesiones con emociones';
  }

  @override
  String get missionLongMovie => 'Mira una película de 2h30 o más';

  @override
  String get missionClassic => 'Mira una película de antes de 1970';

  @override
  String get missionDocumentary => 'Mira un documental';

  @override
  String get missionHorror => 'Mira una película de terror';

  @override
  String get missionAnimation => 'Mira una animación';

  @override
  String get missionAsia => 'Mira una película de Asia';

  @override
  String get missionAfrica => 'Mira una película de África';

  @override
  String get missionBrazil => 'Mira una película brasileña';

  @override
  String get missionCineclube => 'Únete a un cineclub';

  @override
  String get missionChallenge => 'Completa un desafío de maratón';

  @override
  String get diaryTitle => 'Cuadernito';

  @override
  String get diaryToday => 'Hoy';

  @override
  String get diaryPreviousDay => 'Día anterior';

  @override
  String get diaryNextDay => 'Día siguiente';

  @override
  String get diaryMood => '¿Cómo fue tu día?';

  @override
  String diaryGoals(int count, int max) {
    return 'Metas ($count de $max)';
  }

  @override
  String get diaryAddGoal => 'Agregar meta';

  @override
  String get diaryAdd => 'Agregar';

  @override
  String get diaryGoalHint => 'Ver Rashomon';

  @override
  String get diaryNoGoals => 'Ninguna meta para este día.';

  @override
  String get diaryReorder => 'Reordenar';

  @override
  String get diaryNote => 'Desahogo';

  @override
  String get diaryNoteHint => 'Escribe lo que quieras sobre hoy';

  @override
  String get diaryPrivate => 'Solo tú ves tu Cuadernito.';

  @override
  String get diarySaved => 'Día guardado';

  @override
  String get diaryDiscardTitle => '¿Salir sin guardar?';

  @override
  String get diaryDiscardMessage => 'Los cambios de este día se perderán.';

  @override
  String get diaryDiscard => 'Salir';

  @override
  String get diaryYearTitle => 'Año de ánimos';

  @override
  String diaryYearOf(String year) {
    return 'Tu $year en ánimos';
  }

  @override
  String diaryYearDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días escritos',
      one: '1 día escrito',
    );
    return '$_temp0';
  }

  @override
  String diaryYearTop(String mood) {
    return 'más que nada: $mood';
  }

  @override
  String get diaryCategoryMovie => 'Película';

  @override
  String get diaryCategoryShort => 'Corto';

  @override
  String get diaryCategorySeries => 'Serie';

  @override
  String get diaryCategoryStudy => 'Estudio';

  @override
  String get diaryCategoryOther => 'Otros';

  @override
  String get moodGreat => 'Genial';

  @override
  String get moodGood => 'Bien';

  @override
  String get moodOkay => 'Más o menos';

  @override
  String get moodBad => 'Mal';

  @override
  String get moodAwful => 'Pésimo';

  @override
  String get partyTitle => 'Sesión sincronizada';

  @override
  String get partyIntro =>
      'Dale play junto con tus amigos: crea una sala, comparte el código y empieza la cuenta regresiva.';

  @override
  String get partyCreate => 'Crear una sala';

  @override
  String get partyFieldTitle => '¿Qué van a ver?';

  @override
  String get partyJoin => 'Entrar con un código';

  @override
  String get partyFieldCode => 'Código de la sala';

  @override
  String get partyNotFound => 'No hay ninguna sala con ese código.';

  @override
  String get partyFull => 'Esta sala está llena.';

  @override
  String get partyClosed => 'La sala se cerró';

  @override
  String partyCodeLabel(String code) {
    return 'Código de la sala $code';
  }

  @override
  String get partyCopyCode => 'Copiar código';

  @override
  String get partyCodeCopied => 'Código copiado';

  @override
  String partyMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas en la sala',
      one: '1 persona en la sala',
    );
    return '$_temp0';
  }

  @override
  String get partyWaiting =>
      'Esperando que quien creó la sala empiece la cuenta';

  @override
  String get partyWaitingHost => 'Cuando todos estén listos, empieza la cuenta';

  @override
  String get partyStart => 'Empezar la cuenta';

  @override
  String get partyRestart => 'Reiniciar la cuenta';

  @override
  String partyStartIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'En $seconds segundos',
      one: 'En 1 segundo',
    );
    return '$_temp0';
  }

  @override
  String partySecondsLeft(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Faltan $seconds segundos',
      one: 'Falta 1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get partyPlay => '¡Play!';

  @override
  String get partyNoMessages => 'Ningún mensaje todavía';

  @override
  String get partyMessageHint => 'Di algo';

  @override
  String get partySend => 'Enviar';

  @override
  String get posterGameTitle => 'Juego del Póster';

  @override
  String get posterGameHint => 'Un póster de película desenfocado';

  @override
  String get posterGameQuestion => '¿Qué película es?';

  @override
  String posterGameScore(int points) {
    return '$points puntos';
  }

  @override
  String posterGameStreak(int count) {
    return 'Racha: $count';
  }

  @override
  String get posterGameRight => '¡Acertaste!';

  @override
  String posterGameWrong(String title) {
    return 'Era $title';
  }

  @override
  String get posterGameNext => 'Siguiente póster';

  @override
  String get onboardingWelcomeTitle => 'Muuvie es una maratón de películas';

  @override
  String get onboardingWelcomeText =>
      'Guarda lo que ves, acepta desafíos y mira junto con otros cinéfilos.';

  @override
  String get onboardingShelvesTitle => 'Estantes y videoclubes';

  @override
  String get onboardingShelvesText =>
      'Ya la vi y Quiero ver siempre están. Crea tus estantes y júntalas en videoclubes.';

  @override
  String get onboardingLogsTitle => 'Registra cada sesión';

  @override
  String get onboardingLogsText =>
      'Estrellas, emociones, GIF y comentario para cada película, eligiendo quién ve cada uno.';

  @override
  String get onboardingProgramacaoTitle => 'Maratones y cineclubes';

  @override
  String get onboardingProgramacaoText =>
      'Únete a maratones con desafíos que se completan solos y a cineclubes con día de debate y sin spoilers.';

  @override
  String get onboardingSocialTitle => 'Amigos y una vaquinha';

  @override
  String get onboardingSocialText =>
      'Sigue a personas, envía Susurros y cría una vaquinha que crece con cada película.';

  @override
  String get onboardingImportTitle => 'Trae tu historial';

  @override
  String get onboardingImportText =>
      'Importa desde Filmow lo que viste, lo que quieres ver y tus listas. Nada de lo que hiciste aquí se sobrescribe.';

  @override
  String get onboardingImportFilmow => 'Importar desde Filmow';

  @override
  String get onboardingSuggestionsTitle => 'En cartelera';

  @override
  String get onboardingSuggestionsText =>
      'Maratones y cineclubes abiertos para unirte hoy.';

  @override
  String get onboardingSuggestionsEmpty =>
      'Nada abierto ahora. ¡Crea el primero en Programación!';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String onboardingStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsImport => 'Importar películas';

  @override
  String get settingsImportHint =>
      'Desde Filmow, sin sobrescribir lo que hiciste aquí';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotifyMessages => 'Susurros';

  @override
  String get settingsNotifyFollowers => 'Nuevos seguidores';

  @override
  String get settingsNotifyLoves => 'Me encanta en mis actividades';

  @override
  String get settingsNotifyMaratonas => 'Maratones en las que entré';

  @override
  String get settingsNotifyCineclubes => 'Día de debate de mis cineclubes';

  @override
  String get settingsPushOff =>
      'Las notificaciones están desactivadas en este dispositivo';

  @override
  String get settingsPushOffHint =>
      'Permítelas para recibir Susurros y avisos con la app cerrada. Si no pasa nada, actívalas en los ajustes del dispositivo.';

  @override
  String get settingsPushAllow => 'Permitir';

  @override
  String get settingsAbout => 'Muuvie';

  @override
  String get settingsShowIntro => 'Ver la introducción otra vez';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutTitle => '¿Cerrar sesión en Muuvie?';

  @override
  String get movieDetailRecordsTab => 'Actividad';

  @override
  String get movieRecordsEmpty =>
      'Nadie registró esta película todavía. ¡Sé la primera persona!';

  @override
  String movieCommunityWatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas la vieron',
      one: '1 persona la vio',
      zero: 'Nadie la vio todavía',
    );
    return '$_temp0';
  }

  @override
  String movieCommunityWantToWatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas quieren verla',
      one: '1 persona quiere verla',
      zero: 'Nadie quiere verla todavía',
    );
    return '$_temp0';
  }

  @override
  String get movieEventsTitle => 'En la Programação';

  @override
  String movieEventCountsFor(String challenges) {
    return 'Cuenta para: $challenges';
  }

  @override
  String get movieDetailWrittenBy => 'Guion de';

  @override
  String get movieDetailTrailer => 'Ver tráiler';

  @override
  String get movieDetailCreateCineClube =>
      'Crear un CineClube con esta película';

  @override
  String get movieDetailWatchParty => 'Sesión sincronizada';

  @override
  String get movieActivitiesRatings => 'Valoraciones';

  @override
  String get movieActivitiesUpdates => 'Actualizaciones';

  @override
  String get movieActivitiesEverything => 'Todo';

  @override
  String get movieActivitiesEveryone => 'Todos';

  @override
  String get movieActivitiesFollowing => 'Siguiendo';

  @override
  String get movieActivitiesOnlyMe => 'Solo yo';

  @override
  String get movieCommunityTitle => 'Comunidad';

  @override
  String movieCommunityShelves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Está en $count estanterías',
      one: 'Está en 1 estantería',
    );
    return '$_temp0';
  }

  @override
  String get movieCommunityFeelings => 'Cómo se sintió la gente';

  @override
  String get movieRecentRatings => 'Valoraciones recientes';

  @override
  String get movieRecentRatingsAll => 'Ver todas';

  @override
  String get movieShelvesTitle => 'Estanterías con esta película';

  @override
  String get movieShelvesEmpty =>
      'Ninguna estantería pública tiene esta película todavía.';

  @override
  String movieShelvesBy(String name) {
    return 'de $name';
  }

  @override
  String get movieDetailReadMore => 'Leer más';

  @override
  String get movieDetailReadLess => 'Leer menos';

  @override
  String get movieDetailSynopsisInEnglish =>
      'Sinopsis disponible solo en inglés';

  @override
  String get movieStatWatched => 'La vieron';

  @override
  String get movieStatWantToWatch => 'Quieren verla';

  @override
  String get movieStatShelves => 'Estanterías';

  @override
  String movieEmotionsAll(int count) {
    return 'Ver todas ($count)';
  }

  @override
  String get movieTimelineTitle => 'Últimos 12 meses';

  @override
  String get movieTimelineSessions => 'Sesiones';

  @override
  String movieTimelineMonth(String month, int sessions, int ratings) {
    return '$month: $sessions sesiones, $ratings reseñas';
  }

  @override
  String get movieShelvesSection => 'En estanterías';

  @override
  String get movieMaratonasSection => 'Maratonas en las que contó';

  @override
  String get cineclubeStatusFinished => 'Finalizado';

  @override
  String get movieCommunityEmpty =>
      'Nadie hizo nada con esta película todavía.';

  @override
  String get discoverTrending => 'En tendencia en Muuvie';

  @override
  String get discoverMostLoved => 'Los más amados en Muuvie';

  @override
  String get discoverGenres => 'Géneros';

  @override
  String get discoverSectionError => 'No se pudo cargar esta sección';

  @override
  String get searchMinLetters => 'Escribe al menos 3 letras';

  @override
  String get searchRecent => 'Búsquedas recientes';

  @override
  String get searchClearRecent => 'Borrar todo';

  @override
  String get searchRemoveRecent => 'Quitar';

  @override
  String get searchTabPeople => 'Personas';

  @override
  String shelfByOwner(String name) {
    return 'de $name';
  }

  @override
  String get shelfSavedLabel => 'Guardada';

  @override
  String get shelfSaveError =>
      'No se pudieron actualizar las estantes guardadas. Inténtalo de nuevo.';

  @override
  String shelfOpenOwnerProfile(String name) {
    return 'Abrir el perfil de $name';
  }

  @override
  String get savedShelvesTitle => 'Estantes guardadas';

  @override
  String get savedShelvesAction => 'Guardadas';

  @override
  String get savedShelvesEmpty =>
      'Las estantes que guardes de otras personas aparecen aquí.';
}
