import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/values/api_config.dart';


class JourneyStep {
  final String stepKey;
  final int stepOrder;
  final String category;
  final String title;
  final String subtitle;
  final bool requiresDocument;
  final String targetInstitution;
  final List<String> requirements;
  final List<String> stepByStep;

  RxBool isDone;
  RxBool isLocked;
  RxString documentStatus;
  RxString uploadedFileName;

  // State lokal khusus proses upload sedang berjalan (progress indicator)
  RxBool isUploading = false.obs;

  JourneyStep({
    required this.stepKey,
    required this.stepOrder,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.requiresDocument,
    required this.targetInstitution,
    required this.requirements,
    required this.stepByStep,
    bool isDone = false,
    bool isLocked = false,
    String documentStatus = 'empty',
    String uploadedFileName = '',
  })  : isDone = isDone.obs,
        isLocked = isLocked.obs,
        documentStatus = documentStatus.obs,
        uploadedFileName = uploadedFileName.obs;

  factory JourneyStep.fromJson(Map<String, dynamic> json) {
    return JourneyStep(
      stepKey: json['step_key'] ?? '',
      stepOrder: (json['step_order'] ?? 0) as int,
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      requiresDocument: json['requires_document'] ?? true,
      targetInstitution: json['target_institution'] ?? '',
      requirements: (json['requirements'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      stepByStep: (json['step_by_step'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isDone: json['is_done'] ?? false,
      isLocked: json['is_locked'] ?? false,
      documentStatus: json['document_status'] ?? 'empty',
      uploadedFileName: json['document_name'] ?? '',
    );
  }
}



class PartnerJourneyStep {
  final String stepKey;
  final int stepOrder;
  final String category;
  final String title;
  final String subtitle;
  final bool requiresDocument;
  final String targetInstitution;
  final bool isDone;
  final bool isLocked;
  final String documentStatus; // 'empty' | 'uploaded' — nama file tidak dikirim server (privasi)

  PartnerJourneyStep({
    required this.stepKey,
    required this.stepOrder,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.requiresDocument,
    required this.targetInstitution,
    required this.isDone,
    required this.isLocked,
    required this.documentStatus,
  });

  factory PartnerJourneyStep.fromJson(Map<String, dynamic> json) {
    return PartnerJourneyStep(
      stepKey: json['step_key'] ?? '',
      stepOrder: (json['step_order'] ?? 0) as int,
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      requiresDocument: json['requires_document'] ?? true,
      targetInstitution: json['target_institution'] ?? '',
      isDone: json['is_done'] ?? false,
      isLocked: json['is_locked'] ?? false,
      documentStatus: json['document_status'] ?? 'empty',
    );
  }
}

// ─── TODO CONTROLLER ────────────────────────────────────────────────────────

class TodoController extends GetxController {
  // Profil (ditampilkan di header — diisi dari response /api/journey)
  var userReligion = ''.obs;
  var userGender = ''.obs;
  var isOutOfTown = false.obs;
  var isForeigner = false.obs;

  var journeySteps = <JourneyStep>[].obs;

  // ─── Partner View (read-only) ────────────────────────────────────────
  var viewMode = 'mine'.obs;          // 'mine' | 'partner'
  var isSynced = false.obs;
  var partnerName = ''.obs;
  var partnerSteps = <PartnerJourneyStep>[].obs;
  var isPartnerLoading = false.obs;
  var hasPartnerError = false.obs;
  var partnerErrorMessage = ''.obs;
  var partnerTotalSteps = 0.obs;
  var partnerDoneSteps = 0.obs;
  double get partnerProgressPercent =>
      partnerTotalSteps.value == 0 ? 0.0 : partnerDoneSteps.value / partnerTotalSteps.value;

  // ─── State UI ─────────────────────────────────────────────────────────
  var isLoading = true.obs;       // initial load (skeleton)
  var isRefreshing = false.obs;   // pull-to-refresh, tidak full-skeleton
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var totalSteps = 0.obs;
  var doneSteps = 0.obs;
  double get progressPercent =>
      totalSteps.value == 0 ? 0.0 : doneSteps.value / totalSteps.value;

  // ─── Lihat Dokumen ───────────────────────────────────────────────────
  var isOpeningDocument = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJourney();
  }

  // ═══════════════════════════════════════════════════════════════════
  // FETCH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> fetchJourney({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    hasError.value = false;
    errorMessage.value = '';

    try {
      final token = await _getToken();
      final response = await http
          .get(Uri.parse(ApiConfig.journeyList), headers: _authHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;

        final profile = data['profile'] as Map<String, dynamic>? ?? {};
        userReligion.value = profile['religion'] ?? '';
        userGender.value = profile['gender'] ?? '';
        isOutOfTown.value = profile['is_out_of_town'] ?? false;
        isForeigner.value = profile['is_foreigner'] ?? false;

        final stepsJson = (data['steps'] as List<dynamic>? ?? []);
        journeySteps.value =
            stepsJson.map((e) => JourneyStep.fromJson(e as Map<String, dynamic>)).toList();

        totalSteps.value = (data['total_steps'] ?? journeySteps.length) as int;
        doneSteps.value = (data['done_steps'] ?? 0) as int;
      } else if (response.statusCode == 401) {
        Get.offAllNamed('/login');
      } else {
        _setError('Gagal memuat checklist (${response.statusCode}).');
      }
    } on TimeoutException {
      _setError('Koneksi timeout. Periksa jaringan Anda.');
    } catch (_) {
      _setError('Tidak dapat memuat data. Cek koneksi internet.');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
  }

  // ═══════════════════════════════════════════════════════════════════
  // PARTNER VIEW (read-only)
  // ═══════════════════════════════════════════════════════════════════

  void switchViewMode(String mode) {
    viewMode.value = mode;
    if (mode == 'partner' && partnerSteps.isEmpty && !isPartnerLoading.value) {
      fetchPartnerJourney();
    }
  }

  Future<void> fetchPartnerJourney() async {
    isPartnerLoading.value = true;
    hasPartnerError.value = false;
    partnerErrorMessage.value = '';

    try {
      final token = await _getToken();
      final response = await http
          .get(Uri.parse(ApiConfig.journeyPartner), headers: _authHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;

        isSynced.value = true;
        partnerName.value = data['partner_name'] ?? '';
        final stepsJson = (data['steps'] as List<dynamic>? ?? []);
        partnerSteps.value =
            stepsJson.map((e) => PartnerJourneyStep.fromJson(e as Map<String, dynamic>)).toList();
        partnerTotalSteps.value = (data['total_steps'] ?? partnerSteps.length) as int;
        partnerDoneSteps.value = (data['done_steps'] ?? 0) as int;
      } else if (response.statusCode == 400) {
        isSynced.value = false;
      } else if (response.statusCode == 401) {
        Get.offAllNamed('/login');
      } else {
        hasPartnerError.value = true;
        partnerErrorMessage.value = 'Gagal memuat progres pasangan (${response.statusCode}).';
      }
    } on TimeoutException {
      hasPartnerError.value = true;
      partnerErrorMessage.value = 'Koneksi timeout. Periksa jaringan Anda.';
    } catch (_) {
      hasPartnerError.value = true;
      partnerErrorMessage.value = 'Tidak dapat memuat data pasangan.';
    } finally {
      isPartnerLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOCK CHECK
  // ═══════════════════════════════════════════════════════════════════

  bool isStepLocked(JourneyStep step) => step.isLocked.value;

  // ═══════════════════════════════════════════════════════════════════
  // TOGGLE STATUS SELESAI
  // ═══════════════════════════════════════════════════════════════════

  Future<void> toggleStep(JourneyStep step) async {
    if (step.isLocked.value && !step.isDone.value) {
      Get.snackbar(
        'Aksi Ditolak',
        'Sistem mendeteksi urutan berkas di atasnya belum terpenuhi.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (step.requiresDocument && !step.isDone.value && step.documentStatus.value == 'empty') {
      Get.snackbar(
        'Dokumen Diperlukan',
        'Unggah dokumen terlebih dahulu untuk menandai langkah ini selesai.',
        backgroundColor: const Color(0xFFC8A96A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Optimistic update
    final previousValue = step.isDone.value;
    step.isDone.value = !previousValue;
    _recountDoneSteps();
    _recalculateLocksLocally();

    try {
      final token = await _getToken();
      final response = await http
          .post(Uri.parse(ApiConfig.journeyToggle(step.stepKey)),
              headers: _authHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        step.isDone.value = previousValue;
        _recountDoneSteps();
        _recalculateLocksLocally();

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        Get.snackbar(
          'Gagal',
          body['message'] ?? 'Status tidak dapat diperbarui.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        unawaited(fetchJourney(isRefresh: true));
      }
    } catch (_) {
      step.isDone.value = previousValue;
      _recountDoneSteps();
      _recalculateLocksLocally();
      Get.snackbar(
        'Gagal Terhubung',
        'Perubahan tidak tersimpan. Periksa koneksi internet Anda.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _recountDoneSteps() {
    doneSteps.value = journeySteps.where((s) => s.isDone.value).length;
  }

  void _recalculateLocksLocally() {
    for (int i = 0; i < journeySteps.length; i++) {
      if (i == 0) {
        journeySteps[i].isLocked.value = false;
      } else {
        journeySteps[i].isLocked.value = !journeySteps[i - 1].isDone.value;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPLOAD DOKUMEN
  // ═══════════════════════════════════════════════════════════════════

  Future<void> uploadDocument(JourneyStep step) async {
    if (isStepLocked(step)) {
      Get.snackbar(
        'Langkah Terkunci',
        'Anda wajib menyelesaikan dan mengunggah berkas pada langkah sebelumnya terlebih dahulu agar tertib administrasi.',
        backgroundColor: const Color(0xFFC8A96A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    if (pickedFile.path == null) {
      Get.snackbar('Gagal', 'Berkas tidak dapat dibaca.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    step.isUploading.value = true;
    try {
      final token = await _getToken();
      final uri = Uri.parse(ApiConfig.journeyUpload(step.stepKey));
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path!));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;

        step.documentStatus.value = 'uploaded';
        step.uploadedFileName.value = data['document_name'] ?? pickedFile.name;
        step.isDone.value = true;
        _recountDoneSteps();
        _recalculateLocksLocally();

        Get.snackbar(
          'Berhasil ✓',
          'Berkas berhasil diunggah.',
          backgroundColor: const Color(0xFF596E63),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        unawaited(fetchJourney(isRefresh: true));
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        Get.snackbar(
          'Gagal Mengunggah',
          body['message'] ?? 'Berkas tidak dapat diunggah.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on TimeoutException {
      Get.snackbar('Timeout', 'Unggah berkas memakan waktu terlalu lama.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (_) {
      Get.snackbar(
        'Gagal Terhubung',
        'Tidak dapat mengunggah berkas. Periksa koneksi internet Anda.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      step.isUploading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LIHAT DOKUMEN YANG SUDAH DIUNGGAH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> viewDocument(JourneyStep step) async {
    if (step.documentStatus.value != 'uploaded') return;

    isOpeningDocument.value = true;
    try {
      final token = await _getToken();
      final response = await http
          .get(
            Uri.parse(ApiConfig.journeyDocument(step.stepKey)),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        Get.snackbar(
          'Gagal',
          'Dokumen tidak dapat dimuat.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final contentType = response.headers['content-type'] ?? '';
      final fileName = step.uploadedFileName.value.isNotEmpty
          ? step.uploadedFileName.value
          : 'dokumen_${step.stepKey}';

      // Gambar: tampilkan langsung dalam dialog, tidak perlu buka aplikasi lain
      if (contentType.startsWith('image/')) {
        Get.dialog(_DocumentPreviewDialog(bytes: response.bodyBytes, fileName: fileName));
        return;
      }

      // PDF / lainnya: simpan sementara lalu buka dengan aplikasi bawaan sistem
      final dir = await getTemporaryDirectory();
      final safeName = fileName.contains('.') ? fileName : '$fileName.pdf';
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(response.bodyBytes);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        Get.snackbar(
          'Tidak Dapat Dibuka',
          'Pastikan ada aplikasi pembaca PDF/gambar terpasang di perangkat.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Gagal Terhubung',
        'Tidak dapat memuat dokumen. Periksa koneksi internet Anda.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isOpeningDocument.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // INFO MODAL
  // ═══════════════════════════════════════════════════════════════════

  void showStepInfo(JourneyStep step) {
    Get.dialog(_StepInfoDialog(step: step));
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG: Preview Dokumen Gambar
// ─────────────────────────────────────────────────────────────────────────────

class _DocumentPreviewDialog extends StatelessWidget {
  const _DocumentPreviewDialog({required this.bytes, required this.fileName});
  final List<int> bytes;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          InteractiveViewer(
            child: Image.memory(
              Uint8List.fromList(bytes),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG INFO LANGKAH
// ─────────────────────────────────────────────────────────────────────────────

class _StepInfoDialog extends StatelessWidget {
  const _StepInfoDialog({required this.step});
  final JourneyStep step;

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color textDark = Color(0xFF333333);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: textGrey),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Institusi: ${step.targetInstitution}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryGreen),
              ),
              const Divider(height: 24, color: borderGrey),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Persyaratan Dokumen:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                      const SizedBox(height: 6),
                      ...step.requirements.map((req) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                                Expanded(
                                    child: Text(req,
                                        style: const TextStyle(fontSize: 12, color: textGrey, height: 1.4))),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                      const Text('Prosedur Pelaksanaan:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                      const SizedBox(height: 6),
                      ...step.stepByStep.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$idx. ',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen)),
                              Expanded(
                                  child: Text(entry.value,
                                      style: const TextStyle(fontSize: 12, color: textGrey, height: 1.4))),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Saya Mengerti',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}