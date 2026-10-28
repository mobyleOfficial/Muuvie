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
  String get searchHint => 'Filmes, pessoas, estantes e mais';

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
      zero: '0 estantes',
    );
    return '$_temp0';
  }

  @override
  String locadoraMoviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filmes',
      one: '1 filme',
      zero: '0 filmes',
    );
    return '$_temp0';
  }

  @override
  String get profileTabMarathons => 'Maratonas';

  @override
  String get profileTabHistory => 'Histórico';

  @override
  String get profileTabParticipations => 'Participações';

  @override
  String get profileTabCharts => 'Gráficos';

  @override
  String shelfWatchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assistidos',
      one: '1 assistido',
      zero: '0 assistidos',
    );
    return '$_temp0';
  }

  @override
  String shelfMoviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filmes',
      one: '1 filme',
      zero: '0 filmes',
    );
    return '$_temp0';
  }

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
  String get movieDetailUnmatched =>
      'Não encontramos este filme no nosso catálogo. Os dados vêm do Filmow e podem estar incompletos.';

  @override
  String get movieDetailCast => 'Elenco';

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

  @override
  String get loginWelcomeTitle => 'Que bom te ver!';

  @override
  String get loginNoAccount => 'Novo no Muuvie?';

  @override
  String get loginCreateAccountLink => 'Crie uma conta';

  @override
  String get signUpHeadline => 'Pegue seu ingresso';

  @override
  String get signUpSubtitle => 'Crie sua conta em menos de um minuto.';

  @override
  String get signUpHaveAccount => 'Já tem uma conta?';

  @override
  String get signUpNicknameChecking => 'Verificando disponibilidade…';

  @override
  String get signUpNicknameAvailable => 'Apelido disponível';

  @override
  String get signUpPasswordHelper => 'Mínimo de 8 caracteres';

  @override
  String get passwordShow => 'Mostrar senha';

  @override
  String get passwordHide => 'Ocultar senha';

  @override
  String get movieDetailWriteReview => 'Escrever uma Avaliação';

  @override
  String get movieDetailCreateList => 'Criar uma Lista';

  @override
  String get movieDetailActions => 'Ações';

  @override
  String get movieDetailWantToWatch => 'Quero Assistir';

  @override
  String get movieDetailWatched => 'Assistido';

  @override
  String get movieDetailYourRating => 'Sua avaliação';

  @override
  String get movieListDeleteTitle => 'Excluir Lista';

  @override
  String get movieListDeleteContent =>
      'Tem certeza que deseja excluir esta lista? Esta ação não pode ser desfeita.';

  @override
  String get movieListDoneEditing => 'Concluir edição';

  @override
  String get movieListEditList => 'Editar lista';

  @override
  String get movieListDeleteTooltip => 'Excluir lista';

  @override
  String get createListTitle => 'Nova Lista';

  @override
  String get createListSave => 'Salvar';

  @override
  String get createListAddMovies => 'Adicionar Filmes';

  @override
  String get createListNoMovies => 'Nenhum filme adicionado ainda';

  @override
  String get createListNameHint => 'Nome';

  @override
  String get createListDescriptionHint => 'Descrição';

  @override
  String get createListMoviesSection => 'FILMES';

  @override
  String createListMoviesCount(int count) {
    return 'FILMES ($count)';
  }

  @override
  String get editProfileFilmowLogin => 'Login no Filmow';

  @override
  String get editProfileImportFilmow => 'Importar dados do Filmow';

  @override
  String get editProfileImportLetterboxd => 'Importar dados do Letterboxd';

  @override
  String get followLabel => 'Seguir';

  @override
  String get followingLabel => 'Seguindo';

  @override
  String get unfollowLabel => 'Deixar de seguir';

  @override
  String routeReviewsTitle(String title) {
    return 'Avaliações de $title';
  }

  @override
  String get routeReviews => 'Avaliações';

  @override
  String get routeReleaseDate => 'Data de Lançamento';

  @override
  String get routeBrowse => 'Explorar';

  @override
  String get routeMostPopular => 'Mais Populares';

  @override
  String get routeMostAnticipated => 'Mais Esperados';

  @override
  String get routeFeaturedLists => 'Listas em Destaque';

  @override
  String get addShelvesSearchHint => 'Buscar estantes...';

  @override
  String get addShelvesEmptyState => 'Busque estantes para adicionar';

  @override
  String get createLocadoraTitle => 'Nova Locadora';

  @override
  String get createLocadoraNamePrompt => 'Qual o nome da sua locadora?';

  @override
  String get createLocadoraNameHint => 'Nome';

  @override
  String get createLocadoraDescriptionPrompt =>
      'Descreva sua locadora (opcional)';

  @override
  String get createLocadoraDescriptionHint => 'Descrição';

  @override
  String get createLocadoraVisibilityPrompt => 'Quem pode ver esta locadora?';

  @override
  String get createLocadoraSave => 'Criar Locadora';

  @override
  String get createShelfTitle => 'Nova Estante';

  @override
  String get createShelfNamePrompt => 'Qual o nome da sua estante?';

  @override
  String get createShelfNameHint => 'Nome';

  @override
  String get createShelfDescriptionPrompt => 'Descreva sua estante (opcional)';

  @override
  String get createShelfDescriptionHint => 'Descrição';

  @override
  String get createShelfColorPrompt => 'Escolha uma cor para sua estante';

  @override
  String get createShelfVisibilityPrompt => 'Quem pode ver esta estante?';

  @override
  String get createShelfVisibilityPublic => 'Público';

  @override
  String get createShelfVisibilityPrivate => 'Privado';

  @override
  String get createShelfVisibilityMutuals => 'Mútuos';

  @override
  String get createShelfSave => 'Criar Estante';

  @override
  String get visibilityPublic => 'Público';

  @override
  String get visibilityMutual => 'Mútuos';

  @override
  String get visibilitySecret => 'Secreto';

  @override
  String get watchModeWatched => 'Assistido';

  @override
  String get watchModeMinutes => 'Minutos';

  @override
  String get watchModePercent => 'Porcentagem';

  @override
  String get watchVenueCinema => 'Cinema';

  @override
  String get watchVenueStreaming => 'Streaming';

  @override
  String get watchVenueTv => 'TV';

  @override
  String get watchVenuePhysicalMedia => 'Mídia física';

  @override
  String get watchVenueFestival => 'Festival';

  @override
  String get watchVenueOther => 'Outro';

  @override
  String get watchStatusWatched => 'Assistido';

  @override
  String get watchStatusWantToWatch => 'Quero ver';

  @override
  String get systemShelfWatched => 'Já assisti';

  @override
  String get systemShelfWatchlist => 'Quero ver';

  @override
  String get ratingLabelFavorite => 'Favoritado';

  @override
  String get ratingLabelLoved => 'Adorei';

  @override
  String get ratingLabelLiked => 'Gostei';

  @override
  String get ratingLabelNeutral => 'Neutro';

  @override
  String get ratingLabelNotForMe => 'Não foi pra mim';

  @override
  String get ratingLabelAbandoned => 'Abandonei';

  @override
  String get ratingLabelOnHold => 'Na geladeira';

  @override
  String get shelfSortManual => 'Manual';

  @override
  String get shelfSortTitle => 'Título';

  @override
  String get shelfSortDirector => 'Diretor';

  @override
  String get shelfSortReleaseYear => 'Ano de lançamento';

  @override
  String get shelfSortAddedNewest => 'Adicionados recentemente';

  @override
  String get shelfSortAddedOldest => 'Adicionados primeiro';

  @override
  String get shelfSortUpdatedNewest => 'Atualizados recentemente';

  @override
  String get shelfSortWatchedFirst => 'Assistidos primeiro';

  @override
  String get shelfSortWatchedLast => 'Assistidos por último';

  @override
  String get shelfSortProgressHighest => 'Maior progresso';

  @override
  String get shelfSortRatingHighest => 'Por avaliação';

  @override
  String get emotionCuriosity => 'Curiosidade';

  @override
  String get emotionInspiration => 'Inspiração';

  @override
  String get emotionReflection => 'Reflexão';

  @override
  String get emotionRelaxation => 'Relaxamento';

  @override
  String get emotionMoved => 'Comoção';

  @override
  String get emotionNostalgia => 'Nostalgia';

  @override
  String get emotionGratitude => 'Gratidão';

  @override
  String get emotionAffection => 'Afeto';

  @override
  String get emotionSurprise => 'Surpresa';

  @override
  String get emotionPassion => 'Paixão';

  @override
  String get emotionFun => 'Diversão';

  @override
  String get emotionJoy => 'Alegria';

  @override
  String get emotionHumor => 'Humor';

  @override
  String get emotionFreakOut => 'Surto';

  @override
  String get emotionAnxiety => 'Ansiedade';

  @override
  String get emotionDistress => 'Aflição';

  @override
  String get emotionTension => 'Tensão';

  @override
  String get emotionDistraction => 'Distração';

  @override
  String get emotionConfusion => 'Confusão';

  @override
  String get emotionSuspicion => 'Desconfiança';

  @override
  String get emotionIrritation => 'Irritação';

  @override
  String get emotionAnger => 'Raiva';

  @override
  String get emotionIndignation => 'Indignação';

  @override
  String get emotionFear => 'Medo';

  @override
  String get emotionVulnerability => 'Vulnerabilidade';

  @override
  String get emotionEmbarrassment => 'Vergonha';

  @override
  String get emotionFrustration => 'Frustração';

  @override
  String get emotionSadness => 'Tristeza';

  @override
  String get emotionMelancholy => 'Melancolia';

  @override
  String get emotionTiredness => 'Cansaço';

  @override
  String get emotionBoredom => 'Tédio';

  @override
  String get emotionConnection => 'Conexão';

  @override
  String get emotionFocus => 'Foco';

  @override
  String get emotionIntensity => 'Intensidade';

  @override
  String get emotionEnthusiasm => 'Empolgação';

  @override
  String get emotionExcitement => 'Adrenalina';

  @override
  String get emotionEuphoria => 'Euforia';

  @override
  String get emotionShock => 'Choque';

  @override
  String get emotionHorror => 'Horror';

  @override
  String get emotionDisgust => 'Nojo';

  @override
  String get emotionDevastation => 'Devastação';

  @override
  String get emotionGrudge => 'Ranço';

  @override
  String get emotionIndifference => 'Indiferença';

  @override
  String get emotionApathy => 'Apatia';

  @override
  String get editProfileLogout => 'Sair da conta';

  @override
  String get editProfileLogoutConfirmTitle => 'Sair do Muuvie?';

  @override
  String get editProfileLogoutConfirmMessage =>
      'Você pode entrar de novo quando quiser.';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get navAtts => 'Atts';

  @override
  String get navProgramacao => 'Programação';

  @override
  String get navCatalogo => 'Catálogo';

  @override
  String get navNoticias => 'Notícias';

  @override
  String get attsWhispers => 'Sussurros';

  @override
  String get programacaoMaratonasTab => 'Maratonas';

  @override
  String get programacaoCineClubesTab => 'CineClubes';

  @override
  String get programacaoParticipatingFilter => 'Participando';

  @override
  String get programacaoMaratonasComingSoon =>
      'Aqui vão aparecer maratonas de filmes com desafios e prazos.';

  @override
  String get programacaoCineClubesComingSoon =>
      'CineClubes: um filme, um período e um dia de debate.';

  @override
  String colorPickerOption(int index, int total) {
    return 'Cor $index de $total';
  }

  @override
  String emotionPickerCount(int count, int max) {
    return '$count de $max emoções';
  }

  @override
  String movieProgressMinutes(int watched, int total) {
    return '$watched de $total min';
  }

  @override
  String get editShelfTitle => 'Editar estante';

  @override
  String get shelfSave => 'Salvar';

  @override
  String get systemShelfLockedHint =>
      'Estante padrão: não pode ser renomeada nem excluída';

  @override
  String get shelfEdit => 'Editar';

  @override
  String get shelfDelete => 'Excluir estante';

  @override
  String shelfDeleteConfirmTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get shelfDeleteConfirmMessage =>
      'Os filmes continuam no seu histórico.';

  @override
  String get shelfPin => 'Fixar no topo';

  @override
  String get shelfUnpin => 'Desafixar';

  @override
  String get shelfReorder => 'Reordenar estantes';

  @override
  String get shelfReorderDone => 'Concluir';

  @override
  String get shelfPinned => 'Fixada';

  @override
  String shelfWatchedOfTotal(int watched, int total) {
    return '$watched/$total assistidos';
  }

  @override
  String get shelfNew => 'Nova estante';

  @override
  String get shelfAddMovies => 'Adicionar filmes';

  @override
  String get shelfFilterWatched => 'Assistidos';

  @override
  String get shelfFilterNotWatched => 'Não assistidos';

  @override
  String get shelfFilterDecade => 'Década';

  @override
  String shelfFilterDecadeValue(int decade) {
    return 'Anos $decade';
  }

  @override
  String get shelfFilterGenre => 'Gênero';

  @override
  String get shelfFilterAny => 'Qualquer';

  @override
  String get shelfFilterClear => 'Limpar filtros';

  @override
  String get shelfEmptyFiltered => 'Nenhum filme com esses filtros';

  @override
  String get shelfSortBy => 'Ordenar por';

  @override
  String get shelfSortApplyOnce => 'Aplicar só uma vez';

  @override
  String get shelfSortApply => 'Aplicar';

  @override
  String get shelfManualOrder => 'Reordenar filmes';

  @override
  String get shelfMovieRemove => 'Remover da estante';

  @override
  String get shelfMovieMoveTo => 'Mover para…';

  @override
  String get shelfMovieCopyTo => 'Copiar para…';

  @override
  String get shelfMoveAll => 'Mover todos para…';

  @override
  String get shelfCopyAll => 'Copiar todos para…';

  @override
  String get shelfPickTarget => 'Escolha a estante';

  @override
  String get shelfUnmarkWatchedTitle => 'Desmarcar como assistido?';

  @override
  String get shelfUnmarkWatchedMessage =>
      'Os registros desse filme são mantidos.';

  @override
  String get shelfUnmarkWatchedConfirm => 'Desmarcar';

  @override
  String get shelfActionError => 'Não deu para concluir. Tente de novo.';

  @override
  String get addToShelvesAction => 'Adicionar à estante…';

  @override
  String get addToShelvesTitle => 'Adicionar às estantes';

  @override
  String get addToShelvesSave => 'Salvar';

  @override
  String addToShelvesSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estantes',
      one: '1 estante',
      zero: '0 estantes',
    );
    return 'Salvo em $_temp0';
  }

  @override
  String get watchLogAction => 'Registrar sessão';

  @override
  String get watchLogTitle => 'Registrar sessão';

  @override
  String get watchLogEditTitle => 'Editar registro';

  @override
  String get watchLogDate => 'Data';

  @override
  String get watchLogProgress => 'Progresso';

  @override
  String watchLogPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String watchLogMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get watchLogVenue => 'Onde assistiu';

  @override
  String get watchLogProvider => 'Serviço ou cinema (opcional)';

  @override
  String get watchLogEmotions => 'Como foi?';

  @override
  String get watchLogAddGif => 'Adicionar GIF';

  @override
  String get watchLogRemoveGif => 'Remover GIF';

  @override
  String get watchLogComment => 'Comentário (opcional)';

  @override
  String get watchLogSpoiler => 'Contém spoiler';

  @override
  String get watchLogVisibility => 'Quem pode ver';

  @override
  String get watchLogSave => 'Salvar';

  @override
  String get watchLogSaved => 'Sessão registrada';

  @override
  String get watchLogError => 'Não deu para salvar o registro. Tente de novo.';

  @override
  String get gifSearchHint => 'Buscar GIFs';

  @override
  String get gifRecent => 'Recentes';

  @override
  String get gifSearchUnavailable => 'A busca de GIFs está indisponível agora.';

  @override
  String get gifPickerTitle => 'Escolha um GIF';

  @override
  String get gifLabel => 'GIF';

  @override
  String get ratingTitle => 'Avaliar';

  @override
  String get ratingPrompt => 'Qual opção melhor reflete sua avaliação final?';

  @override
  String get ratingReview => 'Comentário (opcional)';

  @override
  String get ratingCreateLog => 'Criar sessão de 100%';

  @override
  String get ratingSave => 'Salvar avaliação';

  @override
  String get ratingRemove => 'Remover avaliação';

  @override
  String get ratingError => 'Não deu para salvar a avaliação. Tente de novo.';

  @override
  String get rewatchAction => 'Assistir de novo';

  @override
  String get rewatchStarted => 'Rewatch iniciado';

  @override
  String get watchingNowTitle => 'Assistindo agora';

  @override
  String watchProgressPercent(int percent) {
    return '$percent% assistido';
  }

  @override
  String get watchStateError => 'Não deu para atualizar. Tente de novo.';

  @override
  String get historyTitle => 'Histórico';

  @override
  String historyMinutes(int minutes) {
    return '$minutes min assistidos';
  }

  @override
  String historySessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões',
      one: '1 sessão',
      zero: '0 sessões',
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
      zero: 'Nenhum rewatch',
    );
    return '$_temp0';
  }

  @override
  String get historyFirstWatch => 'Primeira vez';

  @override
  String historyRewatch(int number) {
    return 'Rewatch $number';
  }

  @override
  String get historyEmpty => 'Nenhum registro ainda';

  @override
  String get historyEdit => 'Editar';

  @override
  String get historyDelete => 'Excluir';

  @override
  String get historyDeleteTitle => 'Excluir este registro?';

  @override
  String get historyDeleteMessage =>
      'O progresso é recalculado. O filme continua em Já assisti.';

  @override
  String get spoilerReveal => 'Spoiler. Toque para ver';

  @override
  String get threadCommentsTitle => 'Comentários';

  @override
  String get threadCommentHint => 'Escreva um comentário';

  @override
  String get threadCommentSend => 'Enviar';

  @override
  String get threadCommentDelete => 'Excluir comentário';

  @override
  String get threadCommentsEmpty => 'Nenhum comentário ainda';

  @override
  String get threadCommentError =>
      'Não deu para enviar o comentário. Tente de novo.';

  @override
  String get editProfileImportSection => 'Importar dados';

  @override
  String get importTitle => 'Importar';

  @override
  String get importIntro =>
      'Traga seu histórico do Filmow: os filmes vistos vão para Já assisti, o quero ver para Quero ver e suas listas viram estantes. Nada é gravado antes de você confirmar.';

  @override
  String get importStartFilmow => 'Entrar no Filmow e importar';

  @override
  String get importFilmowWaitTitle => 'Espere depois do login';

  @override
  String get importFilmowWaitMessage =>
      'Depois de entrar no Filmow, você PRECISA esperar a tela fechar sozinha. Não feche a tela, senão a importação não começa.';

  @override
  String get importFilmowWaitConfirm => 'Entendi';

  @override
  String get importHistoryTitle => 'Importações anteriores';

  @override
  String get importInProgress => 'Você já tem uma importação em andamento.';

  @override
  String get importStartError =>
      'Não deu para começar a importação. Tente de novo.';

  @override
  String get importActionError => 'Algo deu errado. Tente de novo.';

  @override
  String importStatusLabel(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Começando',
      'reading': 'Lendo',
      'preview': 'Esperando você',
      'importing': 'Importando',
      'done': 'Concluída',
      'failed': 'Falhou',
      'cancelled': 'Cancelada',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get importReadingTitle => 'Lendo seu perfil do Filmow';

  @override
  String get importReadingMessage =>
      'Isso pode levar alguns minutos. Você pode sair desta tela: a prévia vai estar esperando aqui.';

  @override
  String get importPreviewTitle => 'Pronto para importar';

  @override
  String importPreviewWatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filmes → Já assisti',
      one: '1 filme → Já assisti',
      zero: '0 filmes → Já assisti',
    );
    return '$_temp0';
  }

  @override
  String importPreviewWatchlist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filmes → Quero ver',
      one: '1 filme → Quero ver',
      zero: '0 filmes → Quero ver',
    );
    return '$_temp0';
  }

  @override
  String importPreviewFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritos viram Favoritado',
      one: '1 favorito vira Favoritado',
      zero: '0 favoritos viram Favoritado',
    );
    return '$_temp0';
  }

  @override
  String importPreviewLogs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões com data',
      one: '1 sessão com data',
      zero: '0 sessões com data',
    );
    return '$_temp0';
  }

  @override
  String get importPreviewLists => 'Listas → estantes';

  @override
  String get importPreviewNoLists => 'Nenhuma lista encontrada no seu perfil.';

  @override
  String get importPreviewVisibility => 'Quem vê as estantes e sessões novas';

  @override
  String get importConfirm => 'Importar';

  @override
  String get importCancel => 'Cancelar importação';

  @override
  String get importImportingTitle => 'Importando seu histórico';

  @override
  String importImportingProgress(int processed, int total) {
    return '$processed de $total';
  }

  @override
  String get importImportingMessage =>
      'Você pode sair desta tela: avisamos quando terminar.';

  @override
  String get importDoneTitle => 'Importação concluída';

  @override
  String importDoneShelves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas viraram estantes',
      one: '1 lista virou estante',
      zero: '0 listas viraram estantes',
    );
    return '$_temp0';
  }

  @override
  String importDoneKept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filmes que você já tinha ficaram como estavam',
      one: '1 filme que você já tinha ficou como estava',
      zero: '0 filmes que você já tinha ficaram como estavam',
    );
    return '$_temp0';
  }

  @override
  String importReviewUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Revisar $count filmes',
      one: 'Revisar 1 filme',
      zero: 'Revisar 0 filmes',
    );
    return '$_temp0';
  }

  @override
  String get importAgain => 'Importar de novo';

  @override
  String get importFailedTitle => 'A importação falhou';

  @override
  String get importCancelledTitle => 'Importação cancelada';

  @override
  String get importCancelledMessage => 'Nada foi gravado.';

  @override
  String get importUnmatchedTitle => 'Confirmar filmes';

  @override
  String get importUnmatchedHint =>
      'Não tivemos certeza sobre estes filmes. Eles já estão nas suas estantes: escolha o certo ou pule.';

  @override
  String get importUnmatchedSkip => 'Pular';

  @override
  String get importUnmatchedNoCandidates => 'Nenhuma sugestão encontrada.';

  @override
  String get importUnmatchedMatched => 'Confirmado';

  @override
  String get importUnmatchedSkipped => 'Pulado';

  @override
  String get importUnmatchedEmpty => 'Todos os filmes foram encontrados.';

  @override
  String get importFinishedSnack => 'Sua importação do Filmow terminou';

  @override
  String get importSeeReport => 'Ver relatório';

  @override
  String get watchedEmptyImport => 'Já usa o Filmow? Traga seu histórico';

  @override
  String get locadoraNew => 'Nova locadora';

  @override
  String get editLocadoraTitle => 'Editar locadora';

  @override
  String get locadoraEdit => 'Editar';

  @override
  String get locadoraDelete => 'Excluir locadora';

  @override
  String locadoraDeleteConfirmTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get locadoraDeleteConfirmMessage =>
      'As estantes continuam no seu perfil.';

  @override
  String get locadoraReorder => 'Reordenar locadoras';

  @override
  String get locadoraEmptyTitle => 'Nenhuma locadora ainda';

  @override
  String get locadoraEmptyMessage =>
      'Agrupe suas estantes como os corredores de uma locadora.';

  @override
  String get locadoraEmptyOtherMessage => 'Nada para mostrar por aqui ainda.';

  @override
  String get locadoraHideInProfile => 'Ocultar as estantes da aba Estantes';

  @override
  String get locadoraHideInFilters => 'Ocultar as estantes dos filtros';

  @override
  String locadoraByOwner(String username) {
    return 'de @$username';
  }

  @override
  String get locadoraChooseShelves => 'Escolher estantes';

  @override
  String get locadoraNoShelves => 'Esta locadora ainda não tem estantes.';

  @override
  String get locadoraPickShelvesTitle => 'Estantes da locadora';

  @override
  String get locadoraPickShelvesEmpty => 'Crie uma estante primeiro.';

  @override
  String get locadoraShelfEmpty => 'Estante vazia';

  @override
  String locadoraProgress(int watched, int total) {
    return '$watched de $total filmes assistidos';
  }

  @override
  String get locadoraOpenShelf => 'Abrir estante';

  @override
  String get profileTabHighlights => 'Destaques';

  @override
  String get profileTabLogs => 'Registros';

  @override
  String get profileStatWatched => 'Assistidos';

  @override
  String get profileStatCineclubes => 'CineClubes';

  @override
  String get profileFollowsYou => 'Segue você';

  @override
  String get profilePickHandleTip => 'Escolha seu @ para os amigos te acharem';

  @override
  String get profileNotFound => 'Perfil não encontrado';

  @override
  String get profileShare => 'Compartilhar perfil';

  @override
  String profileShareText(String name, String link) {
    return '$name no Muuvie: $link';
  }

  @override
  String profileWatchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filmes assistidos',
      one: '1 filme assistido',
      zero: 'nenhum filme assistido',
    );
    return '$_temp0';
  }

  @override
  String get highlightsEdit => 'Editar destaques';

  @override
  String get highlightsEmptyOwnTitle => 'Mostre seu gosto';

  @override
  String get highlightsEmptyOwnMessage =>
      'Escolha um top 4, uma estante, uma locadora e uma trilha sonora.';

  @override
  String get highlightsEmptyOther => 'Nada em destaque ainda.';

  @override
  String highlightTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'top4': 'Top 4',
      'shelf': 'Estante em destaque',
      'locadora': 'Locadora em destaque',
      'soundtrack': 'Trilha sonora',
      'other': 'Destaque',
    });
    return '$_temp0';
  }

  @override
  String highlightSoundtrackOpen(String service) {
    String _temp0 = intl.Intl.selectLogic(service, {
      'youtubeMusic': 'Ouvir no YouTube Music',
      'other': 'Ouvir no Spotify',
    });
    return '$_temp0';
  }

  @override
  String get highlightChoose => 'Escolher';

  @override
  String get highlightChange => 'Trocar';

  @override
  String get highlightNotSet => 'Não definido';

  @override
  String get highlightTop4Pick =>
      'Escolha até 4 filmes que você assistiu, na ordem.';

  @override
  String highlightTop4Count(int count) {
    return '$count de 4';
  }

  @override
  String get highlightTop4Empty =>
      'Marque filmes como assistidos para escolher seu top 4.';

  @override
  String get highlightSoundtrackHint => 'Link do Spotify ou do YouTube Music';

  @override
  String get highlightSoundtrackInvalid =>
      'Cole um link do open.spotify.com ou do music.youtube.com';

  @override
  String get highlightsSaveError => 'Não foi possível salvar os destaques';

  @override
  String get diaryEmptyOwn => 'Seus registros aparecem aqui.';

  @override
  String get diaryEmptyOther => 'Nenhum registro para mostrar.';

  @override
  String get editProfileSave => 'Salvar';

  @override
  String get editProfileSaveError => 'Não foi possível salvar o perfil';

  @override
  String get editProfileInvalidField =>
      'Confira os campos: algum link ou imagem pode estar inválido';

  @override
  String get editProfileDisplayNameLabel => 'Nome';

  @override
  String get editProfileHandleLabel => '@ (nome de usuário)';

  @override
  String get editProfileHandleHint => '5 a 30 letras, números, . ou _';

  @override
  String get editProfileHandleChecking => 'Verificando…';

  @override
  String get editProfileHandleAvailable => 'Disponível';

  @override
  String get editProfileHandleTaken => 'Este @ já está em uso';

  @override
  String get editProfileHandleInvalid =>
      'Use de 5 a 30 letras minúsculas, números, pontos ou _';

  @override
  String get editProfilePronounsLabel => 'Pronomes';

  @override
  String get editProfilePronounsPlaceholder => 'ex.: ela/dela';

  @override
  String get editProfileLinksLabel => 'Links';

  @override
  String get editProfileAddLink => 'Adicionar link';

  @override
  String get editProfileAccentLabel => 'Cor de destaque';

  @override
  String get editProfileAccentDefault => 'Padrão';

  @override
  String get editProfileImagesLabel => 'Foto e banner';

  @override
  String get editProfileImagesHint =>
      'Cole o link de uma imagem. O envio de arquivos vem depois.';

  @override
  String get editProfileAvatarUrlLabel => 'Link da foto';

  @override
  String get editProfileBannerUrlLabel => 'Link do banner';

  @override
  String get discoverReleases => 'Em cartaz e lançamentos';

  @override
  String get discoverShelves => 'Estantes mais populares';

  @override
  String get discoverLocadoras => 'Locadoras da comunidade';

  @override
  String get discoverProfiles => 'Cinéfilos para seguir';

  @override
  String get discoverExplore => 'Explorar o catálogo';

  @override
  String get discoverEmpty => 'Nada por aqui ainda.';

  @override
  String get discoverFeatured => 'Em destaque';

  @override
  String get searchTabMovies => 'Filmes';

  @override
  String get newsAllSources => 'Todas';

  @override
  String get newsRead => 'Lido';

  @override
  String get newsMoviesTitle => 'Filmes citados';

  @override
  String get newsWantToWatch => 'Quero ver';

  @override
  String get newsInWantToWatch => 'No Quero ver';

  @override
  String get newsWatched => 'Já assisti';

  @override
  String get newsAddToShelf => 'Adicionar à estante';

  @override
  String newsAddedToWatchlist(String title) {
    return '$title está no Quero ver';
  }

  @override
  String get newsWantToWatchError => 'Não foi possível adicionar o filme';

  @override
  String get personDirected => 'Direção';

  @override
  String get personActed => 'Atuação';

  @override
  String get personNoCredits => 'Nenhum filme do catálogo ainda.';

  @override
  String get attsScopeAll => 'Todos';

  @override
  String get attsScopeFollowing => 'Seguindo';

  @override
  String get attsScopeMe => 'Só eu';

  @override
  String get attsEmptyTitle => 'Nada por aqui ainda';

  @override
  String get attsEmptyFollowing => 'Siga pessoas para ver o que elas assistem.';

  @override
  String get attsEmptyMe => 'O que você registra, avalia e cria aparece aqui.';

  @override
  String attsWhispersUnread(int count) {
    return 'Sussurros, $count não lidos';
  }

  @override
  String get attsFollowsAction => 'Seguindo e seguidores';

  @override
  String get activityVerbSession => 'registrou uma sessão de';

  @override
  String get activityVerbFinished => 'assistiu';

  @override
  String get activityVerbRewatched => 'reassistiu';

  @override
  String get activityVerbRating => 'avaliou';

  @override
  String get activityVerbNewShelf => 'criou a estante';

  @override
  String get activityVerbFeaturedShelf => 'destacou a estante';

  @override
  String get activityVerbNewLocadora => 'abriu a locadora';

  @override
  String get activityVerbWatchingNow => 'está assistindo';

  @override
  String activityVerbImported(String source) {
    return 'importou os filmes do $source';
  }

  @override
  String get activityVerbOther => 'fez algo novo';

  @override
  String activityImportCounts(int watched, int watchlist) {
    return '$watched assistidos · $watchlist para ver';
  }

  @override
  String get activityLove => 'Amei';

  @override
  String get activityUnlove => 'Desfazer amei';

  @override
  String activityLovesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amei',
      one: '1 amei',
      zero: '0 amei',
    );
    return '$_temp0';
  }

  @override
  String get activityMoreOptions => 'Mais opções';

  @override
  String get activityHide => 'Ocultar dos outros';

  @override
  String get activityShow => 'Mostrar de novo';

  @override
  String get activityHidden => 'Oculta';

  @override
  String get activityHiddenSnack => 'Agora só você vê';

  @override
  String get timeNow => 'agora';

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
  String get followBackLabel => 'Seguir de volta';

  @override
  String get followRateLimited =>
      'Muitos follows seguidos. Tente de novo em um minuto.';

  @override
  String get followError => 'Não deu para atualizar o follow';

  @override
  String get followsEmptyFollowers => 'Ainda sem seguidores.';

  @override
  String get followsEmptyFollowing => 'Ainda não segue ninguém.';

  @override
  String get whispersEmptyTitle => 'Nenhum sussurro ainda';

  @override
  String get whispersEmptyMessage =>
      'Mande um sussurro pelo perfil de quem segue você de volta.';

  @override
  String get whisperAction => 'Sussurrar';

  @override
  String get whisperHint => 'Escreva um sussurro';

  @override
  String get whisperSend => 'Enviar';

  @override
  String get whisperDisabled =>
      'Vocês só trocam sussurros enquanto um segue o outro.';

  @override
  String get whisperMutualLost =>
      'Vocês não se seguem mais. Esta conversa ficou só para leitura.';

  @override
  String get whisperMutualRestored => 'Vocês voltaram a se seguir.';

  @override
  String get whisperSendError => 'Não deu para enviar. Tente de novo.';

  @override
  String get whisperRateLimited => 'Calma: muitos sussurros em um minuto.';

  @override
  String whisperYou(String body) {
    return 'Você: $body';
  }

  @override
  String whisperStart(String name) {
    return 'Diga oi para $name';
  }

  @override
  String whisperUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count não lidas',
      one: '1 não lida',
      zero: '0 não lidas',
    );
    return '$_temp0';
  }

  @override
  String get movieFollowingActivity => 'De quem você segue';

  @override
  String get maratonaSearchHint => 'Buscar maratonas';

  @override
  String get maratonaFilterCurated => 'Curadoria';

  @override
  String get maratonaFilterOpen => 'Sem senha';

  @override
  String get maratonaFilterFinished => 'Incluir finalizadas';

  @override
  String get maratonaFilterMine => 'Criadas por mim';

  @override
  String get maratonaCreate => 'Criar maratona';

  @override
  String get maratonaListEmptyTitle => 'Nenhuma maratona por aqui';

  @override
  String get maratonaListEmptyMessage => 'Crie uma ou mude os filtros.';

  @override
  String get maratonaParticipatingEmpty =>
      'Você ainda não entrou em nenhuma maratona.';

  @override
  String get maratonaStatusUpcoming => 'Em breve';

  @override
  String get maratonaStatusActive => 'Acontecendo';

  @override
  String get maratonaStatusFinished => 'Finalizada';

  @override
  String get maratonaStatusCancelled => 'Cancelada';

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
      zero: '0 participantes',
    );
    return '$_temp0';
  }

  @override
  String maratonaChallengesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count desafios',
      one: '1 desafio',
      zero: '0 desafios',
    );
    return '$_temp0';
  }

  @override
  String get maratonaJoined => 'Participando';

  @override
  String get maratonaLocked => 'Com senha';

  @override
  String get maratonaTabAbout => 'Sobre';

  @override
  String get maratonaTabChallenges => 'Desafios';

  @override
  String get maratonaTabQueue => 'Minha Fila';

  @override
  String get maratonaTabDiscovery => 'Descoberta';

  @override
  String get maratonaTabRanking => 'Ranking';

  @override
  String get maratonaJoin => 'Participar';

  @override
  String get maratonaLeave => 'Sair';

  @override
  String get maratonaLeaveTitle => 'Sair da maratona?';

  @override
  String get maratonaLeaveMessage =>
      'Sua Fila e os desafios marcados serão removidos.';

  @override
  String get maratonaJoinTitle => 'Participar da maratona';

  @override
  String get maratonaJoinLevel => 'Nível';

  @override
  String get maratonaJoinTeam => 'Equipe';

  @override
  String get maratonaNoTeam => 'Sem equipe';

  @override
  String get maratonaPassword => 'Senha';

  @override
  String get maratonaWrongPassword => 'Senha errada.';

  @override
  String get maratonaClosed => 'Esta maratona não está aberta.';

  @override
  String get maratonaActionError => 'Não deu certo. Tente de novo.';

  @override
  String maratonaOwnerBy(String name) {
    return 'Por $name';
  }

  @override
  String get maratonaCoOwners => 'Co-responsáveis';

  @override
  String get maratonaLevels => 'Níveis';

  @override
  String get maratonaTeams => 'Equipes';

  @override
  String get maratonaPrizes => 'Prêmios';

  @override
  String get maratonaProgressFeed => 'Atividade';

  @override
  String get maratonaProgressEmpty => 'Nada aconteceu ainda.';

  @override
  String maratonaMyProgress(int done, int total) {
    return '$done de $total desafios';
  }

  @override
  String get maratonaSocialLink => 'Comunidade';

  @override
  String get maratonaEdit => 'Editar';

  @override
  String get maratonaCancel => 'Cancelar maratona';

  @override
  String get maratonaCancelMessage =>
      'Ninguém mais poderá entrar ou marcar desafios. Não dá para desfazer.';

  @override
  String get maratonaCancelConfirm => 'Cancelar maratona';

  @override
  String get maratonaKeep => 'Manter';

  @override
  String get maratonaChallengeAuto => 'Conclui sozinho';

  @override
  String get maratonaChallengeManual => 'Marcado à mão';

  @override
  String get maratonaChallengeDaily => 'Diário';

  @override
  String get maratonaTeamOnly => 'Desafios de equipe';

  @override
  String get maratonaChallengeDone => 'Concluído';

  @override
  String get maratonaChallengeOpen => 'A fazer';

  @override
  String get maratonaLinkMovie => 'Marcar com um filme';

  @override
  String get maratonaLinkFromQueue => 'Da sua Fila';

  @override
  String get maratonaLinkFromWatched => 'Do Já assisti';

  @override
  String get maratonaUnlink => 'Remover';

  @override
  String get maratonaLinkAuto => 'por um registro';

  @override
  String get maratonaLinksEmpty => 'Nenhum filme ainda.';

  @override
  String get maratonaNotRunning =>
      'Dá para marcar desafios enquanto a maratona acontece.';

  @override
  String get maratonaJoinToMark => 'Participe para marcar desafios.';

  @override
  String get maratonaPickerEmpty => 'Nenhum filme aqui.';

  @override
  String get maratonaQueueEmpty =>
      'Sua Fila está vazia. Adicione filmes pela Descoberta.';

  @override
  String get maratonaQueueOpen => 'Abrir estante';

  @override
  String get maratonaQueueJoin => 'Participe para ganhar uma Fila.';

  @override
  String get maratonaAddToQueue => 'Adicionar à Fila';

  @override
  String get maratonaAddedToQueue => 'Adicionado à Fila';

  @override
  String get maratonaDiscoveryPick => 'Escolha um desafio';

  @override
  String get maratonaDiscoveryNone =>
      'Nenhum desafio desta maratona tem critério para sugerir filmes.';

  @override
  String get maratonaRankingUsers => 'Participantes';

  @override
  String get maratonaRankingEmpty => 'Ninguém concluiu um desafio ainda.';

  @override
  String maratonaRankingPosition(int position) {
    return '$positionº';
  }

  @override
  String maratonaTeamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
      zero: '0 membros',
    );
    return '$_temp0';
  }

  @override
  String get maratonaEditorNewTitle => 'Nova maratona';

  @override
  String get maratonaEditorEditTitle => 'Editar maratona';

  @override
  String get maratonaEditorFromScratch => 'Começar do zero';

  @override
  String get maratonaEditorTemplates => 'Ou comece por um modelo';

  @override
  String maratonaTemplateDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
      zero: '0 dias',
    );
    return '$_temp0';
  }

  @override
  String get maratonaStepDetails => 'Dados';

  @override
  String get maratonaStepLevels => 'Níveis e equipes';

  @override
  String get maratonaStepPrizes => 'Prêmios e privacidade';

  @override
  String get maratonaFieldTitle => 'Título';

  @override
  String get maratonaFieldSlug => 'Endereço';

  @override
  String maratonaSlugHelp(String slug) {
    return 'Letras, números e hífens: /m/$slug';
  }

  @override
  String get maratonaSlugTaken => 'Este endereço já existe.';

  @override
  String get maratonaSlugInvalid =>
      'Use de 3 a 50 letras minúsculas, números ou hífens.';

  @override
  String get maratonaSlugAvailable => 'Disponível';

  @override
  String get maratonaFieldDescription => 'Descrição';

  @override
  String get maratonaFieldStart => 'Começa em';

  @override
  String get maratonaFieldEnd => 'Termina em';

  @override
  String get maratonaFieldColor => 'Cor';

  @override
  String get maratonaFieldLogo => 'Logo (link da imagem)';

  @override
  String get maratonaFieldSocial => 'Link da comunidade';

  @override
  String get maratonaAddCategory => 'Adicionar categoria';

  @override
  String get maratonaCategoryName => 'Nome da categoria';

  @override
  String get maratonaAddChallenge => 'Adicionar desafio';

  @override
  String get maratonaChallengeDescription => 'Desafio';

  @override
  String get maratonaCriteria => 'Critério automático';

  @override
  String get maratonaCriteriaNone => 'Sem critério: marcado à mão';

  @override
  String get maratonaCriteriaGenres => 'Gêneros';

  @override
  String get maratonaCriteriaDecades => 'Décadas';

  @override
  String get maratonaCriteriaCountries => 'Países';

  @override
  String get maratonaCriteriaLanguages => 'Idioma original';

  @override
  String get maratonaCriteriaRuntimeMin => 'Pelo menos (minutos)';

  @override
  String get maratonaCriteriaRuntimeMax => 'No máximo (minutos)';

  @override
  String get maratonaCriteriaVote => 'Nota mínima no TMDB';

  @override
  String get maratonaCriteriaCodesHint =>
      'Códigos separados por vírgula, como BR, FR';

  @override
  String get maratonaCriteriaKept =>
      'Os outros critérios deste desafio são mantidos.';

  @override
  String get maratonaCriteriaApply => 'Aplicar';

  @override
  String get maratonaCriteriaClear => 'Limpar critério';

  @override
  String get maratonaMinChallenges => 'Desafios para concluir';

  @override
  String get maratonaAddLevel => 'Adicionar nível';

  @override
  String get maratonaLevelName => 'Nome do nível';

  @override
  String get maratonaDefaultLevel =>
      'Sem níveis, concluir todos os desafios completa a maratona.';

  @override
  String get maratonaAddTeam => 'Adicionar equipe';

  @override
  String get maratonaTeamName => 'Nome da equipe';

  @override
  String get maratonaAddPrize => 'Adicionar prêmio';

  @override
  String get maratonaPrizeTitle => 'Prêmio';

  @override
  String get maratonaFieldPassword => 'Senha para entrar (opcional)';

  @override
  String get maratonaKeepPassword => 'Deixe vazio para manter a senha atual.';

  @override
  String get maratonaRemovePassword => 'Remover senha';

  @override
  String get maratonaSave => 'Salvar';

  @override
  String get maratonaNext => 'Próximo';

  @override
  String get maratonaBack => 'Voltar';

  @override
  String get maratonaRemove => 'Remover';

  @override
  String maratonaMinChallengesError(int min) {
    return 'Adicione pelo menos $min desafios.';
  }

  @override
  String get maratonaRequired => 'Obrigatório';

  @override
  String get maratonaPeriodError =>
      'O fim precisa ser no início ou depois dele.';

  @override
  String get maratonaStartedNote =>
      'A maratona começou: só textos, cor, logo, link e prêmios podem mudar.';

  @override
  String get maratonaSaveError =>
      'Não deu para salvar. Confira os campos e tente de novo.';

  @override
  String get activityVerbCreatedMaratona => 'criou a maratona';

  @override
  String get activityVerbJoinedMaratona => 'entrou na maratona';

  @override
  String get activityVerbFinishedChallenge => 'concluiu um desafio em';

  @override
  String get activityVerbFinishedMaratona => 'concluiu a maratona';

  @override
  String activityMaratonaLevel(String level, int done, int total) {
    return 'Nível $level · $done de $total desafios';
  }

  @override
  String get maratonaLoadMore => 'Carregar mais';

  @override
  String get activityVerbCreatedCineClube => 'criou o CineClube';

  @override
  String get activityVerbJoinedCineClube => 'entrou no CineClube';

  @override
  String get cineclubeAddSession => 'Adicionar filme';

  @override
  String get cineclubeCancel => 'Cancelar CineClube';

  @override
  String get cineclubeCancelMessage =>
      'Ninguém mais vai poder entrar nem mudar nada.';

  @override
  String get cineclubeClosed => 'Este CineClube não está aberto.';

  @override
  String cineclubeCompletedSessions(int done, int total) {
    return '$done de $total filmes';
  }

  @override
  String get cineclubeCreate => 'Criar CineClube';

  @override
  String get cineclubeCurrentSession => 'Em cartaz';

  @override
  String get cineclubeCycle => 'Ciclo';

  @override
  String get cineclubeCycleHelp =>
      'Com mais de um filme ele vira um ciclo: um filme depois do outro, cada um com seu período e seu dia de debate.';

  @override
  String get cineclubeDebateLink => 'Link do debate (chamada ou chat)';

  @override
  String cineclubeDebateOn(String date) {
    return 'Debate em $date';
  }

  @override
  String get cineclubeEditorEditTitle => 'Editar CineClube';

  @override
  String get cineclubeEditorNewTitle => 'Novo CineClube';

  @override
  String get cineclubeFieldDebate => 'Dia do debate';

  @override
  String get cineclubeFilterAll => 'Todos';

  @override
  String get cineclubeFutureSessionError =>
      'Filmes novos ou alterados têm que começar depois de hoje.';

  @override
  String get cineclubeGif => 'GIF';

  @override
  String get cineclubeJoin => 'Entrar no CineClube';

  @override
  String get cineclubeJoined => 'Você entrou. O filme está no seu Quero ver.';

  @override
  String get cineclubeLeaveMessage => 'O filme continua no seu Quero ver.';

  @override
  String get cineclubeLeaveTitle => 'Sair do CineClube?';

  @override
  String get cineclubeListEmptyMessage =>
      'Crie um e chame a galera para assistir um filme junto.';

  @override
  String get cineclubeListEmptyTitle => 'Nenhum CineClube por aqui';

  @override
  String get cineclubeMovieAndDates => 'Filme e datas';

  @override
  String get cineclubeMovieRequired => 'Escolha o filme de cada sessão.';

  @override
  String get cineclubeOverlapError =>
      'Os filmes de um ciclo não podem se sobrepor.';

  @override
  String get cineclubeParticipantsEmpty => 'Ninguém por aqui ainda';

  @override
  String get cineclubeParticipatingEmpty =>
      'Você ainda não entrou em nenhum CineClube.';

  @override
  String get cineclubePickMovie => 'Escolher filme';

  @override
  String get cineclubeProgressCompleted => 'Assistiu';

  @override
  String get cineclubeProgressEmptyMessage =>
      'As sessões que os participantes registrarem no período aparecem aqui.';

  @override
  String get cineclubeProgressEmptyTitle => 'Nenhuma sessão ainda';

  @override
  String get cineclubeProgressPending => 'Não começou';

  @override
  String get cineclubeProgressWatching => 'Assistindo';

  @override
  String cineclubeRuntime(int minutes) {
    return '$minutes min';
  }

  @override
  String get cineclubeSave => 'Salvar';

  @override
  String get cineclubeSearchHint => 'Buscar CineClubes';

  @override
  String get cineclubeSearchMovie => 'Buscar um filme';

  @override
  String cineclubeSessionLabel(int number, String title) {
    return '$number. $title';
  }

  @override
  String cineclubeSessionNumber(int number) {
    return 'Filme $number';
  }

  @override
  String get cineclubeSessionStarted => 'Já começou';

  @override
  String get cineclubeSessions => 'Filmes do ciclo';

  @override
  String cineclubeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filmes',
      one: '1 filme',
      zero: '0 filmes',
    );
    return '$_temp0';
  }

  @override
  String cineclubeSlugHelp(String slug) {
    return 'muuvie.app/c/$slug';
  }

  @override
  String get cineclubeSpoilerHidden =>
      'Comentário escondido até você terminar o filme ou chegar o dia do debate.';

  @override
  String get cineclubeSpoilerNote =>
      'Os comentários ficam escondidos até você assistir, ou até o debate.';

  @override
  String get cineclubeTabParticipants => 'Participantes';

  @override
  String get cineclubeTabProgress => 'Progresso';

  @override
  String cineclubeWatchedMinutes(int minutes) {
    return '$minutes min assistidos';
  }

  @override
  String cineclubeWatchedPercent(int percent) {
    return '$percent% assistido';
  }

  @override
  String get cineclubeWhereToWatch => 'Onde assistir';

  @override
  String get chartsGoalTitle => 'Meta de filmes do ano';

  @override
  String get chartsGoalSave => 'Salvar meta';

  @override
  String get chartsGoalInvalid => 'Digite um número entre 1 e 5000.';

  @override
  String chartsGoalPrompt(String year) {
    return 'Defina quantos filmes você quer assistir em $year.';
  }

  @override
  String get chartsGoalSet => 'Definir meta';

  @override
  String chartsGoalProgress(int watched, int target, String year) {
    return '$watched de $target filmes em $year';
  }

  @override
  String get chartsGoalReached => 'Meta batida!';

  @override
  String get chartsEmptyTitle => 'Nenhuma sessão neste ano';

  @override
  String get chartsEmptyMessage =>
      'As sessões registradas no ano aparecem aqui em gráficos.';

  @override
  String chartsOpenRetrospective(String year) {
    return 'Ver a retrospectiva de $year';
  }

  @override
  String get chartsMovies => 'filmes';

  @override
  String get chartsHours => 'horas na frente da tela';

  @override
  String get chartsSessions => 'sessões';

  @override
  String get chartsRewatches => 'revistos';

  @override
  String get chartsMonths => 'Filmes por mês';

  @override
  String get chartsGenres => 'Gêneros';

  @override
  String get chartsOthers => 'Outros';

  @override
  String get chartsDecades => 'Décadas';

  @override
  String chartsDecade(String decade) {
    return 'Anos $decade';
  }

  @override
  String get chartsCountries => 'Países';

  @override
  String get chartsLanguages => 'Idiomas';

  @override
  String get chartsVenues => 'Onde você assistiu';

  @override
  String get chartsDirectors => 'Diretores';

  @override
  String get chartsEmotions => 'Emoções';

  @override
  String get chartsRatings => 'Avaliações';

  @override
  String get chartsCalendar => 'Calendário';

  @override
  String chartsCalendarSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sessões em $count dias',
      one: 'Sessões em 1 dia',
      zero: 'Sessões em 0 dias',
    );
    return '$_temp0';
  }

  @override
  String get retrospectiveShare => 'Compartilhar este story';

  @override
  String retrospectiveShareText(String year) {
    return 'Meu $year em filmes no Muuvie';
  }

  @override
  String get retrospectiveEmpty => 'Nenhum filme concluído neste ano ainda';

  @override
  String get retrospectiveIntro => 'Seu ano no cinema';

  @override
  String retrospectiveMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'filmes',
      one: 'filme',
      zero: 'filmes',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'horas na frente da tela',
      one: 'hora na frente da tela',
      zero: 'horas na frente da tela',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveRewatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'E $count filmes revistos',
      one: 'E 1 filme revisto',
      zero: 'E 0 filmes revistos',
    );
    return '$_temp0';
  }

  @override
  String get retrospectiveTopGenres => 'Seus gêneros';

  @override
  String get retrospectiveTopDirectors => 'Quem você mais assistiu na direção';

  @override
  String get retrospectiveTopActors => 'Rostos que você mais viu';

  @override
  String get retrospectiveEmotion => 'A emoção do seu ano';

  @override
  String get retrospectiveFavorite => 'Seu filme favorito';

  @override
  String get retrospectiveBestMonth => 'Seu mês mais cinéfilo';

  @override
  String retrospectiveMaratonas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maratonas concluídas',
      one: '1 maratona concluída',
      zero: '0 maratonas concluídas',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveCineclubes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count CineClubes',
      one: '1 CineClube',
      zero: '0 CineClubes',
    );
    return '$_temp0';
  }

  @override
  String retrospectiveGoalReached(int target) {
    return 'Meta de $target filmes batida!';
  }

  @override
  String retrospectiveGoalProgress(int watched, int target) {
    return '$watched dos $target filmes da sua meta';
  }

  @override
  String get retrospectiveOutro => 'Até a próxima sessão';

  @override
  String get activityVerbUnlockedBichinho => 'desbloqueou a vaquinha';

  @override
  String get petShelterTitle => 'Vaquinha da Bombonière';

  @override
  String get petAdopt => 'Adotar uma vaquinha';

  @override
  String get petStarterTitle => 'Escolha seu balde de pipoca';

  @override
  String get petStarterMessage =>
      'Sua vaquinha cresce com os minutos que você assiste e as sessões que registra. A primeira escolha é para sempre.';

  @override
  String petStarterConfirmTitle(String name) {
    return 'Adotar $name?';
  }

  @override
  String get petStarterConfirmMessage =>
      'A primeira vaquinha não pode ser trocada depois. Os outros você desbloqueia assistindo.';

  @override
  String get petStarterConfirm => 'Adotar';

  @override
  String petLevel(int level) {
    return 'Nível $level';
  }

  @override
  String petXp(int xp, int next) {
    return '$xp de $next XP';
  }

  @override
  String get petXpHelp =>
      'Cada filme concluído dá 20 XP, mais 1 a cada 10 minutos. Importações não contam.';

  @override
  String petUnlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vaquinhas',
      one: '1 vaquinha',
      zero: '0 vaquinhas',
    );
    return '$_temp0';
  }

  @override
  String get petLocked => 'Para desbloquear';

  @override
  String get petPin => 'Mostrar no meu perfil';

  @override
  String get petRarityStarter => 'Inicial';

  @override
  String get petRarityCommon => 'Comum';

  @override
  String get petRarityRare => 'Raro';

  @override
  String get petRarityLegendary => 'Lendário';

  @override
  String get petPipocaDoce => 'Pipoca doce';

  @override
  String get petPipocaSalgada => 'Pipoca salgada';

  @override
  String get petPipocaCaramelo => 'Pipoca de caramelo';

  @override
  String get petPipocaDoceAbout => 'Adora romance e animação.';

  @override
  String get petPipocaSalgadaAbout => 'Não perde um suspense.';

  @override
  String get petPipocaCarameloAbout => 'Coleciona clássicos.';

  @override
  String get petClaquete => 'Claquete';

  @override
  String get petIngresso => 'Ingresso';

  @override
  String get petFantasminha => 'Fantasminha';

  @override
  String get petRobozinho => 'Robozinho';

  @override
  String get petLanterninha => 'Lanterninha';

  @override
  String get petRoloDeFilme => 'Rolo de filme';

  @override
  String get petDinossauro => 'Dinossauro';

  @override
  String get petCoruja => 'Coruja';

  @override
  String get petTrofeu => 'Troféu';

  @override
  String get petProjetor => 'Projetor';

  @override
  String get petEstatueta => 'Estatueta';

  @override
  String get petRuleStarter => 'Pacote inicial';

  @override
  String petRuleMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Assista $count filmes',
      one: 'Assista 1 filme',
      zero: 'Assista 0 filmes',
    );
    return '$_temp0';
  }

  @override
  String petRuleMinutes(int count) {
    return 'Assista $count minutos';
  }

  @override
  String petRuleHorror(int count) {
    return 'Assista $count filmes de terror';
  }

  @override
  String petRuleSciFi(int count) {
    return 'Assista $count filmes de ficção científica';
  }

  @override
  String petRuleOldMovies(int count, String year) {
    return 'Assista $count filmes de antes de $year';
  }

  @override
  String petRuleMaratonas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Conclua $count maratonas',
      one: 'Conclua uma maratona',
      zero: 'Conclua 0 maratonas',
    );
    return '$_temp0';
  }

  @override
  String petRuleCineclubes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entre em $count CineClubes',
      one: 'Entre em um CineClube',
      zero: 'Entre em 0 CineClubes',
    );
    return '$_temp0';
  }

  @override
  String petRuleMissions(int count) {
    return 'Cumpra $count missões';
  }

  @override
  String get missionsTitle => 'Missões';

  @override
  String missionsWeek(String start, String end) {
    return 'Semana de $start a $end';
  }

  @override
  String get missionsHelp =>
      'Três missões novas toda segunda. O XP vai para a sua vaquinha em destaque.';

  @override
  String missionXp(int xp) {
    return '+$xp XP';
  }

  @override
  String get missionDone => 'Cumprida!';

  @override
  String missionSessions(int count) {
    return 'Registre $count sessões';
  }

  @override
  String missionMovies(int count) {
    return 'Conclua $count filmes';
  }

  @override
  String missionEmotions(int count) {
    return 'Registre $count sessões com emoções';
  }

  @override
  String get missionLongMovie => 'Assista um filme de 2h30 ou mais';

  @override
  String get missionClassic => 'Assista um filme de antes de 1970';

  @override
  String get missionDocumentary => 'Assista um documentário';

  @override
  String get missionHorror => 'Assista um filme de terror';

  @override
  String get missionAnimation => 'Assista uma animação';

  @override
  String get missionAsia => 'Assista um filme da Ásia';

  @override
  String get missionAfrica => 'Assista um filme da África';

  @override
  String get missionBrazil => 'Assista um filme brasileiro';

  @override
  String get missionCineclube => 'Entre em um CineClube';

  @override
  String get missionChallenge => 'Conclua um desafio de maratona';

  @override
  String get diaryTitle => 'Caderninho';

  @override
  String get diaryToday => 'Hoje';

  @override
  String get diaryPreviousDay => 'Dia anterior';

  @override
  String get diaryNextDay => 'Próximo dia';

  @override
  String get diaryMood => 'Como foi o seu dia?';

  @override
  String diaryGoals(int count, int max) {
    return 'Metas ($count de $max)';
  }

  @override
  String get diaryAddGoal => 'Adicionar meta';

  @override
  String get diaryAdd => 'Adicionar';

  @override
  String get diaryGoalHint => 'Ver Rashomon';

  @override
  String get diaryNoGoals => 'Nenhuma meta para este dia.';

  @override
  String get diaryReorder => 'Reordenar';

  @override
  String get diaryNote => 'Desabafo';

  @override
  String get diaryNoteHint => 'Escreva o que quiser sobre hoje';

  @override
  String get diaryPrivate => 'Só você vê o seu Caderninho.';

  @override
  String get diarySaved => 'Dia salvo';

  @override
  String get diaryDiscardTitle => 'Sair sem salvar?';

  @override
  String get diaryDiscardMessage => 'As mudanças deste dia vão se perder.';

  @override
  String get diaryDiscard => 'Sair';

  @override
  String get diaryYearTitle => 'Ano de humores';

  @override
  String diaryYearOf(String year) {
    return 'Seu $year em humores';
  }

  @override
  String diaryYearDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias escritos',
      one: '1 dia escrito',
      zero: '0 dias escritos',
    );
    return '$_temp0';
  }

  @override
  String diaryYearTop(String mood) {
    return 'mais que tudo: $mood';
  }

  @override
  String get diaryCategoryMovie => 'Filme';

  @override
  String get diaryCategoryShort => 'Curta';

  @override
  String get diaryCategorySeries => 'Série';

  @override
  String get diaryCategoryStudy => 'Estudo';

  @override
  String get diaryCategoryOther => 'Outros';

  @override
  String get moodGreat => 'Ótimo';

  @override
  String get moodGood => 'Bom';

  @override
  String get moodOkay => 'Mais ou menos';

  @override
  String get moodBad => 'Ruim';

  @override
  String get moodAwful => 'Péssimo';

  @override
  String get partyTitle => 'Sessão sincronizada';

  @override
  String get partyIntro =>
      'Dê play junto com seus amigos: crie uma sala, passe o código e comece a contagem regressiva.';

  @override
  String get partyCreate => 'Criar uma sala';

  @override
  String get partyFieldTitle => 'O que vocês vão assistir?';

  @override
  String get partyJoin => 'Entrar com um código';

  @override
  String get partyFieldCode => 'Código da sala';

  @override
  String get partyNotFound => 'Nenhuma sala com esse código.';

  @override
  String get partyFull => 'Esta sala está cheia.';

  @override
  String get partyClosed => 'A sala foi fechada';

  @override
  String partyCodeLabel(String code) {
    return 'Código da sala $code';
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
      other: '$count pessoas na sala',
      one: '1 pessoa na sala',
      zero: '0 pessoas na sala',
    );
    return '$_temp0';
  }

  @override
  String get partyWaiting => 'Esperando quem criou a sala começar a contagem';

  @override
  String get partyWaitingHost =>
      'Quando todo mundo estiver pronto, comece a contagem';

  @override
  String get partyStart => 'Começar a contagem';

  @override
  String get partyRestart => 'Recomeçar a contagem';

  @override
  String partyStartIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Em $seconds segundos',
      one: 'Em 1 segundo',
      zero: 'Em 0 segundos',
    );
    return '$_temp0';
  }

  @override
  String partySecondsLeft(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Faltam $seconds segundos',
      one: 'Falta 1 segundo',
      zero: 'Faltam 0 segundos',
    );
    return '$_temp0';
  }

  @override
  String get partyPlay => 'Play!';

  @override
  String get partyNoMessages => 'Nenhuma mensagem ainda';

  @override
  String get partyMessageHint => 'Diga alguma coisa';

  @override
  String get partySend => 'Enviar';

  @override
  String get posterGameTitle => 'Jogo do Pôster';

  @override
  String get posterGameHint => 'Um pôster de filme desfocado';

  @override
  String get posterGameQuestion => 'Que filme é esse?';

  @override
  String posterGameScore(int points) {
    return '$points pontos';
  }

  @override
  String posterGameStreak(int count) {
    return 'Sequência: $count';
  }

  @override
  String get posterGameRight => 'Acertou!';

  @override
  String posterGameWrong(String title) {
    return 'Era $title';
  }

  @override
  String get posterGameNext => 'Próximo pôster';

  @override
  String get onboardingWelcomeTitle => 'O Muuvie é uma maratona de filmes';

  @override
  String get onboardingWelcomeText =>
      'Guarde o que você assiste, encare desafios e assista junto com outros cinéfilos.';

  @override
  String get onboardingShelvesTitle => 'Estantes e locadoras';

  @override
  String get onboardingShelvesText =>
      'Já assisti e Quero ver estão sempre lá. Crie suas estantes e junte-as em locadoras.';

  @override
  String get onboardingLogsTitle => 'Registre cada sessão';

  @override
  String get onboardingLogsText =>
      'Estrelas, emoções, GIF e comentário para cada filme, escolhendo quem vê cada um.';

  @override
  String get onboardingProgramacaoTitle => 'Maratonas e CineClubes';

  @override
  String get onboardingProgramacaoText =>
      'Entre em maratonas com desafios que se completam sozinhos e em CineClubes com dia de debate e sem spoilers.';

  @override
  String get onboardingSocialTitle => 'Amigos e uma vaquinha';

  @override
  String get onboardingSocialText =>
      'Siga pessoas, mande Sussurros e crie uma vaquinha que cresce a cada filme.';

  @override
  String get onboardingImportTitle => 'Traga seu histórico';

  @override
  String get onboardingImportText =>
      'Importe do Filmow o que você assistiu, o que quer ver e suas listas. Nada do que você fez aqui é sobrescrito.';

  @override
  String get onboardingImportFilmow => 'Importar do Filmow';

  @override
  String get onboardingSuggestionsTitle => 'Em cartaz';

  @override
  String get onboardingSuggestionsText =>
      'Maratonas e CineClubes abertos para você entrar hoje.';

  @override
  String get onboardingSuggestionsEmpty =>
      'Nada aberto agora. Crie o primeiro na Programação!';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingStart => 'Começar';

  @override
  String onboardingStep(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get settingsImport => 'Importar filmes';

  @override
  String get settingsImportHint =>
      'Do Filmow, sem sobrescrever o que você fez aqui';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotifyMessages => 'Sussurros';

  @override
  String get settingsNotifyFollowers => 'Novos seguidores';

  @override
  String get settingsNotifyLoves => 'Amei nas minhas atividades';

  @override
  String get settingsNotifyMaratonas => 'Maratonas em que entrei';

  @override
  String get settingsNotifyCineclubes => 'Dia de debate dos meus CineClubes';

  @override
  String get settingsAbout => 'Muuvie';

  @override
  String get settingsShowIntro => 'Ver a introdução de novo';

  @override
  String get settingsLogout => 'Sair';

  @override
  String get settingsLogoutTitle => 'Sair do Muuvie?';

  @override
  String get movieDetailRecordsTab => 'Atividade';

  @override
  String get movieRecordsEmpty =>
      'Ninguém registrou este filme ainda. Seja a primeira pessoa!';

  @override
  String movieCommunityWatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas assistiram',
      one: '1 pessoa assistiu',
      zero: 'Ninguém assistiu ainda',
    );
    return '$_temp0';
  }

  @override
  String movieCommunityWantToWatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas querem ver',
      one: '1 pessoa quer ver',
      zero: 'Ninguém quer ver ainda',
    );
    return '$_temp0';
  }

  @override
  String get movieEventsTitle => 'Na Programação';

  @override
  String movieEventCountsFor(String challenges) {
    return 'Conta para: $challenges';
  }

  @override
  String get movieDetailWrittenBy => 'Roteiro de';

  @override
  String get movieDetailTrailer => 'Ver trailer';

  @override
  String get movieDetailCreateCineClube => 'Criar CineClube com este filme';

  @override
  String get movieDetailWatchParty => 'Sessão sincronizada';

  @override
  String get movieActivitiesRatings => 'Avaliações';

  @override
  String get movieActivitiesUpdates => 'Atualizações';

  @override
  String get movieActivitiesEverything => 'Tudo';

  @override
  String get movieActivitiesEveryone => 'Todos';

  @override
  String get movieActivitiesFollowing => 'Seguindo';

  @override
  String get movieActivitiesOnlyMe => 'Só eu';

  @override
  String get movieCommunityTitle => 'Comunidade';

  @override
  String movieCommunityShelves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Está em $count estantes',
      one: 'Está em 1 estante',
      zero: 'Não está em estantes',
    );
    return '$_temp0';
  }

  @override
  String get movieCommunityFeelings => 'Como as pessoas se sentiram';

  @override
  String get movieRecentRatings => 'Avaliações recentes';

  @override
  String get movieRecentRatingsAll => 'Ver todas';

  @override
  String get movieShelvesTitle => 'Estantes com este filme';

  @override
  String get movieShelvesEmpty =>
      'Nenhuma estante pública tem este filme ainda.';

  @override
  String movieShelvesBy(String name) {
    return 'de $name';
  }

  @override
  String get movieDetailReadMore => 'Ler mais';

  @override
  String get movieDetailReadLess => 'Ler menos';

  @override
  String get movieStatWatched => 'Assistiram';

  @override
  String get movieStatWantToWatch => 'Querem ver';

  @override
  String get movieStatShelves => 'Estantes';

  @override
  String movieEmotionsAll(int count) {
    return 'Ver todas ($count)';
  }

  @override
  String get movieTimelineTitle => 'Últimos 12 meses';

  @override
  String get movieTimelineSessions => 'Sessões';

  @override
  String movieTimelineMonth(String month, int sessions, int ratings) {
    return '$month: $sessions sessões, $ratings avaliações';
  }

  @override
  String get movieShelvesSection => 'Em estantes';

  @override
  String get movieMaratonasSection => 'Maratonas em que contou';

  @override
  String get cineclubeStatusFinished => 'Encerrado';

  @override
  String get movieCommunityEmpty => 'Ninguém interagiu com este filme ainda.';

  @override
  String get discoverTrending => 'Em alta no Muuvie';

  @override
  String get discoverMostLoved => 'Mais amados no Muuvie';

  @override
  String get discoverGenres => 'Gêneros';

  @override
  String get discoverSectionError => 'Não foi possível carregar esta seção';

  @override
  String get searchMinLetters => 'Digite pelo menos 3 letras';

  @override
  String get searchRecent => 'Buscas recentes';

  @override
  String get searchClearRecent => 'Limpar tudo';

  @override
  String get searchRemoveRecent => 'Remover';

  @override
  String get searchTabPeople => 'Pessoas';

  @override
  String shelfByOwner(String name) {
    return 'de $name';
  }

  @override
  String get shelfSavedLabel => 'Salva';

  @override
  String get shelfSaveError =>
      'Não foi possível atualizar as estantes salvas. Tente de novo.';

  @override
  String shelfOpenOwnerProfile(String name) {
    return 'Abrir o perfil de $name';
  }

  @override
  String get savedShelvesTitle => 'Estantes salvas';

  @override
  String get savedShelvesAction => 'Salvas';

  @override
  String get savedShelvesEmpty =>
      'As estantes que você salvar de outras pessoas aparecem aqui.';
}
