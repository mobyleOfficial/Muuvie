import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:gamification/gamification.dart';

/// How each bichinho looks: an emoji on its color. The art can come later;
/// the slug stays the same.
abstract final class PetArt {
  static const _emoji = {
    'pipoca-doce': '🍿',
    'pipoca-salgada': '🍿',
    'pipoca-caramelo': '🍿',
    'claquete': '🎬',
    'ingresso': '🎟️',
    'fantasminha': '👻',
    'robozinho': '🤖',
    'lanterninha': '🔦',
    'rolo-de-filme': '🎞️',
    'dinossauro': '🦖',
    'coruja': '🦉',
    'trofeu': '🏆',
    'projetor': '📽️',
    'estatueta': '🏅',
  };

  static const _color = {
    'pipoca-doce': Color(0xFFF8BBD0),
    'pipoca-salgada': Color(0xFFFFF59D),
    'pipoca-caramelo': Color(0xFFFFCC80),
  };

  static String emoji(String slug) => _emoji[slug] ?? '🍿';

  static Color color(String slug, PetRarity rarity) =>
      _color[slug] ??
      switch (rarity) {
        PetRarity.starter => const Color(0xFFFFF59D),
        PetRarity.common => const Color(0xFFB3E5FC),
        PetRarity.rare => const Color(0xFFD1C4E9),
        PetRarity.legendary => const Color(0xFFFFE082),
      };
}

/// The bichinho drawn on its round tag. Locked ones are dimmed.
class PetAvatar extends StatelessWidget {
  final Pet pet;
  final double size;

  const PetAvatar({super.key, required this.pet, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = PetArt.color(pet.slug, pet.rarity);

    return Semantics(
      label: petName(l10n, pet.slug),
      image: true,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: pet.unlocked || pet.rarity == PetRarity.starter ? 1 : 0.35,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: pet.pinned
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
            ),
            child: Text(
              pet.unlocked || pet.rarity == PetRarity.starter
                  ? PetArt.emoji(pet.slug)
                  : '🔒',
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

String petName(AppLocalizations? l10n, String slug) =>
    switch (slug) {
      'pipoca-doce' => l10n?.petPipocaDoce,
      'pipoca-salgada' => l10n?.petPipocaSalgada,
      'pipoca-caramelo' => l10n?.petPipocaCaramelo,
      'claquete' => l10n?.petClaquete,
      'ingresso' => l10n?.petIngresso,
      'fantasminha' => l10n?.petFantasminha,
      'robozinho' => l10n?.petRobozinho,
      'lanterninha' => l10n?.petLanterninha,
      'rolo-de-filme' => l10n?.petRoloDeFilme,
      'dinossauro' => l10n?.petDinossauro,
      'coruja' => l10n?.petCoruja,
      'trofeu' => l10n?.petTrofeu,
      'projetor' => l10n?.petProjetor,
      'estatueta' => l10n?.petEstatueta,
      _ => null,
    } ??
    slug;

/// A line about each starter, for the starter pack.
String petDescription(AppLocalizations? l10n, String slug) =>
    switch (slug) {
      'pipoca-doce' => l10n?.petPipocaDoceAbout,
      'pipoca-salgada' => l10n?.petPipocaSalgadaAbout,
      'pipoca-caramelo' => l10n?.petPipocaCarameloAbout,
      _ => null,
    } ??
    '';

String petRarity(AppLocalizations? l10n, PetRarity rarity) =>
    switch (rarity) {
      PetRarity.starter => l10n?.petRarityStarter,
      PetRarity.common => l10n?.petRarityCommon,
      PetRarity.rare => l10n?.petRarityRare,
      PetRarity.legendary => l10n?.petRarityLegendary,
    } ??
    '';

/// What unlocks a bichinho, in words.
String petRule(AppLocalizations? l10n, PetRule rule) =>
    switch (rule.type) {
      PetRuleType.starter => l10n?.petRuleStarter,
      PetRuleType.movies => l10n?.petRuleMovies(rule.target),
      PetRuleType.minutes => l10n?.petRuleMinutes(rule.target),
      PetRuleType.genreMovies => switch (rule.genreId) {
        27 => l10n?.petRuleHorror(rule.target),
        878 => l10n?.petRuleSciFi(rule.target),
        _ => l10n?.petRuleMovies(rule.target),
      },
      PetRuleType.oldMovies => l10n?.petRuleOldMovies(
        rule.target,
        '${rule.beforeYear ?? ''}',
      ),
      PetRuleType.maratonasFinished => l10n?.petRuleMaratonas(rule.target),
      PetRuleType.cineclubesJoined => l10n?.petRuleCineclubes(rule.target),
      PetRuleType.missions => l10n?.petRuleMissions(rule.target),
    } ??
    '';

/// The text of a weekly mission, by its slug.
String missionText(AppLocalizations? l10n, Mission mission) =>
    switch (mission.slug) {
      'three-sessions' => l10n?.missionSessions(mission.target),
      'two-movies' || 'five-movies' => l10n?.missionMovies(mission.target),
      'feelings' => l10n?.missionEmotions(mission.target),
      'long-movie' => l10n?.missionLongMovie,
      'classic' => l10n?.missionClassic,
      'documentary' => l10n?.missionDocumentary,
      'horror' => l10n?.missionHorror,
      'animation' => l10n?.missionAnimation,
      'asia' => l10n?.missionAsia,
      'africa' => l10n?.missionAfrica,
      'brazil' => l10n?.missionBrazil,
      'cineclube' => l10n?.missionCineclube,
      'challenge' => l10n?.missionChallenge,
      _ => null,
    } ??
    mission.slug;

extension DiaryMoodLabel on DiaryMood {
  String get emoji => switch (this) {
    DiaryMood.great => '😄',
    DiaryMood.good => '🙂',
    DiaryMood.okay => '😐',
    DiaryMood.bad => '🙁',
    DiaryMood.awful => '😣',
  };

  String label(AppLocalizations? l10n) =>
      switch (this) {
        DiaryMood.great => l10n?.moodGreat,
        DiaryMood.good => l10n?.moodGood,
        DiaryMood.okay => l10n?.moodOkay,
        DiaryMood.bad => l10n?.moodBad,
        DiaryMood.awful => l10n?.moodAwful,
      } ??
      '';
}

extension DiaryCategoryLabel on DiaryCategory {
  String label(AppLocalizations? l10n) =>
      switch (this) {
        DiaryCategory.movie => l10n?.diaryCategoryMovie,
        DiaryCategory.short => l10n?.diaryCategoryShort,
        DiaryCategory.series => l10n?.diaryCategorySeries,
        DiaryCategory.study => l10n?.diaryCategoryStudy,
        DiaryCategory.other => l10n?.diaryCategoryOther,
      } ??
      '';

  IconData get icon => switch (this) {
    DiaryCategory.movie => Icons.movie_outlined,
    DiaryCategory.short => Icons.timer_outlined,
    DiaryCategory.series => Icons.tv_outlined,
    DiaryCategory.study => Icons.menu_book_outlined,
    DiaryCategory.other => Icons.star_outline,
  };
}
