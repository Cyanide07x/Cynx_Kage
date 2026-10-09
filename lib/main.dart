// Save as: lib/main.dart
//
// Matches your existing screens:
//   SplashScreen(onFinished: ...)  -> opens LoginScreen()
//   LoginScreen()                  -> opens HomeScreen() by itself

import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/navigation/navigation_shell.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

Future<bool> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

void main() {
  runApp(const CynxKageApp());
}

class CynxKageApp extends StatelessWidget {
  const CynxKageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cynx Kage',
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: SplashScreen(
        onFinished: () async{
          final isLoggedIn = await checkLoginStatus();
          if (isLoggedIn) {
            navKey.currentState!.pushReplacement(
              MaterialPageRoute(
                builder: (_) => const NavigationShell()),
            );
          } else {
            navKey.currentState!.pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        
      ),
    );
  }
}