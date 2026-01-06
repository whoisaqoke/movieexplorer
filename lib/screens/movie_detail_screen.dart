import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/movie_service.dart';
import '../services/db_helper.dart';
import '../models/movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final String imdbID;
  final String title;

  const MovieDetailScreen({super.key, required this.imdbID, required this.title});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _service = MovieService();
  final DBHelper _dbHelper = DBHelper();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Проверка статуса в БД
  Future<void> _checkFavoriteStatus() async {
    bool fav = await _dbHelper.isFavorite(widget.imdbID);
    setState(() {
      _isFavorite = fav;
    });
  }

  // Логика кнопки Избранное
  Future<void> _toggleFavorite(Map<String, dynamic> data) async {
    if (_isFavorite) {
      await _dbHelper.deleteMovie(widget.imdbID);
    } else {
      await _dbHelper.insertMovie(Movie(
        imdbID: widget.imdbID,
        title: widget.title,
        year: data['Year'] ?? '',
        poster: data['Poster'] ?? '',
      ));
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  // Логика перехода на Kinogo
  Future<void> _openKinopoisk() async {
    // Кодируем название фильма для безопасной передачи в URL
    final String query = Uri.encodeComponent(widget.title);

    // Ссылка на поиск Кинопоиска
    final Uri url = Uri.parse("https://www.kinopoisk.ru/index.php?kp_query=$query");

    try {
      // Используем externalApplication, чтобы открылся именно браузер или приложение Кинопоиск
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Ошибка при открытии Кинопоиска: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Не удалось открыть Кинопоиск")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _service.getMovieDetails(widget.imdbID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
          }

          final data = snapshot.data ?? {};

          return CustomScrollView(
            slivers: [
              // Верхняя часть с постером
              SliverAppBar(
                expandedHeight: 500,
                pinned: true,
                backgroundColor: Colors.black,
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? const Color(0xFFE50914) : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(data),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: widget.imdbID,
                    child: Image.network(
                      data['Poster'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Контентная часть
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      widget.title.toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),

                    // Кнопка Смотреть (Стиль Netflix)
                    ElevatedButton.icon(
                      onPressed: _openKinopoisk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 30),
                      label: const Text("СМОТРЕТЬ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      data['Plot'] ?? 'Нет описания',
                      style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 25),

                    // Дополнительная инфо
                    _buildMetaLine("В ролях", data['Actors']),
                    _buildMetaLine("Режиссер", data['Director']),
                    _buildMetaLine("Рейтинг", "⭐ ${data['imdbRating']}"),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetaLine(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.white),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(color: Colors.grey)),
            TextSpan(text: value ?? 'Н/Д'),
          ],
        ),
      ),
    );
  }
}