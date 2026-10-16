import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductPage({
    super.key, 
    required this.product,
  });

  @override 
  State<ProductPage> createState()=> _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
    );
  }
}
