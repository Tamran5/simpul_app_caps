import 'package:get/get.dart';

import '../controllers/connect_partner_controller.dart';

class ConnectPartnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectPartnerController>(
      () => ConnectPartnerController(),
    );
  }
}
