// lib/app/modules/edukasi/views/edukasi_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/edukasi_controller.dart';
import '../../bookmark/controllers/bookmark_controller.dart';
import '../../../../data/models/article_model.dart';
import '../../article_detail/views/article_detail_view.dart';
import '../../../shared/widgets/simpul_app_bar.dart'; // sesuaikan path

class EdukasiView extends GetView<EdukasiController> {
  EdukasiView({super.key});

  final BookmarkController _bookmarkC = Get.put(BookmarkController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: SimpulAppBar(
        actions: [
          _IconBtn(
            icon: Icons.bookmark_outline_rounded,
            onTap: () => Get.toNamed('/bookmark'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kForestMid, strokeWidth: 2),
          );
        }

        return RefreshIndicator(
          color: kForestMid,
          onRefresh: () async => controller.fetchArticles(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Page title ──────────────────────────────────────
                      const Text(
                        'Pusat Edukasi',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: kInk,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Panduan & artikel pernikahan untukmu',
                        style: TextStyle(fontSize: 13, color: kSubtext),
                      ),
                      const SizedBox(height: 16),

                      // ── Category chips ──────────────────────────────────
                      _CategoryChips(controller: controller),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ── Konten artikel ─────────────────────────────────────────
              Obx(() {
                if (controller.filteredArticles.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Artikel utama
                      _SectionTitle('Bacaan Pilihan'),
                      const SizedBox(height: 12),
                      _FeaturedCard(
                        article: controller.featuredArticle!,
                        bookmarkC: _bookmarkC,
                      ),
                      const SizedBox(height: 28),

                      // Artikel lainnya
                      if (controller.otherArticles.isNotEmpty) ...[
                        _SectionTitle('Artikel Lainnya'),
                        const SizedBox(height: 12),
                        ...controller.otherArticles.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ListCard(article: a, bookmarkC: _bookmarkC),
                          ),
                        ),
                      ],
                    ]),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.controller});
  final EdukasiController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = controller.categories[i];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.changeCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? kForestMid : kSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? kForestMid : kBorder,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : kSubtext,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kInk,
      ),
    );
  }
}

// ── Featured article card (besar) ────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.article, required this.bookmarkC});
  final Article article;
  final BookmarkController bookmarkC;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ArticleDetailView(article: article)),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Stack(
              children: [
                Hero(
                  tag: 'article_image_${article.id}',
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _ArticleImage(
                        url: article.imageUrl, height: 180),
                  ),
                ),
                // Tombol bookmark
                Positioned(
                  top: 12,
                  right: 12,
                  child: _BookmarkBtn(
                      articleId: article.id, bookmarkC: bookmarkC),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CategoryBadge(article.kategori),
                      _ReadTime(article.readTime),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.judul,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kInk,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// ── List article card (kecil) ─────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  const _ListCard({required this.article, required this.bookmarkC});
  final Article article;
  final BookmarkController bookmarkC;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ArticleDetailView(article: article)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'article_image_${article.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _ArticleImage(url: article.imageUrl, height: 80, width: 80),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(article.kategori),
                  const SizedBox(height: 6),
                  Text(
                    article.judul,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kInk,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ReadTime(article.readTime),
                      _BookmarkBtn(
                          articleId: article.id,
                          bookmarkC: bookmarkC,
                          size: 18),
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

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.url, required this.height, this.width = double.infinity});
  final String url;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _Fallback(height: height, width: width);
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: height,
        width: width,
        color: kFog,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: kForestMid, strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _Fallback(height: height, width: width),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.height, required this.width});
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: kFog,
      child: const Icon(Icons.image_outlined, color: kMist, size: 28),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge(this.category);
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kFog,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: kForestMid,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ReadTime extends StatelessWidget {
  const _ReadTime(this.time);
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule_rounded, size: 12, color: kSubtext),
        const SizedBox(width: 4),
        Text(time, style: const TextStyle(fontSize: 11, color: kSubtext)),
      ],
    );
  }
}

class _BookmarkBtn extends StatelessWidget {
  const _BookmarkBtn({required this.articleId, required this.bookmarkC, this.size = 20});
  final int articleId;
  final BookmarkController bookmarkC;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final saved = bookmarkC.bookmarkedArticles.any((a) => a.id == articleId);
      return GestureDetector(
        onTap: () => bookmarkC.toggleBookmark(articleId),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(color: kSurface, shape: BoxShape.circle),
          child: Icon(
            saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            size: size,
            color: saved ? kForestMid : kSubtext,
          ),
        ),
      );
    });
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: kSurface,
          shape: BoxShape.circle,
          border: Border.all(color: kBorder, width: 1.5),
        ),
        child: Icon(icon, color: kForestMid, size: 18),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: kFog, shape: BoxShape.circle),
            child: const Icon(Icons.menu_book_outlined, color: kMist, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada artikel',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kInk),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tidak ada artikel di kategori ini.',
            style: TextStyle(fontSize: 12, color: kSubtext),
          ),
        ],
      ),
    );
  }
}