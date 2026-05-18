import 'package:get/get.dart';

import '../controllers/face_scan_controller.dart';

class FaceScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaceScanController>(
      () => FaceScanController(),
    );
  }
}
