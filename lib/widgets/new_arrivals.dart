import 'package:flutter/material.dart';

class NewArrivals extends StatefulWidget {
  const NewArrivals({super.key});

  @override
  State<NewArrivals> createState() => _NewArrivalsState();

}

class _NewArrivalsState extends State<NewArrivals>{
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 250,
      child: Center(
        child: Text('New Arrivals'),
      ),
    );
  }
}