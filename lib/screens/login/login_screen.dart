import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../home/home_screen.dart';
import '../signup/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> goToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void goToSignup(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263A30),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 540,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      color: Color(0xFFF0F4E6),
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Log in to see your orders and save your bag.',
                    style: TextStyle(
                      color: Color(0xFFB4C6B0),
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 34),

                  _label('Name'),

                  const SizedBox(height: 8),

                  _textField(
                    controller: nameController,
                  ),

                  const SizedBox(height: 22),

                  _label('Email'),

                  const SizedBox(height: 8),

                  _textField(
                    controller: emailController,
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 22),

                  _label('Password'),

                  const SizedBox(height: 8),

                  _passwordField(),

                  const SizedBox(height: 34),

                  // LOGIN
                  SizedBox(
                    width: double.infinity,
                    height: 66,
                    child: ElevatedButton(
                      onPressed: goToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBBD58E),
                        foregroundColor: const Color(0xFF263A30),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CONTINUE AS GUEST
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: OutlinedButton(
                      onPressed: goToHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF0F4E6),
                        side: const BorderSide(
                          color: Color(0xFF588157),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      child: const Text(
                        'Continue as guest',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 38),

                  // CREATE ACCOUNT
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFFB4C6B0),
                          fontSize: 17,
                        ),
                        children: [
                          const TextSpan(
                            text: 'New here? ',
                          ),
                          TextSpan(
                            text: 'Create account',
                            style: const TextStyle(
                              color: Color(0xFFBBD58E),
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = goToSignup,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFF0F4E6),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String hintText = '',
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 62,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFFF0F4E6),
          fontSize: 17,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFB4C6B0),
          ),
          filled: true,
          fillColor: const Color(0xFF3A5A40),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: Color(0xFF588157),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: Color(0xFFBBD58E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return SizedBox(
      height: 62,
      child: TextField(
        controller: passwordController,
        obscureText: obscurePassword,
        style: const TextStyle(
          color: Color(0xFFF0F4E6),
          fontSize: 17,
        ),
        decoration: InputDecoration(
          hintText: 'At least 6 characters',
          hintStyle: const TextStyle(
            color: Color(0xFFB4C6B0),
          ),
          filled: true,
          fillColor: const Color(0xFF3A5A40),
          contentPadding: const EdgeInsets.only(
            left: 20,
          ),
          suffixIcon: TextButton(
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
            child: Text(
              obscurePassword ? 'Show' : 'Hide',
              style: const TextStyle(
                color: Color(0xFFBBD58E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: Color(0xFF588157),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: Color(0xFFBBD58E),
            ),
          ),
        ),
      ),
    );
  }
}