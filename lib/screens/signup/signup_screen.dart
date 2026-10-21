
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Stateful registration screen with name, email, and password fields.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers & state

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isAgreed = false;
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Actions

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    if (!isAgreed) {
      showMessage('Please agree to the Terms and Conditions.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      if (!mounted) return;

      showMessage('Account created successfully!');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please log in.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Choose a stronger password.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign-up is not enabled in Firebase.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
        default:
          message = e.message ?? 'Unable to create your account.';
      }

      showMessage(message);
    } catch (e) {
      if (mounted) {
        showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colors.surface,
        content: Text(
          message,
          style: TextStyle(color: colors.onSurface),
        ),
      ),
    );
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    'Create an account',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Name field
                  const SizedBox(height: 30),
                  label('Name'),
                  const SizedBox(height: 10),
                  inputField(
                    controller: nameController,
                    hint: 'Your full name',
                  ),

                  // Email field
                  const SizedBox(height: 24),
                  label('Email'),
                  const SizedBox(height: 10),
                  inputField(
                    controller: emailController,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Password field
                  const SizedBox(height: 24),
                  label('Password'),
                  const SizedBox(height: 10),
                  inputField(
                    controller: passwordController,
                    hint: 'At least 6 characters',
                    isPassword: true,
                  ),

                  // Terms checkbox
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isAgreed,
                        activeColor: colors.primary,
                        checkColor: colors.onPrimary,
                        onChanged: (value) {
                          setState(() => isAgreed = value ?? false);
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Sign-up button
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isAgreed && !isLoading ? signUp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        disabledBackgroundColor:
                            colors.primary.withValues(alpha: 0.3),
                        foregroundColor: colors.onPrimary,
                        disabledForegroundColor:
                            colors.onPrimary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.onPrimary,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  // Log-in link
                  const SizedBox(height: 30),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 15,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Already have an account? ',
                          ),
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pop(context),
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

  // Private widget builders

  Widget label(String text) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      text,
      style: TextStyle(
        color: colors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    String? hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && obscurePassword,
        autocorrect: false,
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colors.onSurfaceVariant,
          ),
          filled: true,
          fillColor: colors.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colors.primary,
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: colors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
