import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nowPlayingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getNowPlaying;
  return MoviesNotifier(
    fetchMoreMovie: fetchMoreMovies
  );
});

final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getPopular;
  return MoviesNotifier(
    fetchMoreMovie: fetchMoreMovies
  );
});

final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getUpcoming;
  return MoviesNotifier(
    fetchMoreMovie: fetchMoreMovies
  );
});

final topRatedMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getTopRated;
  return MoviesNotifier(
    fetchMoreMovie: fetchMoreMovies
  );
});

typedef MovieCallback = Future<List<Movie>> Function ({int page});

class MoviesNotifier extends StateNotifier<List<Movie>> {

  int currentPage = 0;
  bool isLoading = false;
  MovieCallback fetchMoreMovie;
  
  MoviesNotifier({
    required this.fetchMoreMovie,
  }): super([]);

  Future<void> loadNextPage () async {
    if(isLoading) return;

    isLoading = true;
    currentPage++;
    final List<Movie> movies = await fetchMoreMovie(page: currentPage);
    state = [...state, ...movies];
    await Future.delayed(const Duration(milliseconds: 200));
    isLoading = false;
  }

}