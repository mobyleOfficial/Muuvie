import 'package:core/core.dart';
import 'package:maratonas/maratonas.dart';

sealed class MaratonaDetailState {
  const MaratonaDetailState();
}

class MaratonaDetailLoading extends MaratonaDetailState {
  const MaratonaDetailLoading();
}

class MaratonaDetailError extends MaratonaDetailState {
  final AppError error;

  const MaratonaDetailError(this.error);
}

/// The maratona and its challenges with what the user completed. [busy] is
/// true while joining, leaving or cancelling.
class MaratonaDetailSuccess extends MaratonaDetailState {
  final Maratona maratona;
  final List<MaratonaCategory> categories;
  final bool busy;

  const MaratonaDetailSuccess({
    required this.maratona,
    required this.categories,
    this.busy = false,
  });

  int get completed =>
      categories.fold(0, (total, category) => total + category.completed);

  MaratonaDetailSuccess copyWith({
    Maratona? maratona,
    List<MaratonaCategory>? categories,
    bool? busy,
  }) => MaratonaDetailSuccess(
    maratona: maratona ?? this.maratona,
    categories: categories ?? this.categories,
    busy: busy ?? this.busy,
  );
}
