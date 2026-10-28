/// The single rating of a movie (phase 13): a label picked by hand, never a number.
///
/// The declaration order is the order of the picker and of "sort by rating".
enum Rating {
  /// "Favoritado": replaces the old heart.
  favorite('favorite'),

  /// "Adorei"
  loved('loved'),

  /// "Gostei"
  liked('liked'),

  /// "Neutro"
  neutral('neutral'),

  /// "Não foi pra mim"
  notForMe('not_for_me'),

  /// "Abandonei": ends the open cycle without finishing it.
  abandoned('abandoned'),

  /// "Na geladeira": keeps the open cycle.
  onHold('on_hold');

  final String wireValue;

  const Rating(this.wireValue);

  /// A verdict on a finished movie; only these offer the 100% session.
  bool get isVerdict => this != abandoned && this != onHold;

  static Rating? fromWireValue(String? value) =>
      values.where((rating) => rating.wireValue == value).firstOrNull;
}
