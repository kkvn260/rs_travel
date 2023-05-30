import 'package:flutter/material.dart';

class MainTravel extends StatefulWidget {
  const MainTravel({super.key});

  @override
  State<MainTravel> createState() => _MainTravelState();
}

class _MainTravelState extends State<MainTravel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: const DecorationImage(
                  image: AssetImage('assets/images/main_.jpg'),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '일정 생성'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '일정 참여'),
        ],
      ),
    );
  }
}
