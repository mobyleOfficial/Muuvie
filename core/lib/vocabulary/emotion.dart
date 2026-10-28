/// Emotions a user can attach to a watch session (up to [maxPerLog]).
///
/// [id] matches the backend and is persisted; never change or reuse one.
/// Labels are nouns so they stay gender-neutral.
enum Emotion {
  curiosity(0, 'curiosity'),
  inspiration(1, 'inspiration'),
  reflection(2, 'reflection'),
  relaxation(3, 'relaxation'),
  moved(4, 'moved'),
  nostalgia(5, 'nostalgia'),
  gratitude(6, 'gratitude'),
  affection(7, 'affection'),
  surprise(8, 'surprise'),
  passion(9, 'passion'),
  fun(10, 'fun'),
  joy(11, 'joy'),
  humor(12, 'humor'),
  freakOut(13, 'freak_out'),
  anxiety(14, 'anxiety'),
  distress(15, 'distress'),
  tension(16, 'tension'),
  distraction(17, 'distraction'),
  confusion(18, 'confusion'),
  suspicion(19, 'suspicion'),
  irritation(20, 'irritation'),
  anger(21, 'anger'),
  indignation(22, 'indignation'),
  fear(23, 'fear'),
  vulnerability(24, 'vulnerability'),
  embarrassment(25, 'embarrassment'),
  frustration(26, 'frustration'),
  sadness(27, 'sadness'),
  melancholy(28, 'melancholy'),
  tiredness(29, 'tiredness'),
  boredom(30, 'boredom'),
  connection(31, 'connection'),
  focus(32, 'focus'),
  intensity(33, 'intensity'),
  enthusiasm(34, 'enthusiasm'),
  excitement(35, 'excitement'),
  euphoria(36, 'euphoria'),
  shock(37, 'shock'),
  horror(38, 'horror'),
  disgust(39, 'disgust'),
  devastation(40, 'devastation'),
  grudge(41, 'grudge'),
  indifference(42, 'indifference'),
  apathy(43, 'apathy');

  final int id;
  final String wireValue;

  const Emotion(this.id, this.wireValue);

  static const int maxPerLog = 6;

  static Emotion? fromId(int? id) =>
      values.where((emotion) => emotion.id == id).firstOrNull;

  static Emotion? fromWireValue(String? value) =>
      values.where((emotion) => emotion.wireValue == value).firstOrNull;
}
