import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/db_helper.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final MovieService _movieService = MovieService();
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> _searchResult = [];
  List<Movie> _favoriteMovies = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await _dbHelper.getFavorites();
    setState(() {
      _favoriteMovies = favs;
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadFavorites();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final results = await _movieService.searchMovies(query);
    setState(() {
      _searchResult = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      _buildFavoritesTab(),
      _buildSearchTab(),
      _buildSettingsTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      appBar: AppBar(
        title: const Text('MOVIE EXPLORER',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white30,
        backgroundColor: const Color(0xFF1A1D29),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }

  // --- ВКЛАДКА ПОИСКА ---
  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onSubmitted: _performSearch,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Поиск',
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.search, color: Colors.white30),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              : _searchResult.isEmpty
              ? const Center(child: Text("Найдите что-нибудь интересное 🍿",
              style: TextStyle(color: Colors.white30)))
              : GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: _searchResult.length,
            itemBuilder: (context, index) => _buildMovieCard(_searchResult[index]),
          ),
        ),
      ],
    );
  }

  // --- ВКЛАДКА ИЗБРАННОГО ---
  Widget _buildFavoritesTab() {
    if (_favoriteMovies.isEmpty) {
      return const Center(
          child: Text("В избранном пока пусто 💔",
              style: TextStyle(color: Colors.white30)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _favoriteMovies.length,
      itemBuilder: (context, index) {
        final movie = _favoriteMovies[index];
        return Dismissible(
          key: Key(movie.imdbID),
          direction: DismissDirection.up,
          onDismissed: (_) {
            _dbHelper.deleteMovie(movie.imdbID);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${movie.title} удален")));
          },
          child: _buildMovieCard(movie),
        );
      },
    );
  }

  // --- ВКЛАДКА НАСТРОЕК ---
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Center(child: Text("Киноман", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const Divider(height: 40, color: Colors.white10),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
          title: const Text("Очистить библиотеку"),
          onTap: () async {
            // Реализуйте метод clearAll в DBHelper
            await _dbHelper.clearAll();
            _loadFavorites();
          },
        ),
        const ListTile(
          leading: Icon(Icons.info_outline, color: Colors.white),
          title: Text("Версия"),
          trailing: Text("1.0.5 (TMDB)", style: TextStyle(color: Colors.white30)),
        ),
      ],
    );
  }

  // --- КАРТОЧКА ФИЛЬМА ---
  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(imdbID: movie.imdbID, title: movie.title),
          ),
        );
        _loadFavorites();
      },
      child: Hero(
        tag: movie.imdbID,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(movie.poster),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                stops: const [0.6, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.bottomLeft,
            child: Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}