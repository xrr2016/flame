import 'package:flutter/material.dart';

import '../../../styles.dart';
import './movie_item_vertical.dart';
import '../../../model/movie.dart';
import '../../../widget/loading.dart';

class MovieListHorizontal extends StatefulWidget {
  final List<Movie> movies;
  final String label;

  const MovieListHorizontal(this.movies, this.label);

  @override
  _MovieListHorizontalState createState() => _MovieListHorizontalState();
}

class _MovieListHorizontalState extends State<MovieListHorizontal> {
  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final _movies = widget.movies;

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Styles.subTitle.copyWith(color: Colors.white)),
          SizedBox(height: 24.0),
          SizedBox(
            height: 340.0,
            child: _movies.isNotEmpty
                ? Scrollbar(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 12.0),
                      itemExtent: 192.0,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) {
                        final Movie movie = _movies[index];

                        return MovieItemVertical(movie, label);
                      },
                      itemCount: _movies.length,
                    ),
                  )
                : Loading(),
          ),
        ],
      ),
    );
  }
}
