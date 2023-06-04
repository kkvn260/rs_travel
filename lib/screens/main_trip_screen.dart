import 'package:flutter/material.dart';

class MainTrip extends StatefulWidget {
  const MainTrip({super.key});

  @override
  State<MainTrip> createState() => _MainTripState();
}

class _MainTripState extends State<MainTrip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              child: const Center(child: Text("main trip")),
            ),
          ),
        ],
      ),
    );
  }
}
