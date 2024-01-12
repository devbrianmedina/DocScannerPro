import 'dart:convert';

class Scanner {
  int? idScanner;
  String title;
  String createdAt;
  List<String> imagesPath;

  Scanner({this.idScanner, required this.title, required this.createdAt, required this.imagesPath});

  Map<String, dynamic> toMap() {
    return {
      'id_scanner': idScanner,
      'title': title,
      'created_at': createdAt,
      "images_path": jsonEncode(imagesPath),
    };
  }

  factory Scanner.fromMap(Map<String, dynamic> map) {
    return Scanner(
        idScanner: map['id_scanner'],
        title: map['title'],
        createdAt: map['created_at'],
        imagesPath: List<String>.from(jsonDecode(map['images_path']))
    );
  }
}
