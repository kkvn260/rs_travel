import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rs_travel/plan/trip_plan.dart';

class TripOn extends StatefulWidget {
  const TripOn({
    super.key,
    required this.tripName,
  });

  final String tripName;
  static bool loading = true;

  @override
  State<TripOn> createState() => _TripOnState();
}

class _TripOnState extends State<TripOn> {
  final _store = FirebaseFirestore.instance;
  int dayNum = 0;
  DateTime? startDay;
  DateTime? endDay;
  bool owner = false;
  List<bool> btCk = List.empty(growable: true);
  List<bool> btCk2 = List.empty(growable: true);
  List<bool> userCk = List.empty(growable: true);
  String activeDay = 'Day1';
  User? nowUser;
  String uid = '';
  String tripName = '';
  int addPlanDay = 0;
  String _plan = '';
  String _link = '';
  String tripId = '';
  var dayGroup = ['아침', '점심', '저녁'];
  String selGroup = '';
  String nickName = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    selGroup = dayGroup[0];
    tripId = widget.tripName;
    var data = await _store.collection('trip').doc(widget.tripName).get();
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var getNick = await _store.collection('user').doc(user.uid).get();
      nowUser = user;
      nickName = getNick.data()!['userName'];
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
      TripOn.loading = false;
      if (nowUser?.uid == uid) owner = true;
    });
  }

  void getPlanData(int d) async {
    await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day$d')
        .doc()
        .get();
    setState(() {
      activeDay = 'Day${d + 1}';
    });
  }

  void addPlan(int addDay, String plan, String group, String link) async {
    await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day$addDay')
        .doc(group)
        .collection(group)
        .doc()
        .set({
      'plan': plan,
      'user': nowUser?.uid,
      'time': Timestamp.now(),
      'like': 0,
      'dislike': 0,
      'link': link,
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

  void delTrip() async {
    var data = await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('group')
        .get();
    var dataNum = data.docs.toList().length;
    for (int i = 0; i < dataNum; i++) {
      await _store
          .collection('trip')
          .doc(widget.tripName)
          .collection('group')
          .doc(data.docs.toList()[i].id)
          .delete();
    }
    for (int j = 0; j < 2; j++) {
      var day = ['아침', '점심', '저녁'];
      for (int i = 0; i < dayNum; i++) {
        var data = await _store
            .collection('trip')
            .doc(widget.tripName)
            .collection('day$i')
            .doc(day[j])
            .collection(day[j])
            .get();
        if (data.size > 0) {
          var dataNum = data.docs.toList().length;
          for (int i1 = 0; i1 < dataNum; i1++) {
            var like = await _store
                .collection('trip')
                .doc(widget.tripName)
                .collection('day$i')
                .doc(day[j])
                .collection(day[j])
                .doc(data.docs.toList()[i1].id)
                .collection('like')
                .get();
            if (like.docs.toList().isNotEmpty) {
              for (int i2 = 0; i2 < like.docs.length; i2++) {
                _store
                    .collection('trip')
                    .doc(widget.tripName)
                    .collection('day$i')
                    .doc(day[j])
                    .collection(day[j])
                    .doc(data.docs.toList()[i1].id)
                    .collection('like')
                    .doc(like.docs.toList()[i2].id)
                    .delete();
              }
            }
            var dislike = await _store
                .collection('trip')
                .doc(widget.tripName)
                .collection('day$i')
                .doc(day[j])
                .collection(day[j])
                .doc(data.docs.toList()[i1].id)
                .collection('dislike')
                .get();
            if (dislike.docs.toList().isNotEmpty) {
              for (int i2 = 0; i2 < dislike.docs.length; i2++) {
                _store
                    .collection('trip')
                    .doc(widget.tripName)
                    .collection('day$i')
                    .doc(day[j])
                    .collection(day[j])
                    .doc(data.docs.toList()[i1].id)
                    .collection('dislike')
                    .doc(dislike.docs.toList()[i2].id)
                    .delete();
              }
            }
          }
          await _store
              .collection('trip')
              .doc(widget.tripName)
              .collection('day$i')
              .doc(day[j])
              .collection(day[j])
              .doc(data.docs.toList()[i].id)
              .delete();
        }
      }
    }
    await _store.collection('trip').doc(widget.tripName).delete();
    setState(() {
      TripOn.loading = false;
    });
    goMenu();
  }

  void outTrip() async {
    var data = await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('group')
        .get();
    var dataNum = data.docs.toList().length;
    for (int i = 0; i < dataNum; i++) {
      if (data.docs.toList()[i].data()['user'] == nowUser?.uid) {
        await _store
            .collection('trip')
            .doc(widget.tripName)
            .collection('group')
            .doc(data.docs.toList()[i].id)
            .delete();
      }
    }
    goMenu();
  }

  void changeTripName(String name) async {
    await _store.collection('trip').doc(widget.tripName).update({'name': name});
    setState(() {
      tripName = name;
    });
  }

  void goMenu() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<bool> onBack() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        '일정 공유',
                        style: TextStyle(
                          fontFamily: 'komi',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        child: Column(
                          children: [
                            const Text(
                              '코드를 클릭하여 복사한뒤\n일정을 공유해보세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'komi',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontFamily: 'komi',
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: tripId,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(milliseconds: 1000),
                                    content: Text(
                                      '복사 완료.',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'komi',
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                    backgroundColor: Colors.grey,
                                  ),
                                );
                              },
                              child: Text(tripId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.share),
            ),
            PopupMenuButton(
              position: PopupMenuPosition.under,
              enabled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: owner
                        ? TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      '일정 삭제',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'komi',
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    content: const Text(
                                      '정말 삭제하시겠습니까?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'komi',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    actions: [
                                      FilledButton(
                                        onPressed: () {
                                          setState(() {
                                            TripOn.loading = true;
                                          });
                                          Navigator.pop(context);
                                          delTrip();
                                        },
                                        child: const Text('예'),
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
                                        child: const Text('아니오'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text(
                              '일정 삭제',
                              style: TextStyle(
                                fontFamily: 'komi',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : TextButton(
                            //일정 나가기
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      '일정 나가기',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'komi',
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    content: const Text(
                                      '일정에서 나가시겠습니까?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'komi',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    actions: [
                                      FilledButton(
                                        onPressed: () {
                                          outTrip();
                                        },
                                        child: const Text('예'),
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
                                        child: const Text('아니오'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text(
                              '일정 나가기',
                              style: TextStyle(
                                fontFamily: 'komi',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  PopupMenuItem(
                    child: owner
                        ? TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String cName = '';
                                  return AlertDialog(
                                    title: const Text(
                                      '일정 이름 변경',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'komi',
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    content: TextField(
                                      decoration: const InputDecoration(
                                        label: Text('변경할 이름'),
                                      ),
                                      onChanged: (value) => cName = value,
                                    ),
                                    actions: [
                                      FilledButton(
                                        onPressed: () {
                                          changeTripName(cName);
                                          Navigator.of(context).pop();
                                          setState(() {});
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
                            child: const Text(
                              '일정 이름 변경',
                              style: TextStyle(
                                fontFamily: 'komi',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ];
              },
            ),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: TripOn.loading,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //여행 일정
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(5),
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
                          fontFamily: 'komi',
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
                              fontFamily: 'komi',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${startDay?.year}.${startDay?.month}.${startDay?.day}',
                            style: const TextStyle(
                              fontFamily: 'komi',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '~',
                            style: TextStyle(
                              fontFamily: 'komi',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${endDay?.year}.${endDay?.month}.${endDay?.day}',
                            style: const TextStyle(
                              fontFamily: 'komi',
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                                    fontFamily: 'komi',
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
                TripPlan(
                  tripName: widget.tripName,
                  addPlanDay: addPlanDay,
                  nowUser: nowUser,
                  owner: owner,
                  group: '아침',
                ),
                TripPlan(
                  tripName: widget.tripName,
                  addPlanDay: addPlanDay,
                  nowUser: nowUser,
                  owner: owner,
                  group: '점심',
                ),
                TripPlan(
                  tripName: widget.tripName,
                  addPlanDay: addPlanDay,
                  nowUser: nowUser,
                  owner: owner,
                  group: '저녁',
                ),
              ],
            ),
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
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              child: DropdownButton(
                                value: selGroup,
                                items: dayGroup
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: const TextStyle(
                                            fontFamily: 'komi',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selGroup = value!;
                                  });
                                },
                              ),
                            ),
                            const Text(
                              '일정 추가',
                              style: TextStyle(
                                fontFamily: 'komi',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              addPlan(addPlanDay, _plan, selGroup, _link);
                            },
                            child: const Text('확인'),
                          ),
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.grey),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('취소'),
                          ),
                        ],
                        content: Container(
                          padding: const EdgeInsets.all(5),
                          height: 200,
                          width: 300,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  style: const TextStyle(
                                    fontFamily: 'komi',
                                    fontSize: 25,
                                  ),
                                  decoration: const InputDecoration(
                                    label: Text(
                                      '내용을 입력해주세요.',
                                      style: TextStyle(
                                        fontFamily: 'komi',
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
                                TextField(
                                  style: const TextStyle(
                                    fontFamily: 'komi',
                                    fontSize: 20,
                                  ),
                                  decoration: const InputDecoration(
                                    label: Text(
                                      '링크 참조',
                                      style: TextStyle(
                                        fontFamily: 'komi',
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _link = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
