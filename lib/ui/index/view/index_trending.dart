import 'package:flin/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../model/movie.dart';
import '../widget/movie_list_trending.dart';
import '../../../data/network/api_client.dart';

class IndexTrending extends StatefulWidget {
  @override
  _IndexTrendingState createState() => _IndexTrendingState();
}

class _IndexTrendingState extends State<IndexTrending>
    with AutomaticKeepAliveClientMixin {
  int _totalTendingPage = 1;
  int _currentTrendingPage = 1;
  List<Movie> _trendingMovies = [];
  bool _isLoadingTrending = false;

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

  @override
  void initState() {
    super.initState();
    _getTrending();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Container(
        height: screenHeight(context),
        child: NotificationListener<ScrollNotification>(
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}