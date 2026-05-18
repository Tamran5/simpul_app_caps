import 'package:get/get.dart';

import '../controllers/vendor_detail_controller.dart';

class VendorDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorDetailController>(
      () => VendorDetailController(),
    );
  }
}
