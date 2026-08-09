import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../../../core/values/api_config.dart';
import '../../favorite_vendor/controllers/favorite_vendor_controller.dart';

// ─── Model Paket Harga ────────────────────────────────────────────────────────

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

  factory VendorPackage.fromJson(Map<String, dynamic> json) => VendorPackage(
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        price: json['price'] ?? '',
        badgeText: json['badgeText'],
        features: List<String>.from(json['features'] ?? []),
      );
}

// ─── Model Vendor ─────────────────────────────────────────────────────────────

class VendorModel {
  final String id;
  final String name;
  final String category;
  final String location;
  final String price;
  final double rating;
  final String imageUrl;
  final String philosophy;
  final List<String> portfolioUrls;
  final List<VendorPackage> packages;
  final String whatsapp;
  final double? latitude;
  final double? longitude;
  RxBool isFavorite;

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
    this.latitude,
    this.longitude,
    bool favorite = false,
  }) : isFavorite = favorite.obs;

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final packagesJson = json['packages'] as List? ?? [];

    double? parseCoord(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    return VendorModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Tanpa Nama',
      category: json['category'] ?? 'Lainnya',
      location: json['location'] ?? '',
      price: json['price'] ?? '',
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : 0.0,
      imageUrl: json['image_url'] ?? '',
      philosophy:
          json['philosophy'] ?? 'Belum ada deskripsi untuk vendor ini.',
      portfolioUrls: List<String>.from(json['portfolio_urls'] ?? []),
      packages:
          packagesJson.map((p) => VendorPackage.fromJson(p)).toList(),
      whatsapp: json['whatsapp']?.toString() ?? '',
      latitude: parseCoord(json['latitude']),
      longitude: parseCoord(json['longitude']),
      favorite: json['is_favorite'] ?? false,
    );
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class VendorController extends GetxController {
  final searchQuery      = ''.obs;
  final selectedCategory = 'Semua Kategori'.obs;
  final vendorList       = <VendorModel>[].obs;
  final isLoading        = true.obs;

  // ── Search ────────────────────────────────────────────────────────────────
  final TextEditingController searchTextController = TextEditingController();
  final RxBool isSearchFocused = false.obs;
  final RxBool isSearching = false.obs; // true while debounce is pending
  Timer? _debounce;

  // ── Lokasi ───────────────────────────────────────────────────────────────
  final Rxn<Position> userPosition   = Rxn<Position>();
  final RxString userLocationLabel   = 'Mendeteksi lokasi...'.obs;
  final RxBool isLocationLoading     = false.obs;
  final RxBool locationEnabled       = false.obs;
  final RxBool sortByDistance        = false.obs;

  final List<String> categories = [
    'Semua Kategori',
    'Photography',
    'Catering',
    'Decoration',
    'MUA',
    'Venue',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchVendors();
    detectUserLocation(silent: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  // ── Public alias — dipakai oleh RefreshIndicator di view ──────────────────
  Future<void> fetchVendors() => fetchVendorsFromBackend();

  // ── Fetch dari backend ────────────────────────────────────────────────────
  Future<void> fetchVendorsFromBackend() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConfig.vendors),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == 'success') {
          final List<dynamic> data = decoded['data'];
          vendorList.value =
              data.map((j) => VendorModel.fromJson(j)).toList();
        }
      } else if (response.statusCode == 401) {
        Get.snackbar('Akses Terkunci', 'Silakan login terlebih dahulu.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Gagal', 'Tidak dapat memuat data vendor.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Toggle favorit ────────────────────────────────────────────────────────
  Future<void> toggleFavorite(VendorModel vendor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final response = await http.post(
        Uri.parse('${ApiConfig.vendors}/${vendor.id}/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        vendor.isFavorite.value = data['is_favorite'] as bool? ?? false;

        Get.snackbar(
          vendor.isFavorite.value
              ? 'Ditambahkan ke Favorit'
              : 'Dihapus dari Favorit',
          vendor.isFavorite.value
              ? '${vendor.name} disimpan ke daftar favorit.'
              : '${vendor.name} dihapus dari daftar favorit.',
          snackPosition: SnackPosition.TOP,
          backgroundColor:
              vendor.isFavorite.value ? const Color(0xFF3D6B5F) : Colors.grey.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: Icon(
            vendor.isFavorite.value
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 2),
        );

        if (Get.isRegistered<FavoriteVendorController>()) {
          Get.find<FavoriteVendorController>().fetchFavoritesFromDatabase();
        }
      }
    } catch (_) {
      Get.snackbar('Error', 'Gagal mengubah status favorit.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // ── Category ───────────────────────────────────────────────────────────────
  void changeCategory(String category) => selectedCategory.value = category;

  // ── Search (debounced) ───────────────────────────────────────────────────
  void onSearchChanged(String value) {
    isSearching.value = true;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = value.trim();
      isSearching.value = false;
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchTextController.clear();
    searchQuery.value = '';
    isSearching.value = false;
  }

  // ── Lokasi otomatis ───────────────────────────────────────────────────────
  Future<void> detectUserLocation({bool silent = false}) async {
    isLocationLoading.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        userLocationLabel.value = 'Lokasi nonaktif';
        locationEnabled.value = false;
        if (!silent) {
          Get.snackbar('Lokasi Nonaktif', 'Aktifkan GPS untuk melihat vendor terdekat.',
              backgroundColor: Colors.orange, colorText: Colors.white);
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          userLocationLabel.value = 'Izin lokasi ditolak';
          locationEnabled.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        userLocationLabel.value = 'Izin lokasi diblokir';
        locationEnabled.value = false;
        if (!silent) {
          Get.snackbar(
            'Izin Diblokir',
            'Aktifkan izin lokasi lewat pengaturan aplikasi untuk melihat vendor terdekat.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 12));

      userPosition.value = position;
      locationEnabled.value = true;
      sortByDistance.value = true;

      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final area = (p.subLocality != null && p.subLocality!.isNotEmpty)
              ? p.subLocality
              : p.locality;
          userLocationLabel.value =
              area?.isNotEmpty == true ? area! : (p.locality ?? 'Lokasi ditemukan');
        } else {
          userLocationLabel.value = 'Lokasi ditemukan';
        }
      } catch (_) {
        userLocationLabel.value = 'Lokasi ditemukan';
      }
    } catch (_) {
      userLocationLabel.value = 'Gagal mendeteksi lokasi';
      locationEnabled.value = false;
      if (!silent) {
        Get.snackbar('Error', 'Tidak dapat mengambil lokasi kamu.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } finally {
      isLocationLoading.value = false;
    }
  }

  /// Jarak vendor dari posisi user (km), null jika data tidak tersedia.
  double? distanceKmFor(VendorModel vendor) {
    final pos = userPosition.value;
    if (pos == null || vendor.latitude == null || vendor.longitude == null) {
      return null;
    }
    final meters = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      vendor.latitude!,
      vendor.longitude!,
    );
    return meters / 1000;
  }

  void toggleSortByDistance() {
    if (userPosition.value == null) {
      detectUserLocation();
      return;
    }
    sortByDistance.value = !sortByDistance.value;
  }

  // ── Hasil gabungan: filter kategori + search + urutan jarak ────────────────
  List<VendorModel> get filteredVendors {
    var list = vendorList.toList();

    if (selectedCategory.value != 'Semua Kategori') {
      list = list.where((v) => v.category == selectedCategory.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((v) {
        return v.name.toLowerCase().contains(q) ||
            v.location.toLowerCase().contains(q) ||
            v.category.toLowerCase().contains(q);
      }).toList();
    }

    if (sortByDistance.value && userPosition.value != null) {
      list.sort((a, b) {
        final da = distanceKmFor(a);
        final db = distanceKmFor(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    }

    return list;
  }
}