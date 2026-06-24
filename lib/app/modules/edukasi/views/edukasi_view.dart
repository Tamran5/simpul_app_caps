import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/edukasi_controller.dart';
import '../../bookmark/controllers/bookmark_controller.dart';
import '../../../../data/models/article_model.dart';
import '../../article_detail/views/article_detail_view.dart';


class EdukasiView extends GetView<EdukasiController> {
  EdukasiView({Key? key}) : super(key: key);

  // Inisialisasi BookmarkController untuk fitur simpan artikel
  final BookmarkController bookmarkC = Get.put(BookmarkController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Simpul', style: TextStyle(fontFamily: 'Serif', color: Colors.green, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black87),
            onPressed: () {
              // Navigasi ke halaman Bookmark (Sesuaikan nama rute jika berbeda di app_pages.dart)
              Get.toNamed('/bookmark');
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        return RefreshIndicator(
          color: Colors.green,
          onRefresh: () async => controller.fetchArticles(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pusat Edukasi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
                  const SizedBox(height: 16),
                  
                  // --- Kategori Filter (Chips) ---
                  SizedBox(
                    height: 35,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        String category = controller.categories[index];
                        bool isSelected = controller.selectedCategory.value == category;
                        return GestureDetector(
                          onTap: () => controller.changeCategory(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green[800] : Colors.white,
                              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Jika tidak ada artikel setelah difilter
                  if (controller.filteredArticles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: Text('Tidak ada artikel di kategori ini.', style: TextStyle(color: Colors.grey))),
                    )
                  else ...[
                    // --- Artikel Utama (Bacaan Pilihan) ---
                    const Text('Bacaan Pilihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildFeaturedArticle(controller.featuredArticle!),
                    
                    const SizedBox(height: 24),
                    
                    // --- Artikel Lainnya ---
                    if (controller.otherArticles.isNotEmpty) ...[
                      const Text('Artikel Lainnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.otherArticles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildListArticle(controller.otherArticles[index]);
                        },
                      ),
                    ]
                  ],
                  const SizedBox(height: 30), // Padding bawah
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Komponen Card Besar
  Widget _buildFeaturedArticle(Article article) {
    return GestureDetector(
      onTap: () => Get.to(() => ArticleDetailView(article: article)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'article_image_${article.id}', // Tambahan Hero animasi
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    // PENGGUNAAN CACHED NETWORK IMAGE
                    child: article.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: article.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 180,
                              color: Colors.grey[100],
                              child: const Center(child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) => _fallbackImage(180),
                          )
                        : _fallbackImage(180),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Obx(() {
                      // Cek apakah artikel ini ada di list bookmark
                      bool isSaved = bookmarkC.bookmarkedArticles.any((a) => a.id == article.id);
                      return IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border, 
                          size: 20, 
                          color: isSaved ? Colors.green : Colors.black54
                        ),
                        onPressed: () => bookmarkC.toggleBookmark(article.id),
                        constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                        padding: EdgeInsets.zero,
                      );
                    }),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                        child: Text(article.kategori.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(article.readTime, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(article.judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Komponen Card Kecil
  Widget _buildListArticle(Article article) {
    return GestureDetector(
      onTap: () => Get.to(() => ArticleDetailView(article: article)), 
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Hero(
              tag: 'article_image_${article.id}', // Tambahan Hero animasi
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // PENGGUNAAN CACHED NETWORK IMAGE
                child: article.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: article.imageUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 80, 
                          width: 80, 
                          color: Colors.grey[100],
                          child: const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))),
                        ),
                        errorWidget: (context, url, error) => _fallbackImage(80, 80),
                      )
                    : _fallbackImage(80, 80),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.kategori.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(article.judul, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${article.readTime} read', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Obx(() {
                        // Cek apakah artikel ini ada di list bookmark
                        bool isSaved = bookmarkC.bookmarkedArticles.any((a) => a.id == article.id);
                        return IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border, 
                            size: 18, 
                            color: isSaved ? Colors.green : Colors.grey
                          ),
                          onPressed: () => bookmarkC.toggleBookmark(article.id),
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          padding: EdgeInsets.zero,
                        );
                      }),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage(double height, [double width = double.infinity]) {
    return Container(height: height, width: width, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey));
  }
}