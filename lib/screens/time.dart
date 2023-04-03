import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

class MyTime extends StatefulWidget {
  const MyTime({super.key});

  @override
  State<MyTime> createState() => _MyTimeState();
}

class _MyTimeState extends State<MyTime> with WidgetsBindingObserver {
  late Timer timer;
  late String _timeString;

  @override
  void initState() {
    super.initState();

    _timeString = _formatDateTime(DateTime.now());
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    print("_getTime $_timeString");
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 30, color: Colors.white, decoration: TextDecoration.none),
    );
  }
}
