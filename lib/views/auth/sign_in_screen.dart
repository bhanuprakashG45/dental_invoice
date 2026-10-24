import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'otp_screen.dart';

const Color ssaNavy = Color(0xFF07164D);
const Color ssaBlue = Color(0xFF0865E8);
const Color ssaLightBlue = Color(0xFFEAF3FF);
const Color ssaMuted = Color(0xFF7D86A5);

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(email: _emailController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: SsaBackgroundPainter()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.sizeOf(context).height;
                final compact = screenHeight < 750;

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wp(6.8),
                    vertical: compact ? 12 : 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: compact ? 80 : 100),

                        Center(
                          child: Image.asset(
                            'assets/images/login_img.png',
                            width: context.wp(60),
                            height: context.hp(12),
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: compact ? 20 : 30),

                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: context.sp(35),
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                              color: ssaNavy,
                              height: 1.15,
                            ),
                            children: const [
                              TextSpan(text: 'Welcome '),
                              TextSpan(
                                text: 'Back!',
                                style: TextStyle(color: ssaBlue),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          'Sign in to continue to your account',
                          style: TextStyle(
                            fontSize: context.sp(15.5),
                            fontWeight: FontWeight.w600,
                            color: ssaMuted,
                            height: 1.4,
                          ),
                        ),

                        SizedBox(height: compact ? 25 : 35),

                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: context.sp(15),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4D5879),
                          ),
                        ),

                        SizedBox(height: context.hp(1)),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.email],
                          onFieldSubmitted: (_) => _sendOtp(),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          style: TextStyle(
                            color: ssaNavy,
                            fontSize: context.sp(15),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your email address',
                            hintStyle: TextStyle(
                              color: ssaMuted,
                              fontSize: context.sp(15),
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(7),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: ssaLightBlue,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.mail_outline_rounded,
                                color: ssaBlue,
                                size: 25,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.97),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: _border(),
                            enabledBorder: _border(),
                            focusedBorder: _border(color: ssaBlue, width: 1.6),
                            errorBorder: _border(color: Colors.redAccent),
                            focusedErrorBorder: _border(
                              color: Colors.redAccent,
                              width: 1.4,
                            ),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Please enter your email address';
                            }

                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email)) {
                              return 'Please enter a valid email address';
                            }

                            return null;
                          },
                        ),

                        SizedBox(height: compact ? 15 : 20),

                        SsaGradientButton(
                          label: 'Send OTP',
                          onPressed: _sendOtp,
                        ),

                        SizedBox(height: compact ? 20 : 30),
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

OutlineInputBorder _border({
  Color color = const Color(0xFFDCE5F5),
  double width = 1.3,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: color, width: width),
  );
}

class SsaGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SsaGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.hp(6.5).clamp(54.0, 64.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF168FF7), Color(0xFF0750D7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ssaBlue.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.white70,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white.withValues(alpha: 0.9),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white.withValues(alpha: 0.7),
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: context.sp(17),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: context.wp(3)),
                    const Icon(Icons.arrow_forward_rounded, size: 27),
                  ],
                ),
        ),
      ),
    );
  }
}

class SsaBackgroundPainter extends CustomPainter {
  final bool topDesignOnRight;

  const SsaBackgroundPainter({this.topDesignOnRight = false});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final palePaint = Paint()
      ..color = const Color(0xFFEAF3FF)
      ..style = PaintingStyle.fill;

    // Top light blue layer.
    final top = Path();

    if (topDesignOnRight) {
      top
        ..moveTo(width, 0)
        ..lineTo(width * 0.63, 0)
        ..cubicTo(
          width * 0.75,
          height * 0.09,
          width * 0.88,
          height * 0.15,
          width,
          height * 0.17,
        )
        ..close();
    } else {
      top
        ..moveTo(0, 0)
        ..lineTo(width * 0.37, 0)
        ..cubicTo(
          width * 0.25,
          height * 0.09,
          width * 0.12,
          height * 0.15,
          0,
          height * 0.17,
        )
        ..close();
    }

    canvas.drawPath(top, Paint()..color = const Color(0xFFD6E7FF));

    // Top slightly darker blue layer.
    final topLayer1 = Path();

