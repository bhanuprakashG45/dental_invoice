import 'package:flutter/material.dart';
import 'package:invoice/provider/providers.dart';
import 'package:provider/provider.dart';
import 'package:invoice/views/auth/sign_in_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: allProviders,
      child: MaterialApp(
        title: 'Dental Invoice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SignInScreen(),
        builder: (context, child) {
          return SafeArea(top: false, child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
