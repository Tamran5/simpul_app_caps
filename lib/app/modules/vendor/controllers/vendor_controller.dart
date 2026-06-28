import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/values/api_config.dart';
import '../../favorite_vendor/controllers/favorite_vendor_controller.dart';

// --- MODEL PAKET HARGA ---
class VendorPackage {
  final String title;
  final String subtitle;
  final String price;
  final String? badgeText;
  final List<String> features;

  VendorPackage({
    required this.title,
    required this.subtitle,
    required this.price,
    this.badgeText,
    required this.features,
  });

  factory VendorPackage.fromJson(Map<String, dynamic> json) {
    return VendorPackage(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      price: json['price'] ?? '',
      badgeText: json['badgeText'],
      features: List<String>.from(json['features'] ?? []),
    );
  }
}

// --- MODEL VENDOR UTAMA ---
class VendorModel {
  final String id;
  final String name;
  final String category;
  final String location;
  final String price;
  final double rating;
  final String imageUrl;
  RxBool isFavorite;
  
  // Data Dinamis Baru
  final String philosophy;
  final List<String> portfolioUrls;
  final List<VendorPackage> packages;

  final String whatsapp;

  VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.philosophy,
    required this.portfolioUrls,
    required this.packages,
    required this.whatsapp,
    bool favorite = false,
  }) : isFavorite = favorite.obs;

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    var packagesJson = json['packages'] as List? ?? [];
    List<VendorPackage> parsedPackages = packagesJson.map((p) => VendorPackage.fromJson(p)).toList();

    return VendorModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Tanpa Nama',
      category: json['category'] ?? 'Lainnya',
      location: json['location'] ?? '',
      price: json['price'] ?? '',
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/500x300.png?text=No+Image',
      
      philosophy: json['philosophy'] ?? 'Belum ada deskripsi untuk vendor ini.',
      portfolioUrls: List<String>.from(json['portfolio_urls'] ?? []),
      packages: parsedPackages,
      whatsapp: json['whatsapp']?.toString() ?? '',
      favorite: json['is_favorite'] ?? false,
    );
  }
}

// --- CONTROLLER ---
class VendorController extends GetxController {
  final searchQuery = ''.obs;
  final List<String> categories = ['Semua Kategori', 'Photography', 'Catering', 'Decoration', 'MUA', 'Venue'];
  var selectedCategory = 'Semua Kategori'.obs;

  var vendorList = <VendorModel>[].obs;
  var isLoading = true.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchVendorsFromBackend(); 
  }

  Future<void> fetchVendorsFromBackend() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('access_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConfig.vendors),
        headers: {
          "Content-Type": "application/json",
          // Token tetap dikirim agar Flask tahu siapa yang sedang membuka aplikasi
          "Authorization": "Bearer $token", 
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> data = decodedData['data'];
          

          vendorList.value = data.map((json) => VendorModel.fromJson(json)).toList();
        }
      } else if (response.statusCode == 401) {
        Get.snackbar("Akses Terkunci", "Silakan login terlebih dahulu.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFavorite(VendorModel vendor) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('access_token') ?? '';

    final response = await http.post(
      Uri.parse("${ApiConfig.vendors}/${vendor.id}/favorite"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedData = jsonDecode(response.body);
      vendor.isFavorite.value = decodedData['is_favorite'];

      // --- NOTIF MUNCUL DI ATAS ---
      Get.snackbar(
        vendor.isFavorite.value ? "Ditambahkan ke Favorit" : "Dihapus dari Favorit",
        vendor.isFavorite.value
            ? "${vendor.name} berhasil disimpan ke daftar favorit."
            : "${vendor.name} dihapus dari daftar favorit.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: vendor.isFavorite.value ? Colors.green[600] : Colors.grey[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: Icon(
          vendor.isFavorite.value ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
        duration: const Duration(seconds: 2),
      );

      if (Get.isRegistered<FavoriteVendorController>()) {
        Get.find<FavoriteVendorController>().fetchFavoritesFromDatabase();
      }
    }
  } catch (e) {
    print("Error toggle favorite: $e");
  }
}

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  List<VendorModel> get filteredVendors {
    List<VendorModel> filtered = vendorList;
    if (selectedCategory.value != 'Semua Kategori') {
      filtered = filtered.where((v) => v.category == selectedCategory.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((v) => v.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    return filtered;
  }

}