import 'package:dio/dio.dart';
import '../models/movie.dart';

class MovieService {
  final Dio _dio = Dio();

  final String _apiKey = "5d18cc6d";
  final String _baseUrl = "http://www.omdbapi.com/";

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'apikey': _apiKey,
          's': query,
        },
      );

      if (response.data['Response'] == 'True') {
        List<dynamic> searchResults = response.data['Search'];
        return searchResults.map((json) => Movie.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Ошибка сети: $e");
      return [];
    }
  }
  Future<Map<String, dynamic>> getMovieDetails(String id) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'apikey': _apiKey,
          'i': id,
          'plot': 'full',
        },
      );
      return response.data;
    } catch (e) {
      return {};
    }
  }
}