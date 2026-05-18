import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart'; 
import '../../todo/controllers/todo_controller.dart';       
import '../../vendor/controllers/vendor_controller.dart';   
import '../../edukasi/controllers/edukasi_controller.dart';  

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Controller utama untuk mengatur perpindahan tab index
    Get.lazyPut<HomeController>(() => HomeController());
    
    // SINKRONISASI BINDING: Titipkan controller sub-tab di sini agar siap pakai
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<TodoController>(() => TodoController());
    Get.lazyPut<VendorController>(() => VendorController());
    Get.lazyPut<EdukasiController>(() => EdukasiController());
  }
}