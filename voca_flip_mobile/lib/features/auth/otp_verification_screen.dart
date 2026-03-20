import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/auth/login_screen.dart';
import 'package:voca_flip_mobile/features/auth/providers/auth_provider.dart';
import 'package:voca_flip_mobile/features/auth/reset_password_screen.dart';

enum OtpFlow { passwordReset, emailVerification }

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final OtpFlow flow;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.flow = OtpFlow.passwordReset,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const _otpLength = 4;
  static const _initialSeconds = 30;
  static const _illustrationUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD-EGSISOPuy6GxvI5RR1PmlTxDYJPtj64R-pSlh_X-KkFQVHjjLQWhbQh6mqjtWRA_osymzlPhPVDJvQTFU5eEw5rwyUUiW-wZm24Yy-Bi65FHeOVM8rws5w2Q-ztqXBzoGF4jO35bbzRK9cXKhjswNhn8oQg5iNLo59hnybyAKe8N25ieNucXxvOjt8vviMrQy41GatBopYUlbrBO0ccLgdYq_O23uDha1JPNdDVa3B50CAw4x3ICurhwKJjke98Fn0URG49sstuy';

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _timer;
  int _remainingSeconds = _initialSeconds;
  bool _isSubmitting = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool get _canResend => _remainingSeconds == 0;

  String get _otpCode =>
      _controllers.map((controller) => controller.text).join();

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = _initialSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() => _remainingSeconds = 0);
        }
        return;
      }

      if (mounted) {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  void _onOtpChanged({required int index, required String value}) {
    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    _controllers[index].text = value.substring(value.length - 1);
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: _controllers[index].text.length),
    );

    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  Future<void> _onResendCode() async {
    if (!_canResend || _isSubmitting || _isResending) return;

    setState(() => _isResending = true);
    final success = await ref
        .read(authProvider.notifier)
        .requestOtp(email: widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);

    if (!success) return;

    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã gửi lại mã xác thực tới ${widget.email}',
          style: GoogleFonts.lexend(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _onVerify() async {
    if (_isSubmitting || _isResending) return;

    final hasEmptyDigit = _controllers.any(
      (controller) => controller.text.isEmpty,
    );
    if (_otpCode.length != _otpLength || hasEmptyDigit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 4 chữ số'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(authProvider.notifier)
        .verifyOtp(email: widget.email, otpCode: _otpCode);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success) {
      final errorMessage = ref.read(authProvider).errorMessage;
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (widget.flow == OtpFlow.passwordReset) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ResetPasswordScreen(email: widget.email, otpCode: _otpCode),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Xac thuc email thanh cong, vui long dang nhap'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(isRegisterSuccess: true),
      ),
      (route) => route.isFirst,
    );
  }

  String _formatSeconds(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(
              'Verification',
              textAlign: TextAlign.center,
              style: AppTextStyles.authTopBarTitle,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.authHeroBg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Image.network(
          _illustrationUrl,
          width: 96,
          height: 96,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.mark_email_unread_rounded,
            size: 64,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: AppTextStyles.authScreenTitle.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.authScreenBody,
              children: [
                const TextSpan(
                  text: "We've sent a 4-digit verification code to ",
                ),
                TextSpan(
                  text: widget.email,
                  style: AppTextStyles.authScreenBody.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_otpLength, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index == _otpLength - 1 ? 0 : 16),
          child: SizedBox(
            width: 56,
            height: 64,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: AppTextStyles.authOtpDigit,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                hintText: '-',
                hintStyle: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inputBorder,
                ),
                filled: true,
                fillColor: AppColors.imageOverlay,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onOtpChanged(index: index, value: value),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
            children: [
              const TextSpan(text: 'Resend code in '),
              TextSpan(
                text: _formatSeconds(_remainingSeconds),
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _canResend ? _onResendCode : null,
          child: _isResending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Resend Code',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting || _isResending ? null : _onVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textOnPrimary,
                ),
              )
            : Text(
                'Verify',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnPrimary,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 16),
                _buildIllustration(),
                const SizedBox(height: 24),
                _buildHeadline(),
                const SizedBox(height: 32),
                _buildOtpInputs(),
                const SizedBox(height: 24),
                _buildResendSection(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: _buildVerifyButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
