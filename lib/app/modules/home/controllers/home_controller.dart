import 'package:get/get.dart';

class HomeController extends GetxController {
  // Variabel untuk melacak tab mana yang sedang aktif
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}