    if (topDesignOnRight) {
      topLayer1
        ..moveTo(width, 0)
        ..lineTo(width * 0.73, 0)
        ..cubicTo(
          width * 0.80,
          height * 0.055,
          width * 0.91,
          height * 0.105,
          width,
          height * 0.13,
        )
        ..close();
    } else {
      topLayer1
        ..moveTo(0, 0)
        ..lineTo(width * 0.27, 0)
        ..cubicTo(
          width * 0.20,
          height * 0.055,
          width * 0.09,
          height * 0.105,
          0,
          height * 0.13,
        )
        ..close();
    }

    canvas.drawPath(
      topLayer1,
      Paint()..color = const Color(0xFFAACFFF).withValues(alpha: 0.85),
    );

    // Top third blue layer.
    final topLayer2 = Path();

    if (topDesignOnRight) {
      topLayer2
        ..moveTo(width, 0)
        ..lineTo(width * 0.87, 0)
        ..cubicTo(
          width * 0.895,
          height * 0.035,
          width * 0.945,
          height * 0.06,
          width,
          height * 0.075,
        )
        ..close();
    } else {
      topLayer2
        ..moveTo(0, 0)
        ..lineTo(width * 0.13, 0)
        ..cubicTo(
          width * 0.105,
          height * 0.035,
          width * 0.055,
          height * 0.06,
          0,
          height * 0.075,
        )
        ..close();
    }

    canvas.drawPath(
      topLayer2,
      Paint()..color = const Color(0xFF8DBEFF).withValues(alpha: 0.55),
    );

    // Existing right-side pale shape.
    final right = Path()
      ..moveTo(width, height * 0.29)
      ..cubicTo(
        width * 0.88,
        height * 0.32,
        width * 0.91,
        height * 0.39,
        width,
        height * 0.42,
      )
      ..close();

    canvas.drawPath(right, palePaint);

    // Bottom wave 1: light blue.
    final wave1 = Path()
      ..moveTo(0, height * 0.77)
      ..cubicTo(
        width * 0.24,
        height * 0.77,
        width * 0.39,
        height * 0.94,
        width * 0.60,
        height * 0.86,
      )
      ..cubicTo(
        width * 0.77,
        height * 0.79,
        width * 0.87,
        height * 0.73,
        width,
        height * 0.75,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    // Bottom wave 2: brighter sky blue.
    final wave2 = Path()
      ..moveTo(0, height * 0.84)
      ..cubicTo(
        width * 0.20,
        height * 0.80,
        width * 0.41,
        height * 0.96,
        width * 0.63,
        height * 0.90,
      )
      ..cubicTo(
        width * 0.81,
        height * 0.84,
        width * 0.90,
        height * 0.88,
        width,
        height * 0.84,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    // Bottom wave 3: cornflower blue.
    final wave3 = Path()
      ..moveTo(0, height * 0.89)
      ..cubicTo(
        width * 0.25,
        height * 0.84,
        width * 0.40,
        height * 0.94,
        width * 0.61,
        height * 0.93,
      )
      ..cubicTo(
        width * 0.78,
        height * 0.92,
        width * 0.89,
        height * 0.86,
        width,
        height * 0.89,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    canvas.drawPath(wave1, Paint()..color = const Color(0xFFD6E8FF));
    canvas.drawPath(wave2, Paint()..color = const Color(0xFF9FCBFF));
    canvas.drawPath(wave3, Paint()..color = const Color(0xFF78B1FF));

    // Smooth bottom blue gradient.
    final bottomGradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x0078B1FF), Color(0xFFA8CEFF), Color(0xFFC7DFFF)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, height * 0.89, width, height * 0.11));

    canvas.drawRect(
      Rect.fromLTWH(0, height * 0.89, width, height * 0.11),
      bottomGradient,
    );

    // Subtle white wave separator.
    final curve = Path()
      ..moveTo(0, height * 0.86)
      ..cubicTo(
        width * 0.24,
        height * 0.82,
        width * 0.56,
        height * 0.98,
        width,
        height * 0.91,
      );

    canvas.drawPath(
      curve,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant SsaBackgroundPainter oldDelegate) {
    return oldDelegate.topDesignOnRight != topDesignOnRight;
  }
}
