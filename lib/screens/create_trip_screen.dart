import 'package:flutter/material.dart';
import 'package:rs_travel/config/calendar_dialog.dart';
import 'package:rs_travel/screens/trip_on_screen.dart';

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
  bool isHover = false;
  bool formCk = false;

  String tripName = '';

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

  _createTrip() {}

  void formCheck() {
    var error = false;
    if (isDate && isDate2 && tripName.isNotEmpty) {
      if (startDate!.microsecondsSinceEpoch <=
          endDate!.microsecondsSinceEpoch) {
        formCk = true;
      } else {
        error = true;
      }
    } else {
      formCk = false;
    }
    if (formCk) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TripOn(),
        ),
      );
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
        body: SingleChildScrollView(
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
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          isHover ? Colors.orange : Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        formCheck();
                        _createTrip();
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
    );
  }
}
