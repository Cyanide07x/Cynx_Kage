import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/appcolors.dart';

class SignUpScreen extends StatefulWidget {

  const SignUpScreen({super.key});

  @override

  State<SignUpScreen> createState() => _SignUpScreenState();

}

class _SignUpScreenState extends State<SignUpScreen> {

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

      final credential = await FirebaseAuth.instance

          .createUserWithEmailAndPassword(

        email: email,

        password: password,

      );

      // Save the user's name in their Firebase profile.

      await credential.user?.updateDisplayName(name);

      if (!mounted) return;

      showMessage('Account created successfully!');

      // Firebase automatically signs the user in after registration.

      // Return to the previous screen; we'll align app navigation next.

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

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(message)),

    );

  }

  Widget label(String text) {

    return Text(

      text,

      style: const TextStyle(

        color: Color(0xFFF0F4E6),

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

    return SizedBox(

      height: 60,

      child: TextField(

        controller: controller,

        keyboardType: keyboardType,

        obscureText: isPassword && obscurePassword,

        autocorrect: false,

        style: const TextStyle(

          color: Color(0xFFF0F4E6),

          fontSize: 16,

        ),

        decoration: InputDecoration(

          hintText: hint,

          hintStyle: const TextStyle(color: Color(0xFFB4C6B0)),

          filled: true,

          fillColor: const Color(0xFF588157),

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

                    color: const Color(0xFFBBD58E),

                  ),

                )

              : null,

          enabledBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(18),

            borderSide: const BorderSide(

              color: Color(0xFF588157),

            ),

          ),

          focusedBorder: OutlineInputBorder(

            borderRadius: BorderRadius.circular(18),

            borderSide: const BorderSide(

              color: Color(0xFFBBD58E),

              width: 2,

            ),

          ),

        ),

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

              horizontal: 20,

              vertical: 30,

            ),

            child: ConstrainedBox(

              constraints: const BoxConstraints(maxWidth: 390),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(

                    'Create an account',

                    style: TextStyle(

                      color: Color(0xFFF0F4E6),

                      fontSize: 32,

                      fontWeight: FontWeight.w700,

                    ),

                  ),

                  const SizedBox(height: 30),

                  label('Name'),

                  const SizedBox(height: 10),

                  inputField(

                    controller: nameController,

                    hint: 'Your full name',

                  ),

                  const SizedBox(height: 24),

                  label('Email'),

                  const SizedBox(height: 10),

                  inputField(

                    controller: emailController,

                    hint: 'you@example.com',

                    keyboardType: TextInputType.emailAddress,

                  ),

                  const SizedBox(height: 24),

                  label('Password'),

                  const SizedBox(height: 10),

                  inputField(

                    controller: passwordController,

                    hint: 'At least 6 characters',

                    isPassword: true,

                  ),

                  const SizedBox(height: 12),

                  Row(

                    children: [

                      Checkbox(

                        value: isAgreed,

                        activeColor: const Color(0xFFBBD58E),

                        checkColor: const Color(0xFF263A30),

                        onChanged: (value) {

                          setState(() => isAgreed = value ?? false);

                        },

                      ),

                      const Expanded(

                        child: Text(

                          'I agree to the Terms and Conditions',

                          style: TextStyle(

                            color: Color(0xFFF0F4E6),

                            fontSize: 14,

                          ),

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 24),

                  SizedBox(

                    width: double.infinity,

                    height: 60,

                    child: ElevatedButton(

                      onPressed: isAgreed && !isLoading ? signUp : null,

                      style: ElevatedButton.styleFrom(

                        backgroundColor: const Color(0xFFBBD58E),
                        disabledBackgroundColor: const Color(0xFFBBD58E).withValues(alpha: 0.3),

                        foregroundColor: const Color(0xFF263A30),
                        disabledForegroundColor: const Color(0xFF263A30).withValues(alpha: 0.4),

                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(30),

                        ),

                      ),

                      child: isLoading

                          ? const SizedBox(

                              height: 24,

                              width: 24,

                              child: CircularProgressIndicator(

                                strokeWidth: 2.5,

                                color: Color(0xFF263A30),

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

                  const SizedBox(height: 30),

                  Center(

                    child: RichText(

                      text: TextSpan(

                        style: const TextStyle(

                          color: AppColors.textSecondary,

                          fontSize: 15,

                        ),

                        children: [

                          const TextSpan(

                            text: 'Already have an account? ',

                          ),

                          TextSpan(

                            text: 'Log in',

                            style: const TextStyle(

                              color: Color(0xFFBBD58E),

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

}