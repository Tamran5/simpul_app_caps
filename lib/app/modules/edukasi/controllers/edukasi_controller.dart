import 'package:get/get.dart';
import 'package:flutter/material.dart';

// Model Artikel
class ArticleModel {
  final String id;
  final String title;
  final String category;
  final String readTime;
  final String imageUrl;

  ArticleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    required this.imageUrl,
  });
}

class EdukasiController extends GetxController {
  // Kategori Artikel
  final List<String> categories = ['Terbaru', 'Legal & KUA', 'Keuangan', 'Mental Health', 'Inspirasi'];
  var selectedCategory = 'Terbaru'.obs;

  // Data Artikel (Dummy)
  var articles = <ArticleModel>[].obs;
  var featuredArticle = Rxn<ArticleModel>();

  @override
  void onInit() {
    super.onInit();
    _loadDummyArticles();
  }

  void _loadDummyArticles() {
    // Artikel Unggulan (Hero)
    featuredArticle.value = ArticleModel(
      id: '0',
      title: 'Panduan Lengkap Mengurus Dokumen N1-N4 di Kelurahan',
      category: 'Legal & KUA',
      readTime: '5 min read',
      imageUrl: 'https://picsum.photos/seed/doc/600/400',
    );

    // Daftar Artikel Lainnya
    articles.addAll([
      ArticleModel(
        id: '1',
        title: '5 Cara Menyatukan Pendapat dengan Keluarga Pasangan',
        category: 'Mental Health',
        readTime: '4 min read',
        imageUrl: 'https://picsum.photos/seed/family/300/300',
      ),
      ArticleModel(
        id: '2',
        title: 'Tips Membagi Budget Pernikahan Agar Tidak Over-budget',
        category: 'Keuangan',
        readTime: '6 min read',
        imageUrl: 'https://picsum.photos/seed/money/300/300',
      ),
      ArticleModel(
        id: '3',
        title: 'Tren Warna Gaun Pernikahan Tahun 2026',
        category: 'Inspirasi',
        readTime: '3 min read',
        imageUrl: 'https://picsum.photos/seed/dress/300/300',
      ),
      ArticleModel(
        id: '4',
        title: 'Apa yang Harus Disiapkan Sebelum Mengikuti Suscatin?',
        category: 'Legal & KUA',
        readTime: '4 min read',
        imageUrl: 'https://picsum.photos/seed/study/300/300',
      ),
    ]);
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  List<ArticleModel> get filteredArticles {
    if (selectedCategory.value == 'Terbaru') {
      return articles;
    }
    return articles.where((a) => a.category == selectedCategory.value).toList();
  }

  void openArticle(String title) {
    // Fungsi saat artikel diklik
    Get.snackbar(
      'Membaca Artikel',
      title,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF596E63),
      colorText: const Color(0xFFFFFFFF),
    );
  }
}