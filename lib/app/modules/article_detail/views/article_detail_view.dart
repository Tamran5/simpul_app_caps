import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/article_model.dart';
// 1. IMPORT BOOKMARK CONTROLLER (Pastikan path-nya sesuai)
import '../../bookmark/controllers/bookmark_controller.dart'; 

class ArticleDetailView extends StatelessWidget {
  final Article article;

  const ArticleDetailView({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2. INISIALISASI CONTROLLER BOOKMARK
    final BookmarkController bookmarkC = Get.put(BookmarkController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ----------------------------------------------------
          // 1. HEADER (Gambar Banner dengan Efek Parallax)
          // ----------------------------------------------------
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            
            // Tombol Back (Kiri)
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            
            // 3. TOMBOL BOOKMARK (Kanan) YANG SUDAH BERFUNGSI
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: Obx(() {
                    // Mengecek secara dinamis apakah artikel ini ada di list bookmark
                    bool isSaved = bookmarkC.bookmarkedArticles.any((a) => a.id == article.id);
                    
                    return IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border, 
                        color: isSaved ? Colors.green : Colors.black87,
                      ),
                      onPressed: () {
                        // Menjalankan fungsi simpan/hapus bookmark ke API Flask
                        bookmarkC.toggleBookmark(article.id);
                      },
                    );
                  }),
                ),
              ),
            ],
            
            // Gambar Background Parallax
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'article_image_${article.id}', // Animasi transisi mulus
                child: article.imageUrl.isNotEmpty
                    ? Image.network(
                        article.imageUrl, 
                        fit: BoxFit.cover, 
                        errorBuilder: (_, __, ___) => _fallbackImage()
                      )
                    : _fallbackImage(),
              ),
            ),
          ),
          
          // ----------------------------------------------------
          // 2. KONTEN (Teks Artikel dan Detail)
          // ----------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0.0, -20.0, 0.0), 
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Meta Info (Kategori & Waktu) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1), 
                            borderRadius: BorderRadius.circular(6)
                          ),
                          child: Text(
                            article.kategori.toUpperCase(), 
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${article.readTime} read', 
                              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // --- Judul Artikel ---
                    Text(
                      article.judul,
                      style: const TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        fontFamily: 'Serif', 
                        height: 1.3,
                        color: Colors.black87
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // --- Isi Konten ---
                    Text(
                      article.konten,
                      style: const TextStyle(
                        fontSize: 15, 
                        height: 1.8, 
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.grey[200], 
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Colors.grey)
      )
    );
  }
}