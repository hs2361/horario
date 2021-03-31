import 'package:flutter/material.dart';

class Note with ChangeNotifier {
  String? user;
  int? messageType;
  DateTime? sentTime;
  String? notesName;
  String? messageBody;
  Color color;
  String? subject;
  String? filename;

  Note({
    this.user = "",
    this.messageType,
    this.sentTime,
    this.subject,
    this.filename,
    this.notesName,
    this.messageBody,
    this.color = Colors.blueAccent,
  });
}
