import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/values/api_config.dart';

class HomeController extends GetxController {
  // ─── Tab Navigation ───────────────────────────────────────────────
  var tabIndex = 0.obs;

  // ─── Loading States ───────────────────────────────────────────────
  var isLoading           = false.obs;
  var isPageLoading       = true.obs;
  var isPairActionLoading = false.obs;
  var isNotifLoading      = false.obs;

  // ─── Sync / Pair ─────────────────────────────────────────────────
  var isSynced     = false.obs;
  var syncStatus   = 'none'.obs;
  var myUniqueCode = ''.obs;

  // ─── User & Partner Info ──────────────────────────────────────────
  var myName          = ''.obs;
  var myInitials      = ''.obs;
  var myPhotoUrl      = ''.obs;
  var partnerName     = ''.obs;
  var partnerInitials = ''.obs;
  var partnerPhotoUrl = ''.obs;

  // ─── Wedding Info ─────────────────────────────────────────────────
  var weddingDateStr   = ''.obs;
  var daysRemaining    = 0.obs;
  var hoursRemaining   = 0.obs;
  var minutesRemaining = 0.obs;
  var secondsRemaining = 0.obs;

  // ─── Progress ─────────────────────────────────────────────────────
  var totalTasks           = 0.obs;
  var completedTasks       = 0.obs;
  var legalProgress        = 0.0.obs;
  var taskProgress         = 0.0.obs;
  var currentLegalLevel    = ''.obs;
  var currentLegalDoc      = ''.obs;
  var legalProgressPercent = 0.obs;

  // ─── Notifications ────────────────────────────────────────────────
  var hasUnreadNotif   = false.obs;
  var unreadNotifCount = 0.obs;
  var notifications    = <Map<String, dynamic>>[].obs;

  // ─── Internal ─────────────────────────────────────────────────────
  DateTime? _targetDate;
  Timer?    _countdownTimer;

  DateTime? get targetDate => _targetDate;

  final pairInputController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    _loadAll();
    _startCountdownTicker();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    pairInputController.dispose();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════

  void changeTabIndex(int index) => tabIndex.value = index;

  Future<void> refreshAll() => _loadAll();

