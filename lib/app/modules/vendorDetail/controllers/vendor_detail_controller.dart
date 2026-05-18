import 'package:get/get.dart';

class VendorDetailController extends GetxController {
  // Tempat menyimpan satu data vendor yang sedang dilihat
  late dynamic vendor; 

  // State khusus halaman detail (misal: 0 = Deskripsi, 1 = Paket Harga, 2 = Ulasan)
  var activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Trik GetX: Menangkap data vendor yang dikirim saat kartu diklik di halaman utama
    if (Get.arguments != null) {
      vendor = Get.arguments;
    }
  }

  void ubahTab(int index) {
    activeTab.value = index;
  }

  void hubungiWhatsApp() {
    // Logika membuka WhatsApp untuk chat vendor terkait
    print("Membuka chat WhatsApp dengan Vendor: ${vendor.name}");
  }
}