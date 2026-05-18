import 'package:get/get.dart';

class HomeController extends GetxController {
  // Variabel untuk melacak tab mana yang sedang aktif
  var tabIndex = 0.obs;

  var tanggalPernikahan = DateTime(2027, 6, 18).obs;

  void updateJadwalNikah(DateTime tanggalBaru) {
    tanggalPernikahan.value = tanggalBaru;
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}