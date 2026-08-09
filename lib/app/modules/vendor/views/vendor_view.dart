import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/vendor_controller.dart';
import '../../../shared/widgets/simpul_app_bar.dart';

class VendorView extends StatelessWidget {
  const VendorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorController());

    return Scaffold(
      backgroundColor: kBg,
      appBar: SimpulAppBar(
        actions: [
          _IconBtn(
            icon: Icons.favorite_outline_rounded,
            onTap: () => Get.toNamed('/favorite-vendor'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Page header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Katalog Vendor',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Temukan vendor terbaik untuk hari istimewamu',
                  style: TextStyle(fontSize: 13, color: kSubtext),
                ),
                const SizedBox(height: 14),
                _LocationBar(controller: controller),
                const SizedBox(height: 14),
                _SearchBar(controller: controller),
                const SizedBox(height: 14),
                _CategoryChips(controller: controller),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Vendor list ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: kForestMid, strokeWidth: 2),
                );
              }

              final vendors = controller.filteredVendors;
              if (vendors.isEmpty) {
                return _EmptyState(
                  isSearching: controller.searchQuery.value.isNotEmpty,
                  onClear: controller.clearSearch,
                );
              }

              return RefreshIndicator(
                color: kForestMid,
                onRefresh: controller.fetchVendors,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: vendors.length,
                  itemBuilder: (_, i) => _VendorCard(
                      vendor: vendors[i], controller: controller),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Bar lokasi otomatis ────────────────────────────────────────────────────

class _LocationBar extends StatelessWidget {
  const _LocationBar({required this.controller});
  final VendorController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLocationLoading.value;
      final enabled = controller.locationEnabled.value;
      final sortActive = controller.sortByDistance.value && enabled;

      return Row(
        children: [
          // ── Label lokasi ────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () => controller.detectUserLocation(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: enabled
                      ? kForestMid.withValues(alpha: 0.08)
                      : kFog,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: enabled
                        ? kForestMid.withValues(alpha: 0.25)
                        : kBorder,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: kForestMid,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            enabled
                                ? Icons.my_location_rounded
                                : Icons.location_off_rounded,
                            size: 15,
                            color: enabled ? kForestMid : kSubtext,
                          ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loading
                            ? 'Mendeteksi lokasi kamu...'
                            : controller.userLocationLabel.value,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: enabled ? kForestMid : kSubtext,
                        ),
                      ),
                    ),
                    if (!loading)
                      Icon(Icons.refresh_rounded,
                          size: 15,
                          color: enabled
                              ? kForestMid.withValues(alpha: 0.6)
                              : kSubtext),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ── Toggle urutkan terdekat ─────────────────────────────────────
          GestureDetector(
            onTap: controller.toggleSortByDistance,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: sortActive ? kForestMid : kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sortActive ? kForestMid : kBorder,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.social_distance_rounded,
                    size: 15,
                    color: sortActive ? Colors.white : kSubtext,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Terdekat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sortActive ? Colors.white : kSubtext,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final VendorController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchTextController,
        onChanged: controller.onSearchChanged,
        style: const TextStyle(fontSize: 14, color: kInk),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari vendor, kota, atau kategori...',
          hintStyle: const TextStyle(color: kSubtext, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: kSubtext, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchTextController,
            builder: (_, value, __) {
              return Obx(() {
                if (controller.isSearching.value) {
                  return const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: kForestMid,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: controller.clearSearch,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: kSubtext),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.controller});
  final VendorController controller;

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

// ── Vendor card ───────────────────────────────────────────────────────────────

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor, required this.controller});
  final VendorModel vendor;
  final VendorController controller;

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
            // ── Gambar + favorit + jarak ─────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
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
                Positioned(
                  top: 12,
                  right: 12,
                  child: Obx(() => GestureDetector(
                        onTap: () => controller.toggleFavorite(vendor),
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
                          child: Icon(
                            vendor.isFavorite.value
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            color: vendor.isFavorite.value
                                ? const Color(0xFFE53935)
                                : kSubtext,
                            size: 18,
                          ),
                        ),
                      )),
                ),
                // ── Badge jarak (jika lokasi user & vendor tersedia) ──────
                Obx(() {
                  final distance = controller.distanceKmFor(vendor);
                  if (distance == null) return const SizedBox.shrink();
                  return Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            distance < 1
                                ? '${(distance * 1000).round()} m'
                                : '${distance.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
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
                      Expanded(
                        child: Text(vendor.location,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: kSubtext)),
                      ),
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

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

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
  const _EmptyState({required this.isSearching, required this.onClear});
  final bool isSearching;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration:
                const BoxDecoration(color: kFog, shape: BoxShape.circle),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.storefront_outlined,
              color: kMist,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'Hasil pencarian tidak ditemukan' : 'Vendor tidak ditemukan',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: kInk),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coba ubah kata kunci atau kategori pencarian.',
            style: TextStyle(fontSize: 12, color: kSubtext),
          ),
          if (isSearching) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded,
                  size: 16, color: kForestMid),
              label: const Text(
                'Reset pencarian',
                style: TextStyle(
                    color: kForestMid, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}