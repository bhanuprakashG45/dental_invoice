import 'package:flutter/material.dart';
import 'package:invoice/core/local_storage/user_local_storage.dart';
import 'package:invoice/data/repo/auth/auth_repository.dart';
import 'package:invoice/views/home/home_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider(this.authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    isLoading = true;

    try {
      final response = await authRepository.login(
        email: email,
        password: password,
      );

      if (response.success) {
        await UserLocalStorage.saveUserDetails(
          userId: response.data?.user?.id ?? '',
          email: response.data?.user?.email ?? '',
          role: response.data?.user?.role ?? '',
          isActive: response.data?.user?.isActive ?? false,
          name: response.data?.user?.name ?? '',
          phone: response.data?.user?.phone ?? '',
          clinicName: response.data?.user?.clinicName ?? '',
          address: response.data?.user?.address ?? '',
          accessToken: response.data?.accessToken ?? '',
          refreshToken: response.data?.refreshToken ?? '',
        );

        debugPrint('Login Response: ${response.message}');

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Login Error: $e');
    } finally {
      isLoading = false;
    }
  }
}
