class Movie {
  final String title;
  final String year;
  final String poster;
  final String imdbID;

  Movie({
    required this.title,
    required this.year,
    required this.poster,
    required this.imdbID,
  });


  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'No Title',
      year: json['Year'] ?? '',
      poster: json['Poster'] != 'N/A'
          ? json['Poster']
          : 'https://via.placeholder.com/400x600?text=No+Image',
      imdbID: json['imdbID'] ?? '',
    );
  }

}