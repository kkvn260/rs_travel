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
  List<String> tripId = List.empty(growable: true);
  var today = DateTime.now();
  dynamic id;
  String tripCode = '';
  bool exist = false;

  @override
  void initState() {
    super.initState();
    getNowUser();
    getTripDate();
  }

  void refresh() {
    setState(() {
      tripList.clear();
      tripId.clear();
      working = true;
      getTripDate();
    });
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
      id = result.docs.toList()[i].id;
      var getName = await _store.collection('trip').doc(id).get();
      var name = getName.data()!['name'];
      var getUid =
          await _store.collection('trip').doc(id).collection('group').get();
      for (int j = 0; j < getUid.size; j++) {
        var uid = getUid.docs.toList()[j].data()['user'];
        if (uid == nowUser!.uid) {
          tripList.add(name);
          tripId.add(id);
        }
      }
    }
    setState(() {
      working = false;
    });
  }

  void joinTrip(String code) async {
    var trip = await _store.collection('trip').get();
    int already = 0;
    bool exist = false;
    for (int i = 0; i < trip.docs.length; i++) {
      if (trip.docs.toList()[i].id == code) {
        exist = true;
        var data =
            await _store.collection('trip').doc(code).collection('group').get();
        for (int j = 0; j < data.docs.length; j++) {
          if (data.docs.toList()[j].data()['user'] == nowUser?.uid) {
            already = 1;
            break;
          }
        }
      }
    }
    joinResult(already, exist, code);
  }

  void joinResult(int a, bool exist, String code) async {
    if (a == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text('이미 참여한 일정입니다.'),
        ),
      );
      return;
    }
    if (exist) {
      await _store
          .collection('trip')
          .doc(code)
          .collection('group')
          .add({'user': nowUser?.uid});
      joinDone();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text('존재 하지 않는 일정입니다.'),
        ),
      );
    }
  }

  void joinDone() {
    Navigator.pop(context);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.grey[400],
        actions: [
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
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/main_.jpg'),
              fit: BoxFit.fill,
              opacity: 0.4,
            ),
          ),
          child: Column(
            children: [
              //상단
              Expanded(
                flex: 2,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          'Today',
                          style: TextStyle(
                            fontFamily: 'komi',
                            fontSize: 35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          '${today.year}.${today.month}.${today.day}',
                          style: const TextStyle(
                            fontFamily: 'komi',
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 3,
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '참가한 일정',
                        style: TextStyle(
                          fontFamily: 'komi',
                          fontSize: 25,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tripList[index],
                                    style: const TextStyle(
                                      fontFamily: 'komi',
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TripOn(tripName: tripId[index]),
                                        ),
                                      ).then((value) {
                                        refresh();
                                      });
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
                            refresh();
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.height / 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.orange,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    fontFamily: 'komi',
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  '일정 참가',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'komi',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: TextField(
                                  onChanged: (value) {
                                    tripCode = value;
                                  },
                                  decoration: const InputDecoration(
                                    label: Text('참가 코드'),
                                  ),
                                ),
                                actions: [
                                  FilledButton(
                                    onPressed: () {
                                      joinTrip(tripCode);
                                    },
                                    child: const Text('확인'),
                                  ),
                                  FilledButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.grey),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('취소'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.height / 6,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[200],
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    fontFamily: 'komi',
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
