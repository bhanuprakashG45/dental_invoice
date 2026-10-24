import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/views/auth/sign_in_screen.dart';
import 'package:invoice/views/home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isVerifying = false;

  String get _otp => _controllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();

    if (mounted) {
      setState(() {
        _secondsRemaining = 30;
      });
    } else {
      _secondsRemaining = 30;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        setState(() => _secondsRemaining = 0);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void setStateIfMounted(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty) {
      if (index < _focusNodes.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
  }

  void _handlePaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return;

    final pasted = digits.substring(
      0,
      digits.length.clamp(0, _controllers.length),
    );

    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].value = TextEditingValue(
        text: i < pasted.length ? pasted[i] : '',
        selection: TextSelection.collapsed(offset: i < pasted.length ? 1 : 0),
      );
    }

    if (pasted.length < _focusNodes.length) {
      _focusNodes[pasted.length].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }

    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 4) {
      _showMessage('Please enter the complete 4-digit OTP');
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0) return;

    for (final controller in _controllers) {
      controller.clear();
    }

    _startTimer();
    _focusNodes.first.requestFocus();

    // Connect your resend OTP API here.
    _showMessage('Connect your resend OTP API here.');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  Widget _buildOtpBox(int index, double boxSize) {
    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controllers[index], _focusNodes[index]]),
        builder: (context, _) {
          final isFocused = _focusNodes[index].hasFocus;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: isFocused
                  ? const Color(0xFFF3F7FF)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused ? ssaBlue : const Color(0xFFDCE5F3),
                width: isFocused ? 1.6 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: ssaBlue.withValues(alpha: 0.045),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textInputAction: index == 3
                    ? TextInputAction.done
                    : TextInputAction.next,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                maxLength: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                style: TextStyle(
                  fontSize: context.sp(22),
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: ssaNavy,
                ),
                cursorColor: ssaBlue,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '—',
                  hintStyle: TextStyle(
                    color: const Color(0xFFCCD6E8),
                    fontSize: context.sp(19),
                    height: 1.0,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (input) => _onDigitChanged(input, index),
                onSubmitted: (_) {
                  if (index == 3) {
                    _verifyOtp();
                  } else {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenHeight = screenSize.height;
    final isSmallScreen = screenHeight <= 750;

    final horizontalPadding = context.wp(6.8);
    final availableWidth = screenSize.width - (horizontalPadding * 2);

    // Reduced OTP box size while preserving equal spacing.
    final boxSize = ((availableWidth - context.wp(12)) / 4)
        .clamp(42.0, 58.0)
        .toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SsaBackgroundPainter(topDesignOnRight: true),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: context.hp(1),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - context.hp(2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEAF3FF,
                              ).withValues(alpha: 0.97),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD4E5FF),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF386CCB,
                                  ).withValues(alpha: 0.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.expand(),
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: ssaNavy,
                                size: 19,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: context.hp(isSmallScreen ? 1.5 : 3)),

                        Image.asset(
                          'assets/images/login_img.png',
                          width: context.wp(60),
                          height: context.hp(isSmallScreen ? 9 : 12),
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: context.hp(isSmallScreen ? 1 : 2)),

                        Container(
                          width: context.wp(25),
                          height: context.wp(25),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF0F6FF),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: context.wp(18),
                                height: context.wp(18),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE0EDFF),
                                ),
                              ),
                              Icon(
                                Icons.mark_email_unread_rounded,
                                size: context.wp(15),
                                color: ssaBlue,
                              ),
                              Positioned(
                                right: context.wp(3.5),
                                top: context.wp(4),
                                child: Icon(
                                  Icons.notifications_active_outlined,
                                  size: context.wp(5.5),
                                  color: const Color(0xFF0750D7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: context.hp(isSmallScreen ? 1.5 : 2)),

                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: ssaNavy,
                              fontSize: context.sp(27),
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                            children: const [
                              TextSpan(text: 'Enter '),
                              TextSpan(
                                text: 'OTP',
                                style: TextStyle(color: ssaBlue),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: context.hp(0.5)),

                        Text(
                          'We have sent a 4-digit OTP to',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ssaMuted,
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: context.hp(0.5)),

                        Text(
                          widget.email,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ssaNavy,
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: context.hp(isSmallScreen ? 2 : 3)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            4,
                            (index) => _buildOtpBox(index, boxSize),
                          ),
                        ),

                        SizedBox(height: context.hp(isSmallScreen ? 1.5 : 2)),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _secondsRemaining > 0
                                  ? 'Resend OTP in '
                                  : 'Didn’t receive the OTP? ',
                              style: TextStyle(
                                color: ssaMuted,
                                fontSize: context.sp(12),
                              ),
                            ),
                            if (_secondsRemaining > 0)
                              Text(
                                '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: ssaBlue,
                                  fontSize: context.sp(12),
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else
                              TextButton(
                                onPressed: _resendOtp,
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: ssaBlue,
                                    fontSize: context.sp(12),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: context.hp(isSmallScreen ? 1 : 2)),

                        SsaGradientButton(
                          label: 'Verify OTP',
                          isLoading: _isVerifying,
                          onPressed: _isVerifying ? null : _verifyOtp,
                        ),

                        SizedBox(height: context.hp(isSmallScreen ? 1.5 : 3)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
