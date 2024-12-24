class Comic {
  final int id;
  final String title;
  final int categoryId;
  final String authorId;
  final String? authorName;
  final String? description;
  final String? releaseDate;
  final String? posterUrl;
  final double? rating;
  final String? gambar;

  Comic({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.authorId,
    this.authorName,
    this.description,
    this.releaseDate,
    this.posterUrl,
    this.rating,
    this.gambar,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: json['id'],
      title: json['title'] ?? "",
      categoryId: json['category_id'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      description: json['description'],
      releaseDate: json['release_date'],
      posterUrl: json['poster_url'],
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : null,
      gambar: json['gambar']?.startsWith("data:image")
          ? json['gambar']!.split(',')[1] // Ambil hanya base64-nya
          : null,
    );
  }
}