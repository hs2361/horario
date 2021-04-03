import 'package:flutter/material.dart';

class Class with ChangeNotifier {
  String id;
  final String subject;
  String? link;
  DateTime? deadline;
  List<TimeSlot>? schedule;
  Color color;

  Class({
    this.id = "",
    this.subject = "",
    this.link,
    this.deadline,
    this.schedule,
    this.color = Colors.blueAccent,
  });
}

class TimeSlot {
  late int weekday;
  late TimeOfDay start;
  late TimeOfDay end;

  TimeSlot({
    required this.weekday,
    required this.start,
    required this.end,
  });

  TimeSlot.fromMap(Map<String, dynamic> data) {
    final String start = data['start'] as String;
    final String end = data['end'] as String;
    weekday = data['weekday'] as int;
    this.start = TimeOfDay(
      hour: int.parse(start.split(":")[0]),
      minute: int.parse(start.split(":")[1]),
    );
    this.end = TimeOfDay(
      hour: int.parse(end.split(":")[0]),
      minute: int.parse(end.split(":")[1]),
    );
  }

  Map<String, dynamic> get asMap => {
        'weekday': weekday,
        'start':
            "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",
        'end':
            "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
      };
}
