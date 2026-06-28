import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/values/api_config.dart';
import '../../vendor/controllers/vendor_controller.dart'; 

class FavoriteVendorController extends GetxController {
  var favoriteList = <VendorModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavoritesFromDatabase();
  }

  Future<void> fetchFavoritesFromDatabase() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('access_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConfig.favoriteVendors),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> data = decodedData['data'];
          favoriteList.value = data.map((json) => VendorModel.fromJson(json)).toList();
        }
      } else {
        print("Gagal memuat favorit: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetch favorites: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk menghapus langsung dari halaman favorit
  void removeFromFavoriteInPage(VendorModel vendor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('access_token') ?? '';

      // Tembak API toggle untuk menghapusnya di server
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/vendors/${vendor.id}/favorite"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Hapus dari list lokal di layar agar kartu langsung hilang dengan animasi
        favoriteList.remove(vendor);
        
        // Sinkronisasi: Beritahu VendorController utama agar ikon hatinya ikut mati
        if (Get.isRegistered<VendorController>()) {
          final mainController = Get.find<VendorController>();
          final mainVendor = mainController.vendorList.firstWhereOrNull((v) => v.id == vendor.id);
          if (mainVendor != null) mainVendor.isFavorite.value = false;
        }
      }
    } catch (e) {
      print("Error remove favorite: $e");
    }
  }
}