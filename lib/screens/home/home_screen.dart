import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/appcolors.dart';
import '../../widgets/footer.dart';
import '../../widgets/header.dart';
import '../../widgets/searchbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,

      body: SafeArea(
        child: Column(
          children: [
            const Header(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Hero
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: SvgPicture.asset(
                          'assets/images/Herotag.svg',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),

                    // Space between Hero and Search Bar
                    const SizedBox(height: 20),

                    // Search Bar
                  Padding(
  padding: const EdgeInsets.symmetric(horizontal: 15),
  child: AnimatedSearchBar(
    hint: 'Search jackets, cargos',
  ),
),  
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Footer(
          onAccountTap: () {
            // Account will be added later
          },
        ),
      ),
    );
  }
}