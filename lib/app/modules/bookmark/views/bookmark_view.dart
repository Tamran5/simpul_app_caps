import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bookmark_controller.dart';
import '../../article_detail/views/article_detail_view.dart';

class BookmarkView extends GetView<BookmarkController> {
  const BookmarkView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Artikel Tersimpan', style: TextStyle(fontFamily: 'Serif', color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (controller.bookmarkedArticles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Belum ada artikel yang disimpan', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.bookmarkedArticles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            var article = controller.bookmarkedArticles[index];
            return GestureDetector(
              onTap: () => Get.to(() => ArticleDetailView(article: article)),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: article.imageUrl.isNotEmpty
                          ? Image.network(article.imageUrl, height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 80, width: 80, color: Colors.grey[200]))
                          : Container(height: 80, width: 80, color: Colors.grey[200]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.kategori.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 6),
                          Text(article.judul, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${article.readTime} read', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              // Tombol Hapus Bookmark
                              IconButton(
                                icon: const Icon(Icons.bookmark, size: 20, color: Colors.green),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  controller.toggleBookmark(article.id);
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}