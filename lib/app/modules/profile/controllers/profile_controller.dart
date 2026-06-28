import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/controllers/home_controller.dart';
import '../../../core/values/api_config.dart';

class ProfileController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────
  var isLoading     = false.obs;
  var userName      = ''.obs;
  var userEmail     = ''.obs;
  var userPhone     = ''.obs;
  var userPhotoUrl  = ''.obs;

  // ─── Pair / Sync ──────────────────────────────────────────────────
  var myUniqueCode  = ''.obs;
  var syncStatus    = 'none'.obs;
  var isSynced      = false.obs;
  var partnerName   = ''.obs;
  var weddingDate   = ''.obs;

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

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.profile),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body) as Map)['data'] as Map;

        userName.value     = data['name']         ?? '';
        userEmail.value    = data['email']        ?? '';
        userPhone.value    = data['phone']        ?? '';
        userPhotoUrl.value = data['photo_url']    ?? '';
        myUniqueCode.value = data['my_code']      ?? data['unique_code'] ?? '';
        syncStatus.value   = data['sync_status']  ?? 'none';
        isSynced.value     = syncStatus.value == 'synced';
        partnerName.value  = data['partner_name'] ?? '';
        weddingDate.value  = data['wedding_date'] ?? '';

        if (syncStatus.value == 'pending_received') {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => tampilkanDialogPersetujuan());
        }
      } else if (response.statusCode == 401) {
        await _clearAndLogout();
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat memuat profil. Cek koneksi internet.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // PHOTO
  // ═══════════════════════════════════════════════════════════════════

  /// Buka picker foto (integrasikan image_picker sesuai kebutuhan)
  void changePhoto() {
    // TODO: tambahkan image_picker + upload ke ApiConfig.profilePhoto
    Get.snackbar('Segera Hadir', 'Fitur ganti foto sedang disiapkan.',
        backgroundColor: const Color(0xFF3D6B5F), colorText: Colors.white);
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
  // PAIRING (dipertahankan untuk referensi HomeController)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> kirimPermintaanSinkronisasi() async {
    final code = kodePasanganController.text.trim();
    if (code.isEmpty) return;

    isLoading.value = true;
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(ApiConfig.connectPartner),
        headers: _headers(token!),
        body: jsonEncode({'partner_code': code}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map;
      if (response.statusCode == 200) {
        kodePasanganController.clear();
        await fetchUserProfile();
        Get.snackbar('Berhasil ✓', data['message'] ?? 'Permintaan terkirim.',
            backgroundColor: const Color(0xFF3D6B5F), colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', data['message'] ?? 'Terjadi kesalahan.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Error', 'Gagal menghubungi server.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
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
      final token = await _getToken();
      await http.post(
        Uri.parse(ApiConfig.respondPartner),
        headers: _headers(token!),
        body: jsonEncode({'action': action}),
      ).timeout(const Duration(seconds: 15));

      await fetchUserProfile();
      Get.snackbar(
        action == 'accept' ? 'Terhubung! 💕' : 'Ditolak',
        action == 'accept'
            ? 'Kamu dan $partnerName kini merencanakan bersama.'
            : 'Permintaan sinkronisasi dibatalkan.',
        backgroundColor: action == 'accept'
            ? const Color(0xFF3D6B5F)
            : Colors.grey.shade700,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar('Error', 'Terjadi kesalahan koneksi.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
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

    // Tentukan initialDate yang aman (tidak boleh < firstDate)
    DateTime initialDate = tomorrow;
    if (weddingDate.value.isNotEmpty) {
      // Coba parse dari HomeController jika tersedia
      if (Get.isRegistered<HomeController>()) {
        final target = Get.find<HomeController>().targetDate;
        if (target != null && target.isAfter(DateTime.now())) {
          initialDate = target;
        }
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tomorrow,      // ← tidak bisa pilih hari ini/lampau
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
                foregroundColor: const Color(0xFF3D6B5F)),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      // Format tampilan
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      weddingDate.value =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';

      // Sinkron ke HomeController jika ada
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().updateWeddingDate(picked);
      }
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
        title: const Text('Keluar?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Kamu akan keluar dari akun Simpul. Yakin?',
            style: TextStyle(color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Keluar',
                style: TextStyle(color: Colors.white)),
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed('/login');
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
                  color: Color(0xFFFFF0F0), shape: BoxShape.circle),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.redAccent, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Ada Ajakan Masuk 💌',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827))),
            const SizedBox(height: 8),
            Text(
              '$senderName mengajakmu merencanakan pernikahan bersama di Simpul.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFEEEEEE), width: 1.5),
                    ),
                    onPressed: onReject,
                    child: const Text('Tolak',
                        style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.bold)),
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
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onAccept,
                    child: const Text('Terima 💕',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
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