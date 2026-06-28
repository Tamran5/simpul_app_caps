import 'package:get/get.dart';

import '../controllers/legal_detail_controller.dart';

class LegalDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LegalDetailController>(
      () => LegalDetailController(),
    );
  }
}
