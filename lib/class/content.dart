class Content {
  final int id;
  final int comicid;
  final String? gambar;

  Content({
    required this.id,
    required this.comicid,
    this.gambar,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      comicid: json['comic_id'],
      gambar: json['gambar']?.startsWith("data:image")
          ? json['gambar']!.split(',')[1]
          : null,
    );
  }
}