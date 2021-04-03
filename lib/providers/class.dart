import 'package:flutter/material.dart';

class Class with ChangeNotifier {
  final String subject;
  String? link;
  DateTime? deadline;
  List<TimeSlot>? schedule;
  Color color;

  Class({
    this.subject = "",
    this.link,
    this.deadline,
    this.schedule,
    this.color = Colors.blueAccent,
  });
}

class TimeSlot {
  int weekday;
  TimeOfDay start;
  TimeOfDay end;

  TimeSlot({
    required this.weekday,
    required this.start,
    required this.end,
  });
}
