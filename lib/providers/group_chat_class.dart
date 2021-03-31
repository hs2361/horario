import 'package:flutter/material.dart';

class GroupChatClass with ChangeNotifier {
  String? user;
  int? messageType;
  DateTime? sentTime;
  String? notesName;
  String? messageBody;
  Color color;

  GroupChatClass({
    this.user = "",
    this.messageType,
    this.sentTime,
    this.notesName,
    this.messageBody,
    this.color = Colors.blueAccent,
  });
}
