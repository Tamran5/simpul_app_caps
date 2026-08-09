import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/favorite_vendor_controller.dart';
import '../../vendor/controllers/vendor_controller.dart';
import '../../../shared/widgets/simpul_app_bar.dart';

class FavoriteVendorView extends GetView<FavoriteVendorController> {
  const FavoriteVendorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kSurface,
              shape: BoxShape.circle,
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: kInk, size: 18),
          ),
        ),
        title: const Text(
          'Vendor Favorit',
          style: TextStyle(
            color: kInk,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kForestMid, strokeWidth: 2),
          );
        }

        if (controller.favoriteList.isEmpty) {
          return _EmptyFavorite();
        }

        return RefreshIndicator(
          color: kForestMid,
          onRefresh: controller.fetchFavoritesFromDatabase,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: controller.favoriteList.length,
            itemBuilder: (_, i) =>
                _FavoriteCard(vendor: controller.favoriteList[i]),
          ),
        );
      }),
    );
  }
}

// ─── Favorite Card ────────────────────────────────────────────────────────────

class _FavoriteCard extends GetView<FavoriteVendorController> {
  const _FavoriteCard({required this.vendor});
  final VendorModel vendor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/vendor-detail', arguments: vendor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Gambar + tombol hapus favorit ─────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: vendor.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: vendor.imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 160,
                            color: kFog,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: kForestMid, strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 160,
                            color: kFog,
                            child: const Icon(Icons.storefront_outlined,
                                color: kMist, size: 40),
                          ),
                        )
                      : Container(
                          height: 160,
                          color: kFog,
                          child: const Icon(Icons.storefront_outlined,
                              color: kMist, size: 40),
                        ),
                ),
                // Tombol hapus favorit
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () =>
                        controller.removeFromFavoriteInPage(vendor),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kSurface.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: Color(0xFFE53935), size: 18),
                    ),
                  ),
                ),
              ],
            ),

            // ── Info ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CategoryBadge(vendor.category),
                      _RatingBadge(vendor.rating),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    vendor.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: kSubtext, size: 13),
                      const SizedBox(width: 4),
                      Text(vendor.location,
                          style: const TextStyle(
                              fontSize: 12, color: kSubtext)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vendor.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kInk,
                    ),
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

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyFavorite extends StatelessWidget {
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
            child: const Icon(Icons.favorite_outline_rounded,
                color: kMist, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada favorit',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: kInk),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap ikon ❤ pada vendor untuk menyimpannya di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kSubtext),
          ),
        ],
      ),
    );
  }
}

// ─── Badge Helpers ────────────────────────────────────────────────────────────

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

class _RatingBadge extends StatelessWidget {
  const _RatingBadge(this.rating);
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: kInk,
          ),
        ),
      ],
    );
  }
}