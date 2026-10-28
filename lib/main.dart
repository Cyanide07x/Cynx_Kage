
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/navigation/navigation_shell.dart';
import 'theme/theme_controller.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

Future<bool> checkLoginStatus() async {
  return FirebaseAuth.instance.currentUser != null;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Local Firebase emulators for development only.
  // await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);

  // Android emulator address for the local Functions emulator.
  // FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5001);

  runApp(const CynxKageApp());
}

class CynxKageApp extends StatefulWidget {
  const CynxKageApp({super.key});

  @override
  State<CynxKageApp> createState() => _CynxKageAppState();
}

class _CynxKageAppState extends State<CynxKageApp> {
  @override
  void initState() {
    super.initState();
    themeController.loadSavedTheme();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'Cynx Kage',
          navigatorKey: navKey,
          debugShowCheckedModeBanner: false,
          theme: themeController.themeData,
          home: SplashScreen(
            onFinished: () async {
              final isLoggedIn = await checkLoginStatus();

              if (!mounted) return;

              navKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => isLoggedIn
                      ? const NavigationShell()
                      : const LoginScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
