import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rs_travel/screens/create_trip_screen.dart';

class MainTrip extends StatefulWidget {
  const MainTrip({super.key});

  @override
  State<MainTrip> createState() => _MainTripState();
}

class _MainTripState extends State<MainTrip> {
  final _auth = FirebaseAuth.instance;
  User? nowUser;

  @override
  void initState() {
    super.initState();
    getNowUser();
  }

  void getNowUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        nowUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings,
            ),
          ),
          IconButton(
            onPressed: () {
              _auth.signOut();
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          //상단
          Expanded(
            flex: 2,
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: const Text('날짜'),
            ),
          ),
          //중단
          Expanded(
            flex: 4,
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: const Text('최근일정'),
            ),
          ),
          //하단
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTrip(),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.orange,
                      ),
                      child: Column(
                        children: [
                          Transform.scale(
                            scale: 2,
                            child: Transform.translate(
                              offset: const Offset(-20, 20),
                              child: const Icon(
                                Icons.add,
                                size: 50,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          const Text(
                            "일정생성",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      print('2');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 15,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Transform.scale(
                            scale: 2,
                            child: Transform.translate(
                              offset: const Offset(-20, 20),
                              child: const Icon(
                                Icons.search,
                                size: 50,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          const Text(
                            "일정참가",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
