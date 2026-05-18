import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edukasi_controller.dart';

class EdukasiView extends StatelessWidget {
  const EdukasiView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color primaryLight = Color(0xFFE8F0EE);
  static const Color bgLight = Color(0xFFFBFBFB);
  static const Color textDark = Color(0xFF333333);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EdukasiController());

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Simpul',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: primaryGreen),
            onPressed: () {
              Get.snackbar('Bookmark', 'Fitur simpan artikel akan segera hadir.');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Teks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: const Text(
              'Pusat Edukasi',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textDark),
            ),
          ),
          
          // Chips Kategori Horizontal
          const SizedBox(height: 8),
          _buildCategoryFilter(controller),
          const SizedBox(height: 16),

          // Konten Berita/Edukasi yang bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hanya tampilkan Artikel Utama jika kategori 'Terbaru' dipilih
                    Obx(() {
                      if (controller.selectedCategory.value == 'Terbaru' && controller.featuredArticle.value != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bacaan Pilihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                            const SizedBox(height: 12),
                            _buildFeaturedArticle(controller.featuredArticle.value!, controller),
                            const SizedBox(height: 24),
                            const Text('Artikel Lainnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                            const SizedBox(height: 12),
                          ],
                        );
                      }
                      return const SizedBox.shrink(); // Sembunyikan jika bukan kategori terbaru
                    }),

                    // Daftar Artikel (Grid/List)
                    Obx(() {
                      final articles = controller.filteredArticles;
                      if (articles.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40.0),
                            child: Text('Belum ada artikel di kategori ini.', style: TextStyle(color: textGrey)),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true, // Penting agar ListView bisa berada di dalam SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(), // Scroll diatur oleh SingleChildScrollView induk
                        itemCount: articles.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildArticleItem(articles[index], controller);
                        },
                      );
                    }),
                    const SizedBox(height: 40), // Jarak aman paling bawah
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Filter Kategori
  Widget _buildCategoryFilter(EdukasiController controller) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: controller.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;
            return GestureDetector(
              onTap: () => controller.changeCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreen : Colors.white,
                  border: Border.all(color: isSelected ? primaryGreen : borderGrey),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : textGrey,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // Widget Artikel Utama (Hero Image)
  Widget _buildFeaturedArticle(ArticleModel article, EdukasiController controller) {
    return GestureDetector(
      onTap: () => controller.openArticle(article.title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderGrey),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                article.imageUrl,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180, color: primaryLight,
                  child: const Icon(Icons.image_not_supported, color: primaryGreen),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          article.category.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 12, color: textGrey),
                      const SizedBox(width: 4),
                      Text(article.readTime, style: TextStyle(fontSize: 10, color: textGrey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Item Artikel List (Gambar Kiri, Teks Kanan)
  Widget _buildArticleItem(ArticleModel article, EdukasiController controller) {
    return GestureDetector(
      onTap: () => controller.openArticle(article.title),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderGrey),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80, height: 80, color: primaryLight,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: textGrey),
                      const SizedBox(width: 4),
                      Text(article.readTime, style: TextStyle(fontSize: 10, color: textGrey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}