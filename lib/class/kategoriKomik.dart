class KategoriKomik {
  int id;
  String category_name;

  KategoriKomik({required this.id, required this.category_name, });
  factory KategoriKomik.fromJson(Map<String, dynamic> json) {
    return KategoriKomik(
      id: json['id'] as int,
      category_name: json['category_name'] as String,
    );
  }
}