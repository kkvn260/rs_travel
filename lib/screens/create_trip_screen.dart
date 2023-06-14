import 'package:flutter/material.dart';
import 'package:rs_travel/config/calendar_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rs_travel/screens/trip_on_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CreateTrip extends StatefulWidget {
  const CreateTrip({super.key});

  @override
  State<CreateTrip> createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip> {
  DateTime? startDate;
  DateTime? endDate;
  bool isDate = false;
  bool isDate2 = false;
  bool formCk = false;
  final _store = FirebaseFirestore.instance;
  String id = '';
  String tripName = '';
  bool loading = false;

  Future getStartDate() async {
    startDate = await calendarDialog(context);
    setState(() {
      if (startDate?.day == null) {
        isDate = false;
      } else {
        isDate = true;
      }
    });
  }

  Future getEndDate() async {
    endDate = await calendarDialog(context);
    setState(() {
      if (endDate?.day == null) {
        isDate2 = false;
      } else {
        isDate2 = true;
      }
    });
  }

  void _createTrip(bool ck) async {
    Duration d = endDate!.difference(startDate!);
    int days = 0;
    days = d.inDays;
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('trip').doc().set({
      'time': Timestamp.now(),
      'name': tripName,
      'owner': user!.uid,
      'start': startDate,
      'end': endDate,
      'day': days,
    });
    var result = await _store.collection('trip').get();
    for (int i = 0; i < result.size; i++) {
      var name = result.docs.toList()[i].data()['name'];
      if (tripName == name) {
        setState(() {
          id = result.docs.toList()[i].id;
        });
      }
    }
    await FirebaseFirestore.instance
        .collection('trip')
        .doc(id)
        .collection('group')
        .doc()
        .set({
      'user': user.uid,
    });
    setState(() {
      loading = false;
    });
    goTrip();
  }

  void formCheck() async {
    var error = false;
    if (isDate && isDate2 && tripName.isNotEmpty) {
      if (startDate!.microsecondsSinceEpoch <=
          endDate!.microsecondsSinceEpoch) {
        formCk = true;
        _createTrip(formCk);
        setState(() {
          loading = true;
        });
      } else {
        error = true;
      }
    } else {
      formCk = false;
    }
    if (formCk) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1000),
          content: Text(
            error ? '시작일과 종료일을 정확히 입력 해주세요.' : '입력을 모두 완료해 주세요.',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w200,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void goTrip() {
    // Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripOn(
          tripName: id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text(
            '일정 생성',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: ModalProgressHUD(
          inAsyncCall: loading,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '날짜 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      getStartDate();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 3,
                          color: Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            '시작일',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isDate
                                ? '${startDate?.year}.${startDate?.month}.${startDate?.day}'
                                : '날짜를 선택해 주세요.',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      getEndDate();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 3,
                          color: Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            '종료일',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isDate2
                                ? '${endDate?.year}.${endDate?.month}.${endDate?.day}'
                                : '날짜를 선택해 주세요.',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        tripName = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '일정 이름을 입력해 주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: const Text(
                        '일정 이름',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                            Colors.orange,
                          ),
                        ),
                        onPressed: () {
                          formCheck();
                        },
                        child: const Text(
                          '완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      FilledButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                            Colors.grey[300],
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
