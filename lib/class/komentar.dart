class Komentar {
  int id;
  String comment;
  String reader_name;

  Komentar({required this.id, required this.comment, required this.reader_name});
  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      id: json['id'] as int,
      comment: json['comment'] as String,
      reader_name: json['reader_name'] as String,
    );
  }
}