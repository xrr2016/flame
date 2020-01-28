import 'package:feeling/model/movie.dart';
import 'package:flutter/material.dart';

import './movie_item.dart';

class MovieListTrending extends StatefulWidget {
  final List<Movie> movies;

  const MovieListTrending(this.movies);

  @override
  _MovieListTrendingState createState() => _MovieListTrendingState();
}

class _MovieListTrendingState extends State<MovieListTrending> {
  @override
  Widget build(BuildContext context) {
    final _movies = widget.movies;

    return Scrollbar(
      child: ListView.builder(
        itemExtent: 184.0,
        itemCount: _movies.length,
        itemBuilder: (_, int index) {
          Movie movie = _movies[index];
          return MovieItem(movie);
        },
      ),
    );
  }
}
