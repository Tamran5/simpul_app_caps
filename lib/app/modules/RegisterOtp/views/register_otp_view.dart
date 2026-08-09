import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/register_otp_controller.dart';

class RegisterOtpView extends GetView<RegisterOtpController> {
  const RegisterOtpView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color softGreenTint = Color(0xFFE8F0EE);
  static const Color bgColor = Color(0xFFF5F6F8);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF666666);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color goldAccent = Color(0xFFC8A96A);
  static const Color errorRed = Color(0xFFD64545);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: controller.goBackToRegister,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Obx(() => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Ikon penenang ─────────────────────────────────
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                                color: softGreenTint, shape: BoxShape.circle),
                            child: const Icon(
                              Icons.mark_email_read_rounded,
                              size: 32,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'LANGKAH TERAKHIR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: goldAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        const Text(
                          'Verifikasi Email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textDark),
                        ),
                        const SizedBox(height: 8),

                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 13, color: textGrey, height: 1.5),
                            children: [
                              const TextSpan(
                                  text: 'Kami mengirim kode 6 digit ke '),
                              TextSpan(
                                text: controller.maskedEmail,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textDark),
                              ),
                              const TextSpan(text: '. Masukkan di bawah ini.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: GestureDetector(
                            onTap: controller.goBackToRegister,
                            child: const Text(
                              'Salah alamat email? Kembali',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryGreen,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Kotak OTP (dekoratif) + TextField asli (tersembunyi) ──
                        _OtpBoxes(controller: controller),

                        Obx(() {
                          if (controller.errorText.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 15, color: errorRed),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    controller.errorText.value,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: errorRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // ── Timer countdown ────────────────────────────────
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: controller.isExpired
                                  ? errorRed.withOpacity(0.08)
                                  : softGreenTint,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  controller.isExpired
                                      ? Icons.timer_off_rounded
                                      : Icons.timer_outlined,
                                  size: 14,
                                  color: controller.isExpired
                                      ? errorRed
                                      : primaryGreen,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  controller.isExpired
                                      ? 'Kode kedaluwarsa'
                                      : 'Kode berlaku ${controller.timerLabel}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: controller.isExpired
                                        ? errorRed
                                        : primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Tombol verifikasi ──────────────────────────────
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (controller.isVerifying.value ||
                                    controller.combinedOtp.length != 6)
                                ? null
                                : controller.verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              disabledBackgroundColor:
                                  primaryGreen.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: controller.isVerifying.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    'Verifikasi & Lanjutkan',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Resend OTP ──────────────────────────────────────
                        Center(
                          child: controller.isResending.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: primaryGreen, strokeWidth: 2),
                                )
                              : TextButton(
                                  onPressed: controller.isExpired
                                      ? controller.resendOtp
                                      : null,
                                  child: Text(
                                    controller.isExpired
                                        ? 'Tidak terima kode? Kirim Ulang OTP'
                                        : 'Mohon tunggu sebelum kirim ulang...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: controller.isExpired
                                          ? primaryGreen
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 6 kotak OTP dekoratif + 1 TextField transparan yang benar-benar menerima
// input (jadi backspace, cursor, paste, dsb. semua bawaan Flutter — tidak
// ada FocusNode custom yang bisa bentrok dengan widget lain). ─────────────
class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({required this.controller});
  final RegisterOtpController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.otpFocusNode.requestFocus(),
      child: SizedBox(
        height: 54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Kotak visual ──────────────────────────────────────────────
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller.otpController,
              builder: (_, value, __) {
                final digits = value.text;
                return Obx(() {
                  final hasError = controller.errorText.value.isNotEmpty;
                  final isFocused = controller.otpFocusNode.hasFocus;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      final char = i < digits.length ? digits[i] : '';
                      final isCurrent = i == digits.length && isFocused;
                      return Container(
                        width: 44,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hasError
                              ? RegisterOtpView.errorRed.withOpacity(0.06)
                              : RegisterOtpView.softGreenTint.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasError
                                ? RegisterOtpView.errorRed
                                : isCurrent
                                    ? RegisterOtpView.primaryGreen
                                    : RegisterOtpView.borderGrey,
                            width: (hasError || isCurrent) ? 1.8 : 1.4,
                          ),
                        ),
                        child: Text(
                          char,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: RegisterOtpView.textDark,
                          ),
                        ),
                      );
                    }),
                  );
                });
              },
            ),

            // ── TextField asli, dibuat transparan tapi tetap interaktif ───
            Positioned.fill(
              child: Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: controller.otpController,
                  focusNode: controller.otpFocusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  showCursor: false,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}