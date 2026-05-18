import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_detail_controller.dart';


class VendorDetailView extends GetView<VendorDetailController> {
  // 2. Constructor bersih TANPA meminta parameter required vendor
  const VendorDetailView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color bgLight = Color(0xFFFBFBFB);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    // 3. Ambil data vendor tunggal secara aman lewat controller
    final vendor = controller.vendor;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          vendor.name, 
          style: const TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(vendor.imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor.category, style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(vendor.location, style: const TextStyle(color: textGrey)),
                  const SizedBox(height: 12),
                  Text(vendor.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text('${vendor.rating}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
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