import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rastreamento_app_admin/screens/auth_gate.dart';
import 'package:rastreamento_app_admin/screens/onboarding_screen.dart';
import 'package:rastreamento_app_admin/themes/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rastreamento Admin',
      theme: appTheme,
      home: onboardingCompleted ? const AuthGate() : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
