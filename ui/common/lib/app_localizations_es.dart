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
  String get searchHint => 'Películas, personas, listas...';

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
  String get searchBrowseHighestRated => 'Mejor valoradas';

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
  String get signUpButton => 'Registrarse';

  @override
  String get signUpTitle => 'Crear Cuenta';

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
}
