class Article {
  final int id;
  final String judul;
  final String kategori;
  final String imageUrl;
  final String readTime;
  final String targetReligion;
  final String konten;

  Article({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.imageUrl,
    required this.readTime,
    required this.targetReligion,
    required this.konten,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      kategori: json['kategori'] ?? '',
      imageUrl: json['image_url'] ?? '',
      readTime: json['read_time'] ?? '',
      targetReligion: json['target_religion'] ?? 'Umum',
      konten: json['konten'] ?? '',
    );
  }
}