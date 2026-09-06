import 'package:flutter/material.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';
import 'package:invoice/provider/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn(AuthProvider authvm) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    await authvm.login(context, email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authvm, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(6),
                vertical: context.hp(4),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.hp(4)),
                    Center(
                      child: Container(
                        width: context.wp(20),
                        height: context.wp(20),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: cs.onPrimary,
                          size: 40,
                        ),
                      ),
                    ),

                    SizedBox(height: context.hp(4)),
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.displayLarge.copyWith(
                        fontSize: context.sp(28),
                      ),
                    ),

                    SizedBox(height: context.hp(1)),

                    Text(
                      'Sign in to continue to your account',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSecondary,
                        fontSize: context.sp(14),
                      ),
                    ),

                    SizedBox(height: context.hp(4)),

                    Text('Email Address', style: AppTextStyles.labelLarge),

                    SizedBox(height: context.hp(1)),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: context.hp(2.5)),

                    Text('Password', style: AppTextStyles.labelLarge),

                    SizedBox(height: context.hp(1)),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => signIn(authvm),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: context.hp(2)),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          signIn(authvm);
                        },
                        child: authvm.isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: cs.onPrimary,
                                ),
                              )
                            : Text('Sign In', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
