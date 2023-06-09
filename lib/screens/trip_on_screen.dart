import 'package:flutter/material.dart';

class TripOn extends StatefulWidget {
  const TripOn({super.key});

  @override
  State<TripOn> createState() => _TripOnState();
}

class _TripOnState extends State<TripOn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('ㅇㅇ'),
        ),
      ),
    );
  }
}
