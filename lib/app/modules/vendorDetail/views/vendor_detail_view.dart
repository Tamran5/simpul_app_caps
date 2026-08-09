import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_detail_controller.dart';
import '../../vendor/controllers/vendor_controller.dart';
import '../../../shared/widgets/simpul_app_bar.dart';

class VendorDetailView extends GetView<VendorDetailController> {
  const VendorDetailView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color bgLight = Color(0xFFFBFBFB);
  static const Color textDark = Color(0xFF333333);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E8);

  String _getGalleryTitle(String category) {
    switch (category.toLowerCase()) {
      case 'catering':
        return 'Menu & Hidangan';
      case 'venue':
        return 'Fasilitas & Ruangan';
      case 'mua':
      case 'photography':
      case 'decoration':
        return 'Portfolio';
      default:
        return 'Galeri Foto';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = controller.vendor;

    return Scaffold(
      backgroundColor: bgLight,

      // ✅ Pakai SimpulAppBar dengan tombol back di leading
      appBar: SimpulAppBar(
        backgroundColor: bgLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Get.back(),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () => controller.hubungiWhatsApp(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Contact via WhatsApp',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(vendor.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 260),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 20,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: primaryGreen.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(vendor.category.toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: primaryGreen,
                                        letterSpacing: 0.5)),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_border, size: 16, color: textDark),
                                  const SizedBox(width: 4),
                                  Text('${vendor.rating} (128)',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textGrey)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(vendor.name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(Icons.location_on_outlined, size: 14, color: textGrey),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(vendor.location,
                                      style: const TextStyle(
                                          fontSize: 12, color: textGrey, height: 1.4))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tentang Kami
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tentang Kami',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 12),
                  Text(vendor.philosophy,
                      style: TextStyle(
                          fontSize: 13, color: textGrey.withOpacity(0.8), height: 1.6)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Portfolio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_getGalleryTitle(vendor.category),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                  GestureDetector(
                    onTap: () => controller.lihatSemuaPortofolio(),
                    child: const Text('View All',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            vendor.portfolioUrls.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('Belum ada foto galeri.',
                        style: TextStyle(
                            fontSize: 13, fontStyle: FontStyle.italic, color: textGrey)),
                  )
                : SizedBox(
                    height: 160,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: vendor.portfolioUrls.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            vendor.portfolioUrls[index],
                            width: 120,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                                width: 120,
                                height: 160,
                                color: borderGrey,
                                child: const Icon(Icons.image_not_supported)),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 32),

            // Paket Harga
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('Investment',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            ),
            const SizedBox(height: 16),
            vendor.packages.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('Daftar paket harga belum tersedia.',
                        style: TextStyle(
                            fontSize: 13, fontStyle: FontStyle.italic, color: textGrey)),
                  )
                : Column(
                    children: vendor.packages.map<Widget>((VendorPackage paket) {
                      return _buildPricingCard(
                        title: paket.title,
                        subtitle: paket.subtitle,
                        price: paket.price,
                        badgeText: paket.badgeText,
                        features: paket.features,
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String subtitle,
    required String price,
    String? badgeText,
    required List<String> features,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: textDark))),
              if (badgeText != null && badgeText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(badgeText,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: textGrey)),
          const SizedBox(height: 16),
          Text(price,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: primaryGreen)),
          const SizedBox(height: 20),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: textGrey),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(feature,
                            style: const TextStyle(fontSize: 12, color: textDark))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}