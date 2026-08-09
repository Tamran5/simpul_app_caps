import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/values/api_config.dart';

class EditProfileController extends GetxController {
  // ─── Text Controllers ──────────────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final newEmailController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // ─── State ────────────────────────────────────────────────────────
  var isLoading = false.obs;
  var isUploadingPhoto = false.obs;
  var isChangingEmail = false.obs;
  var previewPhotoUrl = ''.obs;

  // ─── OTP Countdown ────────────────────────────────────────────────
  var otpCountdown = 0.obs; // detik tersisa
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    newEmailController.dispose();
    phoneController.dispose();
    otpController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD DATA
  // ═══════════════════════════════════════════════════════════════════

  void _loadCurrentUserData() {
    if (!Get.isRegistered<ProfileController>()) return;
    final profile = Get.find<ProfileController>();
    nameController.text = profile.userName.value;
    emailController.text = profile.userEmail.value;
    phoneController.text = profile.userPhone.value;
    previewPhotoUrl.value = profile.userPhotoUrl.value;
  }

  // ═══════════════════════════════════════════════════════════════════
  // PHOTO UPLOAD — support Web & Mobile
  // ═══════════════════════════════════════════════════════════════════

  Future<void> pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final source = await _showPhotoSourceSheet();
    if (source == null) return;

    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    isUploadingPhoto.value = true;
    try {
      final token = await _getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.profilePhoto),
      )..headers['Authorization'] = 'Bearer $token';

      if (kIsWeb) {
        // Web: baca bytes dari XFile langsung
        final bytes = await picked.readAsBytes();
        final filename = picked.name.isNotEmpty ? picked.name : 'photo.jpg';
        request.files.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: filename),
        );
      } else {
        // Mobile: gunakan path
        request.files.add(
          await http.MultipartFile.fromPath('photo', picked.path),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final newUrl = ApiConfig.resolvePhotoUrl(body['photo_url'] as String?);
        previewPhotoUrl.value = newUrl;
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().userPhotoUrl.value = newUrl;
        }
        Get.snackbar(
          'Foto Diperbarui ✓',
          'Foto profilmu berhasil disimpan.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF3D6B5F),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Gagal Mengunggah',
          body['message'] ?? 'Terjadi kesalahan saat mengunggah foto.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat menghubungi server.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<ImageSource?> _showPhotoSourceSheet() async {
    // Web hanya support gallery
    if (kIsWeb) return ImageSource.gallery;

    return await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    onTap: () => Get.back(result: ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onTap: () => Get.back(result: ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SAVE PROFILE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> simpanPerubahan({String? otpCode}) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Nama tidak boleh kosong.',
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    final emailTarget = isChangingEmail.value
        ? newEmailController.text.trim()
        : emailController.text.trim();

    if (isChangingEmail.value && emailTarget.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Masukkan alamat email baru.',
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    isLoading.value = true;
    try {
      final token = await _getToken();
      final response = await http
          .post(
            Uri.parse(ApiConfig.updateProfile),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'name': nameController.text.trim(),
              'email': emailTarget,
              'phone': phoneController.text.trim(),
              if (otpCode != null) 'otp': otpCode,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        if (data['status'] == 'require_otp') {
          isLoading.value = false;
          _startOtpCountdown(); // mulai countdown
          _showOtpDialog();
          Get.snackbar(
            'Verifikasi Diperlukan',
            data['message'] ?? 'Cek email lama untuk kode OTP.',
            backgroundColor: const Color(0xFFFFF8EB),
            colorText: const Color(0xFF966C23),
          );
        } else {
          if (Get.isRegistered<ProfileController>()) {
            await Get.find<ProfileController>().fetchUserProfile();
          }
          Get.back();
          Get.snackbar(
            'Tersimpan ✓',
            'Profil berhasil diperbarui.',
            backgroundColor: const Color(0xFF3D6B5F),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
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
        'Tidak dapat menghubungi server.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── OTP Countdown ─────────────────────────────────────────────────

  /// Mulai countdown 5 menit (300 detik) sesuai expiry backend
  void _startOtpCountdown() {
    _countdownTimer?.cancel();
    otpCountdown.value = 300; // 5 menit
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (otpCountdown.value <= 0) {
        t.cancel();
      } else {
        otpCountdown.value--;
      }
    });
  }

  String get otpCountdownText {
    final m = (otpCountdown.value ~/ 60).toString().padLeft(2, '0');
    final s = (otpCountdown.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get canResendOtp => otpCountdown.value == 0;

  /// Kirim ulang OTP (panggil simpanPerubahan tanpa otpCode)
  Future<void> resendOtp() async {
    if (!canResendOtp) return;
    Get.back(); // tutup dialog lama
    await simpanPerubahan();
  }

  // ─── OTP Dialog ────────────────────────────────────────────────────

  void _showOtpDialog() {
    otpController.clear();
    Get.dialog(_OtpDialog(controller: this), barrierDismissible: false);
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }
}

// ─── OTP Dialog Widget ────────────────────────────────────────────────────────

class _OtpDialog extends StatelessWidget {
  const _OtpDialog({required this.controller});
  final EditProfileController controller;

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
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: Color(0xFFC8A96A),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Verifikasi Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                'Masukkan 6-digit kode yang dikirim ke ${controller.emailController.text}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Color(0xFF111827),
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '······',
                hintStyle: TextStyle(
                  letterSpacing: 8,
                  color: Colors.grey.shade300,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F6F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF3D6B5F),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Countdown + Resend ──
            Obx(() {
              final expired = controller.otpCountdown.value == 0;
              return Column(
                children: [
                  if (!expired)
                    Text(
                      'Kode kedaluwarsa dalam ${controller.otpCountdownText}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    )
                  else
                    const Text(
                      'Kode sudah kedaluwarsa.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                    ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: expired ? controller.resendOtp : null,
                    child: Text(
                      'Kirim ulang OTP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: expired
                            ? const Color(0xFF3D6B5F)
                            : const Color(0xFFB0B7C3),
                        decoration: expired ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 20),
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
                    onPressed: () {
                      controller._countdownTimer?.cancel();
                      Get.back();
                    },
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final expired = controller.otpCountdown.value == 0;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: expired
                            ? Colors.grey.shade300
                            : const Color(0xFF3D6B5F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: expired
                          ? null
                          : () {
                              if (controller.otpController.text.length == 6) {
                                controller._countdownTimer?.cancel();
                                Get.back();
                                controller.simpanPerubahan(
                                  otpCode: controller.otpController.text.trim(),
                                );
                              } else {
                                Get.snackbar(
                                  'Perhatian',
                                  'Kode OTP harus 6 digit.',
                                );
                              }
                            },
                      child: const Text(
                        'Verifikasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Photo Source Option ──────────────────────────────────────────────────────

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF2F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF3D6B5F), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D6B5F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