  // ═══════════════════════════════════════════════════════════════════
  // LOADERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadAll() async {
    isPageLoading.value = true;
    await Future.wait([_fetchHomeData(), _fetchNotifStatus()]);
    isPageLoading.value = false;
  }

  Future<void> _fetchHomeData() async {
    try {
      final token    = await _getToken();
      final response = await http
          .get(Uri.parse(ApiConfig.homeData), headers: _authHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;

        _parseUser(data['user'] as Map<String, dynamic>? ?? {});
        _parsePair(data['pair'] as Map<String, dynamic>? ?? {});
        _parseWedding(data);
        _parseProgress(data['progress'] as Map<String, dynamic>? ?? {});
        _parseLegal(data['legal'] as Map<String, dynamic>? ?? {});

        if (syncStatus.value == 'pending_received') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showIncomingPairDialog(partnerName.value);
          });
        }
      } else if (response.statusCode == 401) {
        Get.offAllNamed('/login');
      } else {
        _showError('Gagal memuat data (${response.statusCode}).');
      }
    } on TimeoutException {
      _showError('Koneksi timeout. Coba lagi.');
    } catch (_) {
      _showError('Tidak dapat memuat data. Cek koneksi internet.');
    }
  }

  Future<void> _fetchNotifStatus() async {
    try {
      final token    = await _getToken();
      final response = await http
          .get(
            Uri.parse(ApiConfig.notifUnreadCount),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body  = jsonDecode(response.body) as Map<String, dynamic>;
        final count = (body['data']?['count'] ?? 0) as int;
        unreadNotifCount.value = count;
        hasUnreadNotif.value   = count > 0;
      }
    } catch (_) {}
  }

  /// Dipanggil saat panel notif dibuka
  Future<void> fetchNotifications() async {
    isNotifLoading.value = true;
    try {
      final token    = await _getToken();
      final response = await http
          .get(Uri.parse(ApiConfig.notifList), headers: _authHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (body['data'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        notifications.value = list;
      }
    } catch (_) {}
    finally {
      isNotifLoading.value = false;
    }
  }

  Future<void> markAllNotifRead() async {
    try {
      final token = await _getToken();
      await http
          .post(
            Uri.parse(ApiConfig.notifMarkAllRead),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      notifications.value =
          notifications.map((n) => {...n, 'is_read': true}).toList();
      hasUnreadNotif.value   = false;
      unreadNotifCount.value = 0;
    } catch (_) {}
  }

  Future<void> markNotifRead(String notifId) async {
    try {
      final token = await _getToken();
      await http
          .patch(
            Uri.parse(ApiConfig.notifMarkRead(notifId)),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      notifications.value = notifications.map((n) {
        if (n['id']?.toString() == notifId) {
          return {...n, 'is_read': true};
        }
        return n;
      }).toList();

      final unread = notifications.where((n) => n['is_read'] != true).length;
      unreadNotifCount.value = unread;
      hasUnreadNotif.value   = unread > 0;
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════════════
  // PARSE
  // ═══════════════════════════════════════════════════════════════════

  void _parseUser(Map<String, dynamic> user) {
    myName.value       = user['name']        ?? '';
    myPhotoUrl.value   = user['photo_url']   ?? '';
    myUniqueCode.value = user['unique_code'] ?? '';
    myInitials.value   = _toInitials(myName.value);
  }

  void _parsePair(Map<String, dynamic> pair) {
    isSynced.value   = pair['is_synced']   ?? false;
    syncStatus.value = pair['sync_status'] ?? 'none';

    final partner         = pair['partner'] as Map<String, dynamic>? ?? {};
    partnerName.value     = partner['name']      ?? '';
    partnerInitials.value = _toInitials(partnerName.value);
    partnerPhotoUrl.value = partner['photo_url'] ?? '';
  }

  void _parseWedding(Map<String, dynamic> data) {
    weddingDateStr.value = data['wedding_date_display'] ?? '';
    final epoch = data['wedding_date_epoch'] as int? ?? 0;
    if (epoch > 0) {
      _updateCountdownFrom(
        DateTime.fromMillisecondsSinceEpoch(epoch * 1000),
      );
    }
  }

  void _parseProgress(Map<String, dynamic> progress) {
    totalTasks.value     = (progress['total']          ?? 0) as int;
    completedTasks.value = (progress['completed']      ?? 0) as int;
    legalProgress.value  =
        ((progress['legal_percent'] ?? 0) as num).toDouble() / 100;
    taskProgress.value   =
        ((progress['task_percent']  ?? 0) as num).toDouble() / 100;
  }

  void _parseLegal(Map<String, dynamic> legal) {
    currentLegalLevel.value    = legal['level']       ?? '';
    currentLegalDoc.value      = legal['current_doc'] ?? '';
    legalProgressPercent.value = (legal['percent']    ?? 0) as int;
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAIRING
  // ═══════════════════════════════════════════════════════════════════

  void goToPairingSetup() {
    pairInputController.clear();
    Get.bottomSheet(
      _PairingBottomSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> submitPairRequest() async {
    final code = pairInputController.text.trim().toUpperCase();
    if (code.length < 6) {
      Get.snackbar('Periksa Kode', 'Kode pasangan harus 6 karakter.',
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (code == myUniqueCode.value) {
      Get.snackbar('Oops!', 'Tidak bisa menghubungkan akun ke dirimu sendiri.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    isPairActionLoading.value = true;
    try {
      final token    = await _getToken();
      final response = await http
          .post(
            Uri.parse(ApiConfig.pairRequest),
            headers: _authHeaders(token),
            body: jsonEncode({'unique_code': code}),
          )
          .timeout(const Duration(seconds: 15));

      final res = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Get.back();
        pairInputController.clear();
        await _fetchHomeData();
        Get.snackbar(
          'Permintaan Terkirim ✓',
          res['message'] ?? 'Menunggu konfirmasi dari pasanganmu.',
          backgroundColor: const Color(0xFFC8A96A),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Gagal',
          res['message'] ?? 'Terjadi kesalahan.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } on TimeoutException {
      _showError('Koneksi timeout.');
    } catch (_) {
      _showError('Gagal menghubungi server.');
    } finally {
      isPairActionLoading.value = false;
    }
  }

  Future<void> respondToPair(String action) async {
    Get.back();
    isPairActionLoading.value = true;
    try {
      final token = await _getToken();
      await http
          .post(
            Uri.parse(ApiConfig.pairRespond),
            headers: _authHeaders(token),
            body: jsonEncode({'action': action}),
          )
          .timeout(const Duration(seconds: 15));

      await _fetchHomeData();
      if (action == 'accept') {
        Get.snackbar(
          'Terhubung! 💕',
          'Kamu dan ${partnerName.value} kini merencanakan bersama.',
          backgroundColor: const Color(0xFF3D6B5F),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (_) {
      _showError('Gagal merespons undangan.');
    } finally {
      isPairActionLoading.value = false;
    }
  }

  /// Dipakai saat status SUDAH synced — memutus hubungan sepenuhnya.
  Future<void> unlinkPair() => _confirmAndUnlink(
        title: 'Putus Hubungan?',
        content:
            'Semua progres bersama akan terputus. Yakin ingin melanjutkan?',
        confirmLabel: 'Putus',
        successTitle: 'Koneksi Diputus',
        successMessage: 'Kamu tidak lagi terhubung dengan pasangan.',
      );

  /// Dipakai saat status PENDING (sudah kirim kode, belum dikonfirmasi
  /// pasangan) — membatalkan permintaan yang terlanjur dikirim.
  /// Menggunakan endpoint yang sama dengan unlink karena secara data,
  /// pending & synced sama-sama direset via ApiConfig.pairUnlink.
  Future<void> cancelPairRequest() => _confirmAndUnlink(
        title: 'Batalkan Permintaan?',
        content:
            'Permintaan yang sudah dikirim ke pasangan akan dibatalkan.',
        confirmLabel: 'Batalkan',
        successTitle: 'Permintaan Dibatalkan',
        successMessage: 'Permintaan sinkronisasi berhasil dibatalkan.',
      );

  Future<void> _confirmAndUnlink({
    required String title,
    required String content,
    required String confirmLabel,
    required String successTitle,
    required String successMessage,
  }) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Get.back(result: true),
            child:
                Text(confirmLabel, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isPairActionLoading.value = true;
    try {
      final token    = await _getToken();
      final response = await http
          .post(
            Uri.parse(ApiConfig.pairUnlink),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await _fetchHomeData();
        Get.snackbar(
          successTitle,
          successMessage,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        final res = jsonDecode(response.body) as Map<String, dynamic>;
        _showError(res['message'] ?? 'Gagal memproses permintaan.');
      }
    } catch (_) {
      _showError('Gagal memproses permintaan. Cek internet.');
    } finally {
      isPairActionLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // WEDDING DATE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> updateWeddingDate(DateTime picked) async {
    // Optimistic update
    weddingDateStr.value = _formatDate(picked);
    _updateCountdownFrom(picked);

    try {
      final token   = await _getToken();
      final isoDate = '${picked.year}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';

      final response = await http
          .patch(
            Uri.parse(ApiConfig.weddingDate),
            headers: _authHeaders(token),
            body: jsonEncode({'date': isoDate}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        weddingDateStr.value =
            body['data']?['display'] ?? _formatDate(picked);
        Get.snackbar(
          'Tanggal Disimpan ✓',
          'Hitung mundur diperbarui.',
          backgroundColor: const Color(0xFF3D6B5F),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (_) {
      // Tanggal sudah ter-set lokal via optimistic update — tidak perlu snackbar
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // COUNTDOWN
  // ═══════════════════════════════════════════════════════════════════

  void _updateCountdownFrom(DateTime target) {
    _targetDate = target;
    _tickCountdown();
  }

  void _startCountdownTicker() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickCountdown(),
    );
  }

  void _tickCountdown() {
    if (_targetDate == null) return;
    final diff = _targetDate!.difference(DateTime.now());
    if (diff.isNegative) {
      daysRemaining.value    = 0;
      hoursRemaining.value   = 0;
      minutesRemaining.value = 0;
      secondsRemaining.value = 0;
    } else {
      daysRemaining.value    = diff.inDays;
      hoursRemaining.value   = diff.inHours.remainder(24);
      minutesRemaining.value = diff.inMinutes.remainder(60);
      secondsRemaining.value = diff.inSeconds.remainder(60);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CLIPBOARD
  // ═══════════════════════════════════════════════════════════════════

  void copyMyCode() {
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
  // COMPUTED
  // ═══════════════════════════════════════════════════════════════════

  double get overallProgress =>
      totalTasks.value == 0 ? 0.0 : completedTasks.value / totalTasks.value;

  int get remainingTasks => totalTasks.value - completedTasks.value;

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  String _toInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _showError(String message) {
    Get.snackbar(
      'Gagal',
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showIncomingPairDialog(String senderName) {
    if (Get.isDialogOpen == true) return;
    Get.dialog(
      _IncomingPairDialog(senderName: senderName, controller: this),
      barrierDismissible: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET: Pairing
// ─────────────────────────────────────────────────────────────────────────────

class _PairingBottomSheet extends StatelessWidget {
  const _PairingBottomSheet({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hubungkan Akun Simpul',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Bagikan kode unikmu, atau masukkan kode pasangan.',
                style: TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
              ),
              const SizedBox(height: 20),
              const Text(
                'KODE UNIKMU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8A8A8A),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0EE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF3D6B5F), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          controller.myUniqueCode.value.isEmpty
                              ? '——————'
                              : controller.myUniqueCode.value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6.0,
                            color: Color(0xFF3D6B5F),
                          ),
                        )),
                    GestureDetector(
                      onTap: controller.copyMyCode,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D6B5F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.copy_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'atau',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 20),
              const Text(
                'KODE PASANGANMU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8A8A8A),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.pairInputController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  hintText: '––  ––  ––',
                  hintStyle: TextStyle(
                      letterSpacing: 4, color: Colors.grey.shade400),
                  counterText: '',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.favorite_rounded,
                        color: Color(0xFFC8A96A), size: 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFF0F0F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFF0F0F0), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFF3D6B5F), width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D6B5F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: controller.isPairActionLoading.value
                          ? null
                          : controller.submitPairRequest,
                      child: controller.isPairActionLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Kirim Permintaan Terhubung',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG: Incoming Pair
// ─────────────────────────────────────────────────────────────────────────────

class _IncomingPairDialog extends StatelessWidget {
  const _IncomingPairDialog(
      {required this.senderName, required this.controller});
  final String senderName;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.redAccent, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ada Ajakan Masuk 💌',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$senderName mengajakmu merencanakan pernikahan bersama di Simpul.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8A8A8A),
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(
                          color: Color(0xFFF0F0F0), width: 1.5),
                    ),
                    onPressed: () => controller.respondToPair('reject'),
                    child: const Text(
                      'Tolak',
                      style: TextStyle(
                        color: Color(0xFF8A8A8A),
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => controller.respondToPair('accept'),
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