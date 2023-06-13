import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripOn extends StatefulWidget {
  const TripOn({
    super.key,
    required this.tripName,
  });

  final String tripName;

  @override
  State<TripOn> createState() => _TripOnState();
}

class _TripOnState extends State<TripOn> {
  final _store = FirebaseFirestore.instance;
  int dayNum = 0;
  DateTime? startDay;
  DateTime? endDay;
  bool loading = true;
  bool owner = false;
  List<bool> btCk = List.empty(growable: true);
  String activeDay = '';
  User? nowUser;
  String uid = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    var data = await _store.collection('trip').doc(widget.tripName).get();
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      nowUser = user;
    }
    uid = data.data()!['owner'];
    Timestamp tt1 = data.data()!['start'];
    Timestamp tt2 = data.data()!['end'];
    dayNum = data.data()!['day'] + 1;
    startDay = tt1.toDate();
    endDay = tt2.toDate();
    setState(() {
      loading = false;
      if (nowUser?.uid == uid) owner = true;
    });
  }

  void getPlanData(int d) async {
    var data = await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day$d')
        .doc()
        .get();
    // data.data()!['plan'];
    setState(() {
      activeDay = 'Day${d + 1}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: Column(
          children: [
            //여행 일정
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 3,
                  color: Colors.black,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '여행 일정',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: Colors.black,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '${startDay?.year}.${startDay?.month}.${startDay?.day}',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '~',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${endDay?.year}.${endDay?.month}.${endDay?.day}',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //Day
            Container(
              height: 70,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dayNum,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            color: Colors.blue[300],
                          ),
                          child: TextButton(
                            onPressed: () {
                              getPlanData(index);
                            },
                            child: Text(
                              'Day${index + 1}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              color: Colors.blue,
            ),
            const SizedBox(
              height: 10,
            ),
            //Plan
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(activeDay),
            ),
          ],
        ),
      ),
    );
  }
}
