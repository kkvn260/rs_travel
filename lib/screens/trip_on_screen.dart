import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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
  List<bool> userCk = List.empty(growable: true);
  String activeDay = 'Day1';
  User? nowUser;
  String uid = '';
  String tripName = '';
  int addPlanDay = 0;
  String _plan = '';
  String tripId = '';
  var dayGroup = ['아침', '점심', '저녁'];
  String selGroup = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    tripId = widget.tripName;
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

  void addPlan(int addDay, String plan, String group) async {
    await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day$addDay')
        .doc(group)
        .set({
      'plan': plan,
      'user': nowUser?.uid,
      'time': Timestamp.now(),
      'like': 0,
      'dislike': 0,
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

  void likePlan(String id, bool yn, int ynNum) async {
    bool isMe = false;
    String id2 = '';
    var data = await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day$addPlanDay')
        .doc(id)
        .collection(yn ? "like" : 'dislike')
        .get();

    var data2 = _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day$addPlanDay')
        .doc(id);

    if (data.docs.isNotEmpty) {
      for (int i = 0; i < data.docs.length; i++) {
        var user = data.docs.toList()[i].data()['user'];
        if (user == nowUser?.uid) {
          id2 = data.docs.toList()[i].id;
          isMe = true;
          break;
        }
      }
    }
    if (isMe) {
      await _store
          .collection('trip')
          .doc(widget.tripName)
          .collection('day$addPlanDay')
          .doc(id)
          .collection(yn ? "like" : 'dislike')
          .doc(id2)
          .delete();
      await data2.update(yn ? {'like': ynNum - 1} : {'dislike': ynNum - 1});
    } else {
      await _store
          .collection('trip')
          .doc(widget.tripName)
          .collection('day$addPlanDay')
          .doc(id)
          .collection(yn ? "like" : 'dislike')
          .doc()
          .set({
        'user': nowUser?.uid,
      });
      await data2.update(yn ? {'like': ynNum + 1} : {'dislike': ynNum + 1});
    }
    setState(() {
      loading = false;
    });
  }

  void delPlan(int index, String id) async {
    var data = await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day$addPlanDay')
        .doc(id)
        .get();
    var user = data.data()!['user'];
    if (user == nowUser?.uid) {
      await _store
          .collection('trip')
          .doc(widget.tripName)
          .collection('day$addPlanDay')
          .doc(id)
          .delete();
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
    for (int i = 0; i < dayNum; i++) {
      var data = await _store
          .collection('trip')
          .doc(widget.tripName)
          .collection('day$i')
          .get();
      if (data.size > 0) {
        var dataNum = data.docs.toList().length;
        for (int j = 0; j < dataNum; j++) {
          await _store
              .collection('trip')
              .doc(widget.tripName)
              .collection('day$i')
              .doc(data.docs.toList()[i].id)
              .delete();
        }
      }
    }
    await _store.collection('trip').doc(widget.tripName).delete();
    setState(() {
      loading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  content: const Text(
                                    '정말 삭제하시겠습니까?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  actions: [
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          loading = true;
                                        });
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
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  content: const Text(
                                    '일정에서 나가시겠습니까?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
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
                return ExpansionTile(
                    title: const Text(
                      '아침',
                    ),
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 3,
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                          itemCount: planDocs.length,
                          itemBuilder: (context, index) {
                            bool d = false;
                            if (nowUser?.uid ==
                                planDocs.toList()[index].data()['user']) {
                              d = true;
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.7,
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
                                        onPressed: () {
                                          delPlan(index,
                                              planDocs.toList()[index].id);
                                        },
                                        icon: Icon(
                                          owner ? Icons.delete : null,
                                          size: 25,
                                          color:
                                              d ? Colors.black : Colors.white,
                                        ),
                                      ),
                                      StreamBuilder(
                                          stream: _store
                                              .collection('trip')
                                              .doc(widget.tripName)
                                              .collection('day$addPlanDay')
                                              .doc(planDocs.toList()[index].id)
                                              .collection('like')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            int likeNum = 0;
                                            bool d = false;
                                            if (snapshot.hasData) {
                                              int size = snapshot.data!.docs
                                                  .toList()
                                                  .length;
                                              likeNum =
                                                  snapshot.data!.docs.length;
                                              for (int i = 0; i < size; i++) {
                                                if (snapshot.data!.docs
                                                        .toList()[i]
                                                        .data()['user'] ==
                                                    nowUser?.uid) {
                                                  d = true;
                                                }
                                              }
                                            }
                                            return Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      loading = true;
                                                      likePlan(
                                                        planDocs
                                                            .toList()[index]
                                                            .id,
                                                        true,
                                                        likeNum,
                                                      );
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.thumb_up,
                                                    size: 25,
                                                    color: d
                                                        ? Colors.blue
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                Text('$likeNum'),
                                              ],
                                            );
                                          }),
                                      StreamBuilder(
                                          stream: _store
                                              .collection('trip')
                                              .doc(widget.tripName)
                                              .collection('day$addPlanDay')
                                              .doc(planDocs.toList()[index].id)
                                              .collection('dislike')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            int dislikeNum = 0;
                                            bool d = false;
                                            if (snapshot.hasData) {
                                              int size = snapshot.data!.docs
                                                  .toList()
                                                  .length;
                                              dislikeNum =
                                                  snapshot.data!.docs.length;
                                              for (int i = 0; i < size; i++) {
                                                if (snapshot.data!.docs
                                                        .toList()[i]
                                                        .data()['user'] ==
                                                    nowUser?.uid) {
                                                  d = true;
                                                }
                                              }
                                            }
                                            return Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      loading = true;
                                                      likePlan(
                                                        planDocs
                                                            .toList()[index]
                                                            .id,
                                                        false,
                                                        dislikeNum,
                                                      );
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.thumb_down,
                                                    size: 25,
                                                    color: d
                                                        ? Colors.red
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                Text('$dislikeNum'),
                                              ],
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ]);
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
                        addPlan(addPlanDay, _plan, selGroup);
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
                    child: Column(
                      children: [
                        DropdownButton(
                          value: dayGroup[0],
                          items: dayGroup
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selGroup = value!;
                            });
                          },
                        ),
                        TextField(
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
                      ],
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
