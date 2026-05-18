import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_controller.dart';


class VendorView extends StatelessWidget {
  const VendorView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color primaryLight = Color(0xFFE8F0EE);
  static const Color bgGreen = Color(0xFFFBFBFB);
  static const Color textDark = Color(0xFF333333);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorController());

    return Scaffold(
      backgroundColor: bgGreen,
      appBar: AppBar(
        backgroundColor: bgGreen,
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
            icon: const Icon(Icons.notifications_none, color: primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Teks
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: const Text(
              'Katalog Vendor',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
          ),

          // Kolom Pencarian (Search Bar)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGrey),
              ),
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: const InputDecoration(
                  hintText: 'Cari catering, decoration, MUA...',
                  hintStyle: TextStyle(color: textGrey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: textGrey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Chips Kategori Horizontal
          _buildCategoryFilter(controller),
          const SizedBox(height: 16),

          // Daftar Vendor
          Expanded(
            child: Obx(() {
              final vendors = controller.filteredVendors;
              if (vendors.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada vendor ditemukan.',
                    style: TextStyle(color: textGrey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  return _buildVendorCard(vendors[index], controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget Kategori
  Widget _buildCategoryFilter(VendorController controller) {
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
                  color: isSelected ? primaryGreen : primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : primaryGreen,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // Widget Kartu Vendor
  // Widget Kartu Vendor
  Widget _buildVendorCard(VendorModel vendor, VendorController controller) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/vendor-detail', arguments: vendor);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Header & Ikon Favorit
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    vendor.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Tampilan saat gambar sedang loading / gagal
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: primaryLight,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: primaryGreen,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => controller.toggleFavorite(vendor),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          vendor.isFavorite.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: vendor.isFavorite.value
                              ? Colors.redAccent
                              : textGrey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Informasi Vendor Bawah
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge Kategori
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vendor.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${vendor.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nama Vendor
                  Text(
                    vendor.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Lokasi
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: textGrey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vendor.location,
                        style: const TextStyle(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Harga Bawah
                  Text(
                    vendor.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textDark,
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
