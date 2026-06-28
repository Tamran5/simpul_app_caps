import 'package:get/get.dart';

import '../controllers/favorite_vendor_controller.dart';

class FavoriteVendorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteVendorController>(
      () => FavoriteVendorController(),
    );
  }
}
