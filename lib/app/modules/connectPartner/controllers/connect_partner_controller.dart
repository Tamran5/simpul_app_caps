// controllers/connect_partner_controller.dart

import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart'; // sesuaikan path

class ConnectPartnerController extends GetxController {
  // ── Ambil HomeController yang sudah ada (sudah di-put saat /home dibuka)
  // Jika pengguna baru saja register dan belum ke /home, pakai find+put.
  HomeController get _home => Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  // ── Proxy ke HomeController — View cukup akses via sini ──────────────────

  /// Kode unik milik user saat ini (reaktif, dari backend)
  RxString get myCode => _home.myUniqueCode;

  /// Status loading saat kirim permintaan
  RxBool get isLoading => _home.isPairActionLoading;

  /// TextEditingController input kode pasangan
  get partnerCodeController => _home.pairInputController;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Salin kode unik ke clipboard
  void salinKode() => _home.copyMyCode();

  /// Kirim permintaan hubungkan ke backend
  Future<void> prosesHubungkan() => _home.submitPairRequest();

  /// Lewati — langsung ke beranda tanpa sinkronisasi
  void lewatiSementara() => Get.offAllNamed('/home');

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

  }

}