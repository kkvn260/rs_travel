import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/trip_on_screen.dart';

class TripPlan extends StatefulWidget {
  const TripPlan(
      {super.key,
      required this.tripName,
      required this.addPlanDay,
      this.nowUser,
      required this.owner,
      required this.group});

  final String tripName;
  final int addPlanDay;
  final User? nowUser;
  final bool owner;
  final String group;

  @override
  State<TripPlan> createState() => _TripPlanState();
}

class _TripPlanState extends State<TripPlan> {
  final _store = FirebaseFirestore.instance;

  void likePlan(String id, bool yn, int ynNum) async {
    bool isMe = false;
    String id2 = '';
    var data = await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day${widget.addPlanDay}')
        .doc(widget.group)
        .collection(widget.group)
        .doc(id)
        .collection(yn ? "like" : 'dislike')
        .get();

    var data2 = _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day${widget.addPlanDay}')
        .doc(widget.group)
        .collection(widget.group)
        .doc(id);

    if (data.docs.isNotEmpty) {
      for (int i = 0; i < data.docs.length; i++) {
        var user = data.docs.toList()[i].data()['user'];
        if (user == widget.nowUser?.uid) {
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
          .collection('day${widget.addPlanDay}')
          .doc(widget.group)
          .collection(widget.group)
          .doc(id)
          .collection(yn ? "like" : 'dislike')
          .doc(id2)
          .delete();
      await data2.update(yn ? {'like': ynNum - 1} : {'dislike': ynNum - 1});
    } else {
      await _store
          .collection('trip')
          .doc(widget.tripName)
          .collection('day${widget.addPlanDay}')
          .doc(widget.group)
          .collection(widget.group)
          .doc(id)
          .collection(yn ? "like" : 'dislike')
          .doc()
          .set({
        'user': widget.nowUser?.uid,
      });
      await data2.update(yn ? {'like': ynNum + 1} : {'dislike': ynNum + 1});
    }
    setState(() {
      TripOn.loading = false;
    });
  }

  void delPlan(int index, String id) async {
    var data = await _store
        .collection('trip')
        .doc(widget.tripName)
        .collection('day${widget.addPlanDay}')
        .doc(widget.group)
        .collection(widget.group)
        .doc(id)
        .get();
    var user = data.data()!['user'];
    if (user == widget.nowUser?.uid) {
      await _store
          .collection('trip')
          .doc(widget.tripName)
          .collection('day${widget.addPlanDay}')
          .doc(widget.group)
          .collection(widget.group)
          .doc(id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _store
          .collection('trip')
          .doc(widget.tripName)
          .collection('day${widget.addPlanDay}')
          .doc(widget.group)
          .collection(widget.group)
          .orderBy('like', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final planDocs = snapshot.data!.docs;
        return SingleChildScrollView(
          child: ExpansionTile(
            title: Text(
              widget.group,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
                    if (widget.nowUser?.uid == planDocs[index]['user']) {
                      d = true;
                    }
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
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                delPlan(index, planDocs.toList()[index].id);
                              },
                              icon: Icon(
                                !d ? Icons.delete : null,
                                size: 25,
                                color: Colors.black,
                              ),
                            ),
                            StreamBuilder(
                                stream: _store
                                    .collection('trip')
                                    .doc(widget.tripName)
                                    .collection('day${widget.addPlanDay}')
                                    .doc(widget.group)
                                    .collection(widget.group)
                                    .doc(planDocs.toList()[index].id)
                                    .collection('like')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  int likeNum = 0;
                                  bool d = false;
                                  if (snapshot.hasData) {
                                    int size =
                                        snapshot.data!.docs.toList().length;
                                    likeNum = snapshot.data!.docs.length;
                                    for (int i = 0; i < size; i++) {
                                      if (snapshot.data!.docs
                                              .toList()[i]
                                              .data()['user'] ==
                                          widget.nowUser?.uid) {
                                        d = true;
                                      }
                                    }
                                  }
                                  return Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            TripOn.loading = true;
                                            likePlan(
                                              planDocs.toList()[index].id,
                                              true,
                                              likeNum,
                                            );
                                          });
                                        },
                                        icon: Icon(
                                          Icons.thumb_up,
                                          size: 25,
                                          color: d ? Colors.blue : Colors.grey,
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
                                    .collection('day${widget.addPlanDay}')
                                    .doc(widget.group)
                                    .collection(widget.group)
                                    .doc(planDocs.toList()[index].id)
                                    .collection('dislike')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  int dislikeNum = 0;
                                  bool d = false;
                                  if (snapshot.hasData) {
                                    int size =
                                        snapshot.data!.docs.toList().length;
                                    dislikeNum = snapshot.data!.docs.length;
                                    for (int i = 0; i < size; i++) {
                                      if (snapshot.data!.docs
                                              .toList()[i]
                                              .data()['user'] ==
                                          widget.nowUser?.uid) {
                                        d = true;
                                      }
                                    }
                                  }
                                  return Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            TripOn.loading = true;
                                            likePlan(
                                              planDocs.toList()[index].id,
                                              false,
                                              dislikeNum,
                                            );
                                          });
                                        },
                                        icon: Icon(
                                          Icons.thumb_down,
                                          size: 25,
                                          color: d ? Colors.red : Colors.grey,
                                        ),
                                      ),
                                      Text('$dislikeNum'),
                                    ],
                                  );
                                }),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
