import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'movies.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(imdbID TEXT PRIMARY KEY, title TEXT, year TEXT, poster TEXT)',
        );
      },
    );
  }

  // Сохранить фильм
  Future<void> insertMovie(Movie movie) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'imdbID': movie.imdbID,
        'title': movie.title,
        'year': movie.year,
        'poster': movie.poster,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Если уже есть — обновим
    );
  }

  // Удалить из избранного
  Future<void> deleteMovie(String id) async {
    final db = await database;
    await db.delete('favorites', where: 'imdbID = ?', whereArgs: [id]);
  }

  // Получить все избранные фильмы
  Future<List<Movie>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');

    return List.generate(maps.length, (i) {
      return Movie(
        imdbID: maps[i]['imdbID'],
        title: maps[i]['title'],
        year: maps[i]['year'],
        poster: maps[i]['poster'],
      );
    });
  }

  // Проверить, в избранном ли фильм
  Future<bool> isFavorite(String id) async {
    final db = await database;
    final maps = await db.query('favorites', where: 'imdbID = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('favorites');
  }
}