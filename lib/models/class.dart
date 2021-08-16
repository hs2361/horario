import 'package:flutter/material.dart';

import 'time_slot.dart';

class Class {
  String id;
  String subject;
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

