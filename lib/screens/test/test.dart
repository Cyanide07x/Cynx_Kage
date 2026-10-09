import 'package:flutter/material.dart';
import '../../widgets/header.dart';
import '../../theme/appcolors.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Column(
        children: [
          const Header(),

          const Expanded(
            child: Center(
              child: Text(
                'Test Screen',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),

      
    );
  }
}