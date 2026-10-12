import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../navigation/navigation_shell.dart';

import '../signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override

  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  bool isLoading = false;

  @override

  void dispose() {

    emailController.dispose();

    passwordController.dispose();

    super.dispose();

  }

  Future<void> login() async {

    final email = emailController.text.trim();

    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {

      _showMessage('Please enter your email and password.');

      return;

    }

    setState(() => isLoading = true);

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(

        email: email,

        password: password,

      );

      if (!mounted) return;

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) => const NavigationShell(),

        ),

      );

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;

      String message;

      switch (e.code) {

        case 'invalid-email':

          message = 'Please enter a valid email address.';

          break;

        case 'user-not-found':

        case 'invalid-credential':

        case 'wrong-password':

          message = 'Incorrect email or password.';

          break;

        case 'user-disabled':

          message = 'This account has been disabled.';

          break;

        case 'too-many-requests':

          message = 'Too many attempts. Please try again later.';

          break;

        case 'network-request-failed':

          message = 'Network error. Check your internet connection.';

          break;

        default:

          message = e.message ?? 'Unable to log in. Please try again.';

      }

      _showMessage(message);

    } catch (e) {

      if (mounted) {

        _showMessage('Something went wrong. Please try again.');

      }

    } finally {

      if (mounted) {

        setState(() => isLoading = false);

      }

    }

  }

  void _showMessage(String message) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(message)),

    );

  }

  void goToSignup() {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => const SignUpScreen(),

      ),

    );

  }

  void continueAsGuest() {

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) => const NavigationShell(),

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

              constraints: const BoxConstraints(maxWidth: 540),

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

                  SizedBox(

                    width: double.infinity,

                    height: 66,

                    child: ElevatedButton(

                      onPressed: isLoading ? null : login,

                      style: ElevatedButton.styleFrom(

                        backgroundColor: const Color(0xFFBBD58E),

                        foregroundColor: const Color(0xFF263A30),

                        disabledBackgroundColor:

                            const Color(0xFFBBD58E).withValues(alpha: 0.6),

                        elevation: 0,

                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(35),

                        ),

                      ),

                      child: isLoading

                          ? const SizedBox(

                              width: 24,

                              height: 24,

                              child: CircularProgressIndicator(

                                strokeWidth: 2.5,

                                color: Color(0xFF263A30),

                              ),

                            )

                          : const Text(

                              'Log in',

                              style: TextStyle(

                                fontSize: 18,

                                fontWeight: FontWeight.w700,

                              ),

                            ),

                    ),

                  ),

                  const SizedBox(height: 12),

                  SizedBox(

                    width: double.infinity,

                    height: 64,

                    child: OutlinedButton(

                      onPressed: isLoading ? null : continueAsGuest,

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

                  Center(

                    child: RichText(

                      text: TextSpan(

                        style: const TextStyle(

                          color: Color(0xFFB4C6B0),

                          fontSize: 17,

                        ),

                        children: [

                          const TextSpan(text: 'New here? '),

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

        autocorrect: false,

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

          contentPadding: const EdgeInsets.symmetric(horizontal: 20),

          enabledBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(17),

            borderSide: const BorderSide(color: Color(0xFF588157)),

          ),

          focusedBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(17),

            borderSide: const BorderSide(color: Color(0xFFBBD58E)),

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

        autocorrect: false,

        enableSuggestions: false,

        style: const TextStyle(

          color: Color(0xFFF0F4E6),

          fontSize: 17,

        ),

        decoration: InputDecoration(

          hintText: 'Your password',

          hintStyle: const TextStyle(

            color: Color(0xFFB4C6B0),

          ),

          filled: true,

          fillColor: const Color(0xFF3A5A40),

          contentPadding: const EdgeInsets.only(left: 20),

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

            borderSide: const BorderSide(color: Color(0xFF588157)),

          ),

          focusedBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(17),

            borderSide: const BorderSide(color: Color(0xFFBBD58E)),

          ),

        ),

      ),

    );

  }

}
