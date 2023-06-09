import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

Future<dynamic> calendarDialog(BuildContext context) async {
  var date = DateTime.now();
  DateTime? selDate;

  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: SingleChildScrollView(
          child: AlertDialog(
            title: const Text('날짜 선택'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              height: MediaQuery.of(context).size.height / 1.5,
              child: TableCalendar(
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarFormat: CalendarFormat.month,
                locale: 'ko_KR',
                daysOfWeekHeight: 30,
                focusedDay: date,
                firstDay: DateTime.utc(date.year, 1, 31),
                lastDay: DateTime.utc(date.year + 1, 12, 31),
                onDaySelected: (selectedDay, focusedDay) {
                  selDate = selectedDay;
                  Navigator.pop(context);
                },
                selectedDayPredicate: (day) {
                  return isSameDay(selDate, day);
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  ).then((value) => selDate);
}
