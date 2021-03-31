import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

import './group_chat_class.dart';

class ChatCollection with ChangeNotifier {
  //dummy data for testing purposes
  final List<GroupChatClass> _chats = [
    GroupChatClass(
      notesName: "Physics",
      color: Colors.pink,
      user: "UID",
      messageType: 0,
      messageBody: "Notes chahiye"
    ),
    GroupChatClass(
      notesName: "Chemistry",
      color: Colors.purple,
      user: "2zZWzj2gOuOz2XrJIifcoTMqt3C3",
      messageType: 1,
      messageBody: "Notes lele"
    )
  ];

  //Real code
  void addChat({
    String? user,
    String? notesName,
    DateTime? currTime,
    int? messageType,
    String? messageBody,
    Color color = Colors.blueAccent,
  }) {
    _chats.add(
      GroupChatClass(
        user: user,
        notesName: notesName,
        sentTime: currTime,
        messageType: messageType,
        messageBody: messageBody,
        color: color,
      ),
    );
    notifyListeners();
  }

  List<GroupChatClass> get chat {
    final List<GroupChatClass> currchat = _chats;
    
    return currchat;
  }
}