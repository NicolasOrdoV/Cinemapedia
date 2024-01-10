import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query); 

class SearchMovieDelegate extends SearchDelegate<Movie?> {

  final SearchMoviesCallback searchMovies;
  List<Movie> initialMovies;
  StreamController<List<Movie>> debounceMovies = StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();
  Timer? _debounceTimer;

  SearchMovieDelegate({ required this.initialMovies, required this.searchMovies});

  void clearStreams() {
    debounceMovies.close();
  }

  void _onQuerychanged(String query) {
    isLoadingStream.add(true);
    if(_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async { 
      // if (query.isEmpty) {
      //   debounceMovies.add([]);
      //   return;
      // }

      final movies = await searchMovies(query);
      initialMovies = movies;
      debounceMovies.add(movies);
      isLoadingStream.add(false);
    });
  }

  @override
  String get searchFieldLabel => 'Buscar pelicula';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // if(query.isNotEmpty)
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream, 
        builder: (context, snapshot) {
          if(snapshot.data ?? false) {
            return SpinPerfect(
              duration: const Duration(seconds: 20),
              infinite: true,
              child: IconButton(
                onPressed: () => query = '', 
                icon: const Icon(Icons.refresh)
              ),
            );
          } else {
            return FadeIn(
              animate: query.isNotEmpty,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: () => query = '', 
                icon: const Icon(Icons.clear)
              ),
            );
          }
        },
      ),
      
      
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        close(context, null);
      }, 
      icon: const Icon(Icons.arrow_back_ios_new_outlined)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return  buildResultAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQuerychanged(query);
    return buildResultAndSuggestions();
  }

  Widget buildResultAndSuggestions() {
    return StreamBuilder(
      initialData: initialMovies,
      stream: debounceMovies.stream,
      builder: (context, snapshot) {
        // if(snapshot.hasData)
        final movies = snapshot.data ?? [];
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie:  movies[index], 
            onMovieSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            },
          ),
        );
      },
    );
  }

}

class _MovieItem extends StatelessWidget {
  final Movie movie;
  final Function onMovieSelected;
  const _MovieItem({required this.movie, required this.onMovieSelected});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: (){
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath
                ),
              ),
            ),
      
            const SizedBox(width: 10,),
      
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: textStyles.titleMedium,),
                  (movie.overview.length > 100) ? Text('${movie.overview.substring(0, 100)}...') : Text(movie.overview) ,
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded, color: Colors.yellow.shade800,),
                      const SizedBox(width: 5,),
                      Text(
                        HumanFormats.number(movie.voteAverage, 2), 
                        style: textStyles.bodyMedium!.copyWith(color: Colors.yellow.shade900),
                      )
                    ],
                  )
                ],
              ),
      
            )
          ],
        ),
      ),
    );
  }
}