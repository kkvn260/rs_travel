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
  List<bool> btCk2 = List.empty(growable: true);
  String activeDay = 'Day1';
  User? nowUser;
  String uid = '';
  String tripName = '';
  int addPlanDay = 0;
  String _plan = '';

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
    tripName = data.data()!['name'];
    Timestamp tt1 = data.data()!['start'];
    Timestamp tt2 = data.data()!['end'];
    dayNum = data.data()!['day'] + 1;
    for (int i = 0; i < dayNum; i++) {
      if (i == 0) {
        btCk.add(true);
        btCk2.add(false);
      } else {
        btCk.add(false);
        btCk2.add(false);
      }
    }
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
    setState(() {
      activeDay = 'Day${d + 1}';
    });
  }

  void addPlan(int addDay, String plan) async {
    await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day$addDay')
        .doc()
        .set({
      'plan': plan,
      'time': Timestamp.now(),
    });
  }

  void activeBt(int now) {
    btCk.setAll(0, btCk2);
    btCk[now] = true;
    setState(() {});
  }

  bool nowDay(int now) {
    if (btCk[now]) {
      return true;
    } else {
      return false;
    }
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
                  Text(
                    tripName,
                    style: const TextStyle(
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
                      const Text(
                        '여행 일정 : ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${startDay?.year}.${startDay?.month}.${startDay?.day}',
                        style: const TextStyle(
                          fontSize: 20,
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
                          fontSize: 20,
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
                            color: nowDay(index)
                                ? Colors.orange
                                : Colors.blue[300],
                          ),
                          child: TextButton(
                            onPressed: () {
                              getPlanData(index);
                              setState(() {
                                activeBt(index);
                                addPlanDay = index;
                              });
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
            StreamBuilder(
              stream: _store
                  .collection('trip')
                  .doc(widget.tripName)
                  .collection('day$addPlanDay')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final planDocs = snapshot.data!.docs;
                return Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                      itemCount: planDocs.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.7,
                              child: Text(
                                ' - ${planDocs[index]['plan']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      owner ? Icons.delete : null,
                                      size: 25,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.thumb_up,
                                      size: 25,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.thumb_down,
                                      size: 25,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      //일정추가
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.blue[300],
          borderRadius: BorderRadius.circular(30),
        ),
        child: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    '일정 추가',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        addPlan(addPlanDay, _plan);
                      },
                      child: const Text('확인'),
                    ),
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('취소'),
                    ),
                  ],
                  content: Container(
                    padding: const EdgeInsets.all(5),
                    height: 90,
                    width: 300,
                    child: TextField(
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                      decoration: const InputDecoration(
                        label: Text(
                          '내용을 입력해주세요.',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _plan = value;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          },
          icon: const Icon(Icons.add),
          color: Colors.white,
        ),
      ),
    );
  }
}
