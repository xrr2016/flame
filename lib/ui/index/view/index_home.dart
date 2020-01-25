import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../model/movie.dart';
import '../../../widget/loading.dart';
import '../../search/search_screen.dart';
import '../../../const/movie_types.dart';
import '../widget/movie_list_trending.dart';
import '../widget/movie_list_horiziontal.dart';
import '../../../data/network/api_client.dart';

class IndexHome extends StatefulWidget {
  @override
  _IndexHomeState createState() => _IndexHomeState();
}

class _IndexHomeState extends State<IndexHome>
    with AutomaticKeepAliveClientMixin {
  bool _isLoadingData = false;
  bool _isLoadingTrending = false;
  bool _isLoadingMovies = false;

  int _totalTendingPage = 1;
  int _currentTrendingPage = 1;
  List<Movie> _trendingMovies = [];

  int _totalMoviePage = 1;
  int _currentMoviePage = 1;
  List<Movie> _movies = [];

  String _selection = movieTypes[0];

  Future _fetchMovieData() async {
    setState(() {
      _isLoadingData = true;
    });

    var futures = List<Future>();

    futures.add(_getMovies());
    futures.add(_getTrending());

    await Future.wait(futures);

    setState(() {
      _isLoadingData = false;
    });
  }

  Future _getTrending({String time = 'day'}) async {
    _isLoadingTrending = true;
    try {
      Response response = await ApiClient.get(
        '/3/trending/movie/$time',
        queryParameters: {
          "page": _currentTrendingPage,
        },
      );

      final data = response.data;
      final results = data["results"] as List;
      _totalTendingPage = data["total_pages"];

      results.forEach((r) => _trendingMovies.add(Movie.fromJson(r)));
      setState(() {
        _trendingMovies = _trendingMovies;
      });
    } on DioError catch (err) {
      throw err;
    } finally {
      _isLoadingTrending = false;
    }
  }

  Future _getMovies({String type = 'upcoming'}) async {
    _isLoadingMovies = true;
    try {
      Response response = await ApiClient.get(
        '/3/movie/$type',
        queryParameters: {
          "page": _currentMoviePage,
        },
      );

      final data = response.data;
      final results = data["results"] as List;
      _totalMoviePage = data["total_pages"];

      results.forEach((r) => _movies.add(Movie.fromJson(r)));
      setState(() {
        _movies = _movies;
      });
    } on DioError catch (err) {
      throw err;
    } finally {
      _isLoadingMovies = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMovieData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        AppBar(
          elevation: 0.0,
          centerTitle: false,
          leading: PopupMenuButton<String>(
            initialValue: _selection,
            icon: Icon(Icons.filter_list),
            onSelected: (result) {
              setState(() {
                _movies = [];
                _totalMoviePage = 1;
                _currentMoviePage = 1;
                _selection = result;
                _getMovies(type: result);
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: movieTypes[0],
                child: Text('Popular'),
              ),
              PopupMenuItem(
                value: movieTypes[1],
                child: Text('Upcoming'),
              ),
              PopupMenuItem(
                value: movieTypes[2],
                child: Text('Top'),
              ),
              PopupMenuItem(
                value: movieTypes[3],
                child: Text('Now'),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pushNamed(context, SearchScreen.routeName);
              },
            ),
          ],
        ),
        Expanded(
          child: _isLoadingData
              ? Loading()
              : RefreshIndicator(
                  onRefresh: () {
                    _isLoadingData = false;
                    _isLoadingMovies = false;
                    _isLoadingTrending = false;

                    _totalTendingPage = 1;
                    _currentTrendingPage = 1;

                    _totalMoviePage = 1;
                    _currentMoviePage = 1;

                    setState(() {
                      _movies = [];
                      _trendingMovies = [];
                    });

                    return _fetchMovieData();
                  },
                  child: Column(
                    children: <Widget>[
                      NotificationListener<ScrollNotification>(
                        child: MovieListHorizontal(_movies),
                        onNotification: (ScrollNotification scrollInfo) {
                          final metrics = scrollInfo.metrics;

                          if (metrics.pixels >= metrics.maxScrollExtent) {
                            if (_currentMoviePage < _totalMoviePage &&
                                !_isLoadingMovies) {
                              _currentMoviePage++;
                              _getMovies();
                            }
                          }
                          return;
                        },
                      ),
                      NotificationListener<ScrollNotification>(
                        child: MovieListTrending(_trendingMovies),
                        onNotification: (ScrollNotification scrollInfo) {
                          final metrics = scrollInfo.metrics;

                          if (metrics.pixels >= metrics.maxScrollExtent) {
                            if (_currentTrendingPage < _totalTendingPage &&
                                !_isLoadingTrending) {
                              _currentTrendingPage++;
                              _getTrending();
                            }
                          }
                          return;
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}