import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/navigation/navigation_shell.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

Future<bool> checkLoginStatus() async {
  return FirebaseAuth.instance.currentUser != null;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: SplashScreen(
        onFinished: () async {
          final isLoggedIn = await checkLoginStatus();

          if (isLoggedIn) {
            navKey.currentState!.pushReplacement(
              MaterialPageRoute(
                builder: (_) => const NavigationShell(),
              ),
            );
          } else {
            navKey.currentState!.pushReplacement(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}