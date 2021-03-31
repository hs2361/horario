import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Class with ChangeNotifier {
  final String subject;
  String? link;
  DateTime? deadline;
  List<List<Tuple2<TimeOfDay, TimeOfDay>>>? schedule;
  Color color;

  Class({
    this.subject = "",
    this.link,
    this.deadline,
    this.schedule,
    this.color = Colors.blueAccent,
  });
}
