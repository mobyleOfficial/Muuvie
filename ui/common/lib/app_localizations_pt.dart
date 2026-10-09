// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Muuvie';

  @override
  String get home => 'Início';

  @override
  String get search => 'Pesquisar';

  @override
  String get profile => 'Perfil';

  @override
  String get moviesTab => 'Filmes';

  @override
  String get reviewsTab => 'Reviews';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String movieRelease(String date) {
    return 'Lançamento: $date';
  }

  @override
  String movieRating(String rating) {
    return 'Nota: $rating';
  }

  @override
  String movieRuntime(int minutes) {
    return 'Duração: $minutes min';
  }

  @override
  String movieGenres(String genres) {
    return 'Gêneros: $genres';
  }

  @override
  String get socialTab => 'Social';

  @override
  String get newUserActivityTab => 'Nova Atividade';

  @override
  String get searchHint => 'Filmes, pessoas, listas...';

  @override
  String get searchBrowse => 'Explorar';

  @override
  String get searchBrowseReleaseDate => 'Data de lançamento';

  @override
  String get searchBrowseGenre => 'Gênero';

  @override
  String get searchBrowseCountryAndLanguage => 'País e idioma';

  @override
  String get searchBrowseGenreCountryLanguage => 'Gênero, País e Idioma';

  @override
  String get searchBrowseCountry => 'País';

  @override
  String get searchBrowseLanguage => 'Idioma';

  @override
  String get searchBrowseService => 'Serviço';

  @override
  String get searchBrowseMostPopular => 'Mais populares';

  @override
  String get searchBrowseHighestRated => 'Mais bem avaliados';

  @override
  String get searchBrowseMostAnticipated => 'Mais aguardados';

  @override
  String get searchBrowseFeaturedLists => 'Listas em destaque';

  @override
  String get profileTabProfile => 'Perfil';

  @override
  String get profileTabDiary => 'Reviews';

  @override
  String get profileTabReviews => 'Reviews';

  @override
  String get profileTabLists => 'Listas';

  @override
  String get profileTabWatchlist => 'Assistir Depois';

  @override
  String get profileFollowers => 'Seguidores';

  @override
  String get profileFollowing => 'Seguindo';

  @override
  String get profileMoviesWatched => 'Assistidos';

  @override
  String get profileMoviesWatchedTitle => 'Filmes assistidos';

  @override
  String get profileFollowingTitle => 'Seguindo';

  @override
  String get profileFollowersTitle => 'Seguidores';

  @override
  String get profileEmptyMoviesWatched => 'Nenhum filme assistido ainda';

  @override
  String get profileEmptyFollowing => 'Você ainda não segue ninguém';

  @override
  String get profileEmptyFollowers => 'Nenhum seguidor ainda';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get editProfileUsernameLabel => 'Nome de usuário';

  @override
  String get editProfileUsernamePlaceholder => 'Digite seu nome de usuário';

  @override
  String get editProfileBioLabel => 'Bio';

  @override
  String get editProfileBioPlaceholder => 'Conte sobre você';

  @override
  String get editProfileChangePhoto => 'Alterar foto';

  @override
  String get profileRecentMovies => 'Filmes recentes';

  @override
  String get profileFavoriteMovies => 'Filmes favoritos';

  @override
  String get profileRecentActivity => 'Atividade recente';

  @override
  String get profileMoviesSection => 'Filmes';

  @override
  String get profileReviewsSection => 'Reviews';

  @override
  String get profileWatchlistSection => 'Watchlist';

  @override
  String get profileSeeAll => 'Ver tudo';

  @override
  String get socialFriendsTab => 'Amigos';

  @override
  String get socialActivitiesTab => 'Atividades';

  @override
  String get socialNoFriends => 'Nenhum amigo ainda';

  @override
  String get moviesListListsTab => 'Listas';

  @override
  String get moviesListArticlesTab => 'Artigos';

  @override
  String get moviesListPopularThisWeek => 'Populares esta semana';

  @override
  String movieListDetailMoviesTab(int count) {
    return '$count Filmes';
  }

  @override
  String movieListDetailCommentsTab(int count) {
    return '$count Comentários';
  }

  @override
  String get movieListDetailCommentsPlaceholder => 'Comentários em breve';

  @override
  String get newUserActivityDraftsSection => 'Rascunhos';

  @override
  String get newUserActivityRecentSection => 'Recentes';

  @override
  String get profileFollow => 'Seguir';

  @override
  String get reviewDetailsBodyTitle => 'Meu Review';

  @override
  String get noResults => 'Nenhum resultado encontrado';

  @override
  String get movieReviewTitle => 'Review';

  @override
  String get movieReviewNameHint => 'Título do Reiew';

  @override
  String get movieReviewAddReview => 'Adicionar um review...';

  @override
  String get movieReviewRewatch => 'Reassistindo';

  @override
  String get movieReviewFirstTime => 'Primeira vez';

  @override
  String get movieReviewTags => 'Tags';

  @override
  String get movieReviewTagMasterpiece => 'Obra-prima';

  @override
  String get movieReviewTagOverrated => 'Superestimado';

  @override
  String get movieReviewTagUnderrated => 'Subestimado';

  @override
  String get movieReviewTagMustWatch => 'Imperdível';

  @override
  String get movieReviewTagDisappointing => 'Decepcionante';

  @override
  String get movieReviewTagFeelGood => 'Reconfortante';

  @override
  String get movieReviewTagMindBending => 'Intrigante';

  @override
  String get movieReviewTagEmotional => 'Emocionante';

  @override
  String get movieReviewSend => 'Enviar review';

  @override
  String get deleteDraftTitle => 'Excluir rascunho?';

  @override
  String get deleteDraftContent =>
      'Este rascunho será excluído permanentemente.';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reviewEditorTitle => 'Escrever um review';

  @override
  String get reviewEditorPlaceholder => 'Comece a escrever seu review...';

  @override
  String get reviewEditorClear => 'Limpar tudo';

  @override
  String get reviewEditorClearConfirmTitle => 'Limpar review?';

  @override
  String get reviewEditorClearConfirmContent => 'Todo o texto será removido.';

  @override
  String get reviewDetailsAddReview => 'Adicionar um review...';

  @override
  String get movieListDetailShowGridView => 'Mostrar visualização em grade';

  @override
  String get movieListDetailShowListView => 'Mostrar visualização em lista';

  @override
  String get emptyStateErrorTitle => 'Algo deu errado';

  @override
  String get emptyStateErrorMessage =>
      'Ocorreu um erro inesperado. Por favor, tente novamente.';

  @override
  String get emptyStateRetry => 'Tentar novamente';

  @override
  String get emptyStateNoItemsTitle => 'Nada aqui ainda';

  @override
  String get emptyStateNoItemsMessage => 'Não há itens para exibir.';

  @override
  String get clearSearch => 'Limpar';

  @override
  String get submitReviewTitle => 'Enviar Avaliação';

  @override
  String get submitReviewContent =>
      'Tem certeza de que deseja enviar esta avaliação? Ela será publicada e o rascunho será removido.';

  @override
  String get submit => 'Enviar';

  @override
  String get submittingReview => 'Enviando avaliação...';

  @override
  String get submissionFailed => 'Falha ao enviar';

  @override
  String get fieldRequired => 'Este campo é obrigatório';

  @override
  String get ratingRequired => 'Por favor selecione uma avaliação';

  @override
  String get reviewBodyRequired => 'Por favor escreva uma avaliação';

  @override
  String get tagsRequired => 'Por favor selecione pelo menos uma tag';

  @override
  String get movieDetailWhereToWatch => 'Onde Assistir';

  @override
  String get movieDetailSynopsis => 'Sinopse';

  @override
  String get movieDetailReviews => 'Avaliações';

  @override
  String get movieDetailSimilar => 'Filmes Similares';

  @override
  String movieDetailLikes(int count) {
    return '$count curtidas';
  }

  @override
  String movieDetailReviewCount(int count) {
    return '$count avaliações';
  }

  @override
  String movieDetailListCount(int count) {
    return '$count listas';
  }

  @override
  String get movieDetailDirectedBy => 'Dirigido por';

  @override
  String movieDetailMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get movieDetailSeeAll => 'Ver tudo';

  @override
  String get movieDetailAboutTab => 'Sobre';

  @override
  String movieDetailMovieReviews(String title) {
    return 'Avaliações de $title';
  }

  @override
  String get comments => 'Comentários';

  @override
  String get noComments => 'Ainda não há comentários';

  @override
  String get loadMore => 'Carregar mais comentários';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get reviewDetailsShare => 'Compartilhar review';

  @override
  String get reviewDetailsLike => 'Curtir review';

  @override
  String get reviewDetailsUnlike => 'Descurtir review';

  @override
  String get reviewDetailsLikeError =>
      'Não foi possível atualizar a curtida. Tente novamente.';

  @override
  String reviewDetailsLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curtidas',
      one: '1 curtida',
      zero: 'Sem curtidas ainda',
    );
    return '$_temp0';
  }

  @override
  String get reviewDetailsCommentsTitle => 'Comentários';

  @override
  String reviewDetailsViewAllComments(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get reviewDetailsNoComments => 'Sem comentários ainda';

  @override
  String get reviewDetailsOtherReviewsForMovie => 'Outros reviews deste filme';

  @override
  String reviewDetailsMoreFromAuthor(String author) {
    return 'Mais reviews de $author';
  }

  @override
  String reviewDetailsBy(String author) {
    return 'por $author';
  }

  @override
  String get reviewDetailsAnonymousAuthor => 'Anônimo';

  @override
  String get reviewDetailsNoBody => 'Sem texto do review';

  @override
  String get reviewDetailsLoadCommentsError =>
      'Não foi possível carregar os comentários';

  @override
  String get reviewDetailsLoadRelatedError =>
      'Não foi possível carregar os reviews relacionados';

  @override
  String get loginSubtitle => 'Entre para descobrir e avaliar filmes';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithFacebook => 'Continuar com Facebook';

  @override
  String get articleDetailShare => 'Compartilhar artigo';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginEmailHint => 'Digite seu e-mail';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginPasswordHint => 'Digite sua senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get signUpButton => 'Cadastrar';

  @override
  String get signUpTitle => 'Criar Conta';

  @override
  String get signUpNickname => 'Apelido';

  @override
  String get signUpNicknameHint => 'Escolha um apelido';

  @override
  String get createAccountButton => 'Criar Conta';

  @override
  String get emailValidationError => 'Por favor digite um e-mail válido';

  @override
  String get passwordValidationError =>
      'A senha deve ter pelo menos 8 caracteres';

  @override
  String get passwordTooLongError => 'A senha deve ter no máximo 72 caracteres';

  @override
  String get nicknameValidationError => 'Por favor digite um apelido';

  @override
  String get nicknameTooLongError =>
      'O apelido deve ter no máximo 30 caracteres';

  @override
  String get nicknameTakenError => 'Esse apelido já está em uso';

  @override
  String get signUpConflictError => 'Esse email ou apelido já está em uso.';

  @override
  String get signUpBadRequestError => 'Verifique seus dados e tente novamente.';

  @override
  String get signUpNetworkError =>
      'Sem conexão com a internet. Tente novamente.';

  @override
  String get signUpServerError =>
      'Erro no servidor. Tente novamente mais tarde.';

  @override
  String get loginError => 'Usuário ou senha incorretos.';

  @override
  String get loginGenericError => 'Algo deu errado, tente de novo mais tarde.';
}
