import 'package:flutter/material.dart';

class Note with ChangeNotifier {
  String id;
  String? user;
  //TODO make a boolean
  int? messageType;
  DateTime? sentTime;
  String? notesName;
  String? messageBody;
  String? subject;
  String? filename;
  String? fileUrl;

  Note({
    this.id = "",
    this.user,
    this.messageType,
    this.sentTime,
    this.subject,
    this.filename,
    this.notesName,
    this.messageBody,
    this.fileUrl,
  });
}
