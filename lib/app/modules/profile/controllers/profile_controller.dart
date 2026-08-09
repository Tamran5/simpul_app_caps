import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/controllers/home_controller.dart';
import '../../../core/values/api_config.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────
  var isLoading = false.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var userPhotoUrl = ''.obs;

  // ─── Pair / Sync ──────────────────────────────────────────────────
  var myUniqueCode = ''.obs;
  var syncStatus = 'none'.obs;
  var isSynced = false.obs;
  var partnerName = ''.obs;

  // ─── Wedding Date ─────────────────────────────────────────────────

  final RxString _weddingDateLocal = ''.obs;

  /// Getter String biasa (non-reaktif) — aman dipakai di luar Obx,
  /// misal di dalam logic / validasi yang tidak butuh rebuild UI.
  String get weddingDate {
    if (Get.isRegistered<HomeController>()) {
      final homeStr = Get.find<HomeController>().weddingDateStr.value;
      if (homeStr.isNotEmpty) return homeStr;
    }
    return _weddingDateLocal.value;
  }

  /// Getter RxString — WAJIB dipakai di dalam Obx() di UI supaya
  /// widget benar-benar listen ke perubahan dari HomeController.
  /// Kalau HomeController sudah terdaftar, ini akan selalu menunjuk
  /// ke RxString milik HomeController (mirror penuh, bukan copy).
  RxString get weddingDateRx => Get.isRegistered<HomeController>()
      ? Get.find<HomeController>().weddingDateStr
      : _weddingDateLocal;

  final kodePasanganController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  @override
  void onClose() {
    kodePasanganController.dispose();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // FETCH PROFILE
  // ═══════════════════════════════════════════════════════════════════

  Future<String?> _requireToken() async {
    final token = await _getToken();
    if (token == null) {
      await _clearAndLogout();
      return null;
    }
    return token;
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http
          .get(Uri.parse(ApiConfig.profile), headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body) as Map)['data'] as Map;

        userName.value = data['name'] ?? '';
        userEmail.value = data['email'] ?? '';
        userPhone.value = data['phone'] ?? '';
        userPhotoUrl.value = ApiConfig.resolvePhotoUrl(data['photo_url'] as String?);
        myUniqueCode.value = data['my_code'] ?? data['unique_code'] ?? '';
        syncStatus.value = data['sync_status'] ?? 'none';
        isSynced.value = syncStatus.value == 'synced';
        partnerName.value = data['partner_name'] ?? '';

        // FIX: hanya isi fallback lokal. JANGAN timpa HomeController —
        // kalau HomeController sudah ada, dia tetap sumber utama
        // (lihat getter weddingDateRx di atas).
        _weddingDateLocal.value = data['wedding_date'] ?? '';

        if (syncStatus.value == 'pending_received') {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => tampilkanDialogPersetujuan(),
          );
        }
      } else if (response.statusCode == 401) {
        await _clearAndLogout();
      }
    } catch (_) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat memuat profil. Cek koneksi internet.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // PHOTO
  // ═══════════════════════════════════════════════════════════════════

  void changePhoto() {
    // TODO: tambahkan image_picker + upload ke ApiConfig.profilePhoto
    Get.snackbar(
      'Segera Hadir',
      'Fitur ganti foto sedang disiapkan.',
      backgroundColor: const Color(0xFF3D6B5F),
      colorText: Colors.white,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // COPY CODE
  // ═══════════════════════════════════════════════════════════════════

  void copyMyCode() {
    if (myUniqueCode.value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: myUniqueCode.value));
    Get.snackbar(
      'Disalin ✓',
      'Kode ${myUniqueCode.value} berhasil disalin.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF3D6B5F),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAIRING
  // FIX: connectPartner → pairRequest, respondPartner → pairRespond
  // ═══════════════════════════════════════════════════════════════════

  Future<void> kirimPermintaanSinkronisasi() async {
    final code = kodePasanganController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    if (code.length < 6) {
      Get.snackbar(
        'Periksa Kode',
        'Kode pasangan harus 6 karakter.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (code == myUniqueCode.value) {
      Get.snackbar(
        'Oops!',
        'Tidak bisa memasukkan kode milik sendiri.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;
    try {
      final token = await _requireToken();
      if (token == null) return;
      final response = await http
          .post(
            Uri.parse(ApiConfig.pairRequest),
            headers: _headers(token),
            body: jsonEncode({'unique_code': code}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map;
      if (response.statusCode == 200) {
        kodePasanganController.clear();
        await fetchUserProfile();
        Get.snackbar(
          'Berhasil ✓',
          data['message'] ?? 'Permintaan terkirim.',
          backgroundColor: const Color(0xFF3D6B5F),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Terjadi kesalahan.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Gagal menghubungi server.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void tampilkanDialogPersetujuan() {
    if (Get.isDialogOpen == true) return;
    Get.dialog(
      _IncomingPairDialog(
        senderName: partnerName.value,
        onAccept: () {
          Get.back();
          responPermintaan('accept');
        },
        onReject: () {
          Get.back();
          responPermintaan('reject');
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> responPermintaan(String action) async {
    isLoading.value = true;
    try {
      final token = await _requireToken();
      if (token == null) return;

      final response = await http
          .post(
            Uri.parse(ApiConfig.pairRespond),
            headers: _headers(token),
            body: jsonEncode({'action': action}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await fetchUserProfile();
        Get.snackbar(
          action == 'accept' ? 'Terhubung! 💕' : 'Ditolak',
          action == 'accept'
              ? 'Kamu dan ${partnerName.value} kini merencanakan bersama.'
              : 'Permintaan sinkronisasi dibatalkan.',
          backgroundColor: action == 'accept'
              ? const Color(0xFF3D6B5F)
              : Colors.grey.shade700,
          colorText: Colors.white,
        );
      } else {
        final res = jsonDecode(response.body) as Map;
        Get.snackbar(
          'Gagal',
          res['message'] ?? 'Gagal merespons permintaan.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan koneksi.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi unlink yang konsisten dengan HomeController
  Future<void> putusHubungan() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Putus Hubungan?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Semua progres bersama akan terputus. Yakin ingin melanjutkan?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Putus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    try {
      final token = await _getToken();
      final response = await http
          .post(Uri.parse(ApiConfig.pairUnlink), headers: _headers(token!))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await fetchUserProfile();
        Get.snackbar(
          'Koneksi Diputus',
          'Kamu tidak lagi terhubung dengan pasangan.',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        final res = jsonDecode(response.body) as Map;
        Get.snackbar(
          'Gagal',
          res['message'] ?? 'Gagal memutus koneksi.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Gagal memutus koneksi. Cek internet.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // WEDDING DATE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> aturJadwalNikah(BuildContext context) async {
    if (!isSynced.value) return;

    final tomorrow = DateTime.now().add(const Duration(days: 1));

    DateTime initialDate = tomorrow;
    if (Get.isRegistered<HomeController>()) {
      final target = Get.find<HomeController>().targetDate;
      if (target != null && target.isAfter(DateTime.now())) {
        initialDate = target;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tomorrow,
      lastDate: DateTime(2035),
      helpText: 'Pilih tanggal pernikahan',
      cancelText: 'Batal',
      confirmText: 'Simpan',
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3D6B5F),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF111827),
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3D6B5F),
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    // FIX: tidak ada lagi assignment manual ke weddingDate.value di sini.
    // HomeController.updateWeddingDate() yang akan mengubah
    // HomeController.weddingDateStr (source of truth), dan karena
    // weddingDateRx di atas mengarah langsung ke RxString itu,
    // Profile otomatis ikut ter-update di frame yang sama — termasuk
    // optimistic update-nya, tanpa perlu fetchUserProfile() ulang.
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().updateWeddingDate(picked);
    } else {
      // Jaga-jaga kalau entah bagaimana HomeController belum pernah
      // ter-inisialisasi saat Profile dibuka duluan — fallback simpan
      // lokal saja, supaya tidak silent-fail.
      const months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      _weddingDateLocal.value =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════

  void editProfile() => Get.toNamed('/edit-profile');

  // ═══════════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Kamu akan keluar dari akun Simpul. Yakin?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clearAndLogout();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<void> _clearAndLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      if (token.isNotEmpty) {
        await http
            .post(
              Uri.parse(ApiConfig.logout),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG: Incoming Pair
// ─────────────────────────────────────────────────────────────────────────────

class _IncomingPairDialog extends StatelessWidget {
  const _IncomingPairDialog({
    required this.senderName,
    required this.onAccept,
    required this.onReject,
  });

  final String senderName;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.redAccent,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ada Ajakan Masuk 💌',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$senderName mengajakmu merencanakan pernikahan bersama di Simpul.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFEEEEEE),
                        width: 1.5,
                      ),
                    ),
                    onPressed: onReject,
                    child: const Text(
                      'Tolak',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D6B5F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onAccept,
                    child: const Text(
                      'Terima 💕',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
