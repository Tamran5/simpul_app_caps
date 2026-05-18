import 'package:get/get.dart';

// Model Data Vendor
class VendorModel {
  final String id;
  final String name;
  final String category;
  final String location;
  final String price;
  final double rating;
  final String imageUrl;
  RxBool isFavorite;

  VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    bool favorite = false,
  }) :  isFavorite = favorite.obs;
}

class VendorController extends GetxController {
  final searchQuery = ''.obs;
  
  // Kategori Vendor
  final List<String> categories = ['Semua Kategori', 'Catering', 'Decoration', 'Photography', 'MUA'];
  var selectedCategory = 'Semua Kategori'.obs;

  // Data Dummy Vendor
  var vendorList = <VendorModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyVendors();
  }

  void _loadDummyVendors() {
    vendorList.addAll([
      VendorModel(
        id: '1',
        name: 'Rasa Nusantara',
        category: 'Catering',
        location: 'Jakarta Selatan',
        price: 'Mulai dari Rp 150k /pax',
        rating: 4.9,
        // Menggunakan placeholder image yang aman
        imageUrl: 'https://picsum.photos/seed/catering/500/300', 
        favorite: true,
      ),
      VendorModel(
        id: '2',
        name: 'Lumina Studios',
        category: 'Photography',
        location: 'Based in Bali, Available Worldwide',
        price: 'Mulai dari Rp 15.000k',
        rating: 4.8,
        imageUrl: 'https://picsum.photos/seed/photo/500/300',
      ),
      VendorModel(
        id: '3',
        name: 'Sekar Kedaton Decor',
        category: 'Decoration',
        location: 'Yogyakarta',
        price: 'Mulai dari Rp 25.000k',
        rating: 4.7,
        imageUrl: 'https://picsum.photos/seed/decor/500/300',
      ),
    ]);
  }

  // Fungsi mengubah kategori
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  // Fungsi mendapatkan data yang sudah difilter
  List<VendorModel> get filteredVendors {
    List<VendorModel> filtered = vendorList;
    
    // Filter Kategori
    if (selectedCategory.value != 'Semua Kategori') {
      filtered = filtered.where((v) => v.category == selectedCategory.value).toList();
    }
    
    // Pencarian Teks
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((v) => v.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    
    return filtered;
  }

  // Fungsi tekan tombol love/favorit
  void toggleFavorite(VendorModel vendor) {
    vendor.isFavorite.value = !vendor.isFavorite.value;
  }
}