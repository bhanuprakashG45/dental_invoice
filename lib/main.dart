import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice/core/local_storage/user_local_storage.dart';
import 'package:provider/provider.dart';
import 'package:invoice/provider/providers.dart';
import 'package:invoice/views/auth/sign_in_screen.dart';
import 'package:invoice/views/home/home_screen.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final token = await UserLocalStorage.getAccessToken();

  final bool isLoggedIn = token != null && token.isNotEmpty;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: allProviders,
      child: MaterialApp(
        title: 'Dental Invoice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        home: isLoggedIn ? const HomeScreen() : const SignInScreen(),

        builder: (context, child) {
          return SafeArea(top: false, child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
