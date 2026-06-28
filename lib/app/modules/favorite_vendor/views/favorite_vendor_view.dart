import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favorite_vendor_controller.dart';
import '../../vendor/controllers/vendor_controller.dart'; 
import '../../vendor/views/vendor_view.dart'; 

class FavoriteVendorView extends GetView<FavoriteVendorController> {
  const FavoriteVendorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VendorView.bgGreen,
      appBar: AppBar(
        backgroundColor: VendorView.bgGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VendorView.primaryGreen),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Vendor Favorit Akun Saya',
          style: TextStyle(color: VendorView.textDark, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: VendorView.primaryGreen));
        }

        if (controller.favoriteList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada vendor favorit di akun ini.',
              style: TextStyle(color: VendorView.textGrey, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const BouncingScrollPhysics(),
          itemCount: controller.favoriteList.length,
          itemBuilder: (context, index) {
            final vendor = controller.favoriteList[index];
            return _buildFavoriteCard(vendor);
          },
        );
      }),
    );
  }

  Widget _buildFavoriteCard(VendorModel vendor) {
    return GestureDetector(
      onTap: () => Get.toNamed('/vendor-detail', arguments: vendor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: VendorView.borderGrey),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    vendor.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => controller.removeFromFavoriteInPage(vendor),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: VendorView.primaryLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          vendor.category.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VendorView.primaryGreen, letterSpacing: 0.5),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${vendor.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VendorView.textDark)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(vendor.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VendorView.textDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: VendorView.textGrey, size: 14),
                      const SizedBox(width: 4),
                      Text(vendor.location, style: const TextStyle(fontSize: 12, color: VendorView.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(vendor.price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: VendorView.textDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}