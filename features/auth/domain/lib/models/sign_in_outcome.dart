/// How a sign-in with Apple or Google ended.
sealed class SignInOutcome {
  const SignInOutcome();
}

/// The session is saved. A new account still carries a generated nickname
/// ([needsNickname]) and is asked to pick one; [suggestedNickname] is the
/// name the provider gave, when it gave one.
final class SignedIn extends SignInOutcome {
  final bool needsNickname;
  final String? suggestedNickname;

  const SignedIn({required this.needsNickname, this.suggestedNickname});
}

/// The user closed the provider's sheet: nothing changed.
final class SignInCancelled extends SignInOutcome {
  const SignInCancelled();
}
