import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rs_travel/screens/create_trip_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rs_travel/screens/trip_on_screen.dart';

class MainTrip extends StatefulWidget {
  const MainTrip({super.key});

  @override
  State<MainTrip> createState() => _MainTripState();
}

class _MainTripState extends State<MainTrip> {
  final _auth = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
  User? nowUser;
  bool working = true;
  List<String> tripList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getNowUser();
    getTripDate();
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

  getTripDate() async {
    var result = await _store.collection('trip').get();
    for (int i = 0; i < result.size; i++) {
      var name = result.docs.toList()[i].data()['name'];
      var getUid = await _store
          .collection('trip')
          .doc(name)
          .collection('group')
          .doc('uid')
          .get();
      var uid = getUid.data()!['user'];
      if (uid == nowUser!.uid) {
        tripList.add(name);
      }
    }
    setState(() {
      working = false;
    });
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
      body: ModalProgressHUD(
        inAsyncCall: working,
        child: Column(
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
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const Text(
                      '최근일정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      height: 4,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: tripList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tripList[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TripOn(tripName: tripList[index]),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
                        ).then((value) {
                          setState(() {
                            tripList.clear();
                            working = true;
                            getTripDate();
                          });
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.height / 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.orange,
                        ),
                        child: Column(
                          children: [
                            Transform.scale(
                              scale: 2,
                              child: Transform.translate(
                                offset: const Offset(-15, 10),
                                child: const Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
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
                        getTripDate();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.height / 6,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Transform.scale(
                              scale: 2,
                              child: Transform.translate(
                                offset: const Offset(-15, 10),
                                child: const Icon(
                                  Icons.search,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
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
      ),
    );
  }
}
