// ─────────────────────────────────────────────────────────────────────────────
// screens/login/login_screen.dart
// Firebase email/password login screen for Cynx Kage.
//
// On success the user is routed to [NavigationShell].
// Unauthenticated users can also tap "Continue as guest" to browse without
// an account, or navigate to [SignUpScreen] to create one.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../navigation/navigation_shell.dart';
import '../signup/signup_screen.dart';

/// Stateful login screen with email and password fields.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Controllers & state ───────────────────────────────────────────────────

  /// Text controller for the email input field.
  final TextEditingController emailController = TextEditingController();

  /// Text controller for the password input field.
  final TextEditingController passwordController = TextEditingController();

  /// Whether the password characters are hidden.
  bool obscurePassword = true;

  /// Whether a login network request is in progress.
  bool isLoading = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Validates the form and attempts a Firebase email/password sign-in.
  ///
  /// On success, replaces the current route with [NavigationShell].
  /// On failure, shows a user-friendly [SnackBar] message.
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

      // Map Firebase error codes to human-readable messages.
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

  /// Shows a [SnackBar] with the given [message].
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Navigates forward to [SignUpScreen].
  void goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignUpScreen(),
      ),
    );
  }

  /// Skips login and navigates to [NavigationShell] as a guest user.
  void continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NavigationShell(),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263A30), // deep forest green
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
                  // ── Heading ────────────────────────────────────────────
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

                  // ── Email field ──────────────────────────────────────────
                  const SizedBox(height: 34),
                  _label('Email'),
                  const SizedBox(height: 8),
                  _textField(
                    controller: emailController,
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // ── Password field ───────────────────────────────────────
                  const SizedBox(height: 22),
                  _label('Password'),
                  const SizedBox(height: 8),
                  _passwordField(),

                  // ── Log in button ───────────────────────────────────────
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

                  // ── Guest button ───────────────────────────────────────
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : continueAsGuest,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF0F4E6),
                        side: const BorderSide(color: Color(0xFF588157)),
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

                  // ── Sign-up link ───────────────────────────────────────
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

  // ── Private widget builders ────────────────────────────────────────────

  /// Renders a bold field label (e.g. "Email", "Password").
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

  /// A reusable text input field styled for the login form.
  ///
  /// [controller] — the associated [TextEditingController].
  /// [hintText]   — placeholder shown when the field is empty.
  /// [keyboardType] — optional keyboard variant (default: text).
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
          hintStyle: const TextStyle(color: Color(0xFFB4C6B0)),
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

  /// Password field with a Show/Hide toggle suffix button.
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
          hintStyle: const TextStyle(color: Color(0xFFB4C6B0)),
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
