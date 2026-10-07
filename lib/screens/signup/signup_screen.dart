import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../theme/appcolors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isAgreed = false;
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: const Color(0xFF263A30),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
             top: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text('Create an account',
        style: TextStyle(color: Color(0xFFF0F4E6),
        fontSize: 32,
        fontWeight: FontWeight.w700,
        ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Name', 
        style: TextStyle(color: Color(0xFFF0F4E6),
        fontSize:16,
        fontWeight: FontWeight.w600,
        ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 350,
          height: 60,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF588157),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFBBD58E),
                width: 3,
              ),
              )
            )
          )
        ),
        const SizedBox(height: 40),
        const Text(
          'Email', 
        style: TextStyle(color: Color(0xFFF0F4E6),
        fontSize:16,
        fontWeight: FontWeight.w600,
        ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 350,
          height: 60,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF588157),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFBBD58E),
                width: 3,
              ),
              )
            )
          )
        ),
        const SizedBox(height: 40),
        const Text(
          'Password', 
        style: TextStyle(color: Color(0xFFF0F4E6),
        fontSize:16,
        fontWeight: FontWeight.w600,
        ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 350,
          height: 60,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF588157),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFBBD58E),
                width: 3,
              ),
              )
            )
          )
        ),

        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: isAgreed,
              onChanged: (value) {
                setState(() {
                  isAgreed = value ?? false;
                });
              },
            ),
            const Text(
              'I agree to the Terms and Conditions',
              style: TextStyle(color: Color(0xFFF0F4E6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              ),
            ),
          ],
           ),
           const SizedBox(height: 40),
           SizedBox(
            width: 350,
            height: 60,
            child: ElevatedButton(
              onPressed: isAgreed ? () {
                // Handle sign up logic here
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBBD58E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Color(0xFF263A30),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                ),
              ),
            )
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
                      ..onTap = () {
                        // Navigate to the login screen
                        Navigator.pop(context);
                      },
                  ),
                ],
              ),
            ),
           )
        ],
      ),
    ),
  ),
);
  }
}
