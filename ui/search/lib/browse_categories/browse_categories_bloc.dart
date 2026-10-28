import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';

import 'package:search/browse_categories/browse_categories_state.dart';

class BrowseCategoriesCubit extends Cubit<BrowseCategoriesState> {
  final GetGenres _getGenres;
  final GetCountries _getCountries;
  final GetLanguages _getLanguages;

  BrowseCategoriesCubit(this._getGenres, this._getCountries, this._getLanguages)
    : super(const BrowseCategoriesLoading()) {
    _load();
  }

  void reload() {
    emit(const BrowseCategoriesLoading());
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _getGenres(),
      _getCountries(),
      _getLanguages(),
    ]);

    final genresResult = results[0] as Result<List<Genre>>;
    final countriesResult = results[1] as Result<List<Country>>;
    final languagesResult = results[2] as Result<List<Language>>;

    if (genresResult is Failure ||
        countriesResult is Failure ||
        languagesResult is Failure) {
      emit(const BrowseCategoriesError('Failed to load categories'));
      return;
    }

    emit(
      BrowseCategoriesSuccess(
        genres: (genresResult as Success<List<Genre>>).data,
        countries: (countriesResult as Success<List<Country>>).data,
        languages: (languagesResult as Success<List<Language>>).data,
      ),
    );
  }
}
