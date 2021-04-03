import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'note.dart';

class Notes with ChangeNotifier {
  //dummy data for testing purposes
  final List<Note> _notes = [
    Note(
      notesName: "Physics lesson 1",
      color: Colors.pink,
      user: "UID",
      messageType: 0,
      messageBody: "Notes chahiye plzplzplzplzp lzplzpzlp zplzpzllzpz lppzllzplzpl zpzlpzlpz lzplzplz zlpzlpzplz lzpoplzplzlp zlpzlplzp",
      subject: "Physics"
    ),
    Note(
      notesName: "Chemistry lesson 2",
      color: Colors.purple,
      user: "2zZWzj2gOuOz2XrJIifcoTMqt3C3",
      messageType: 1,
      messageBody: "Notes lele",
      subject: "Chemistry",
      filename: "chem2.pdf"
    ),
        Note(
      notesName: "Physics lesson 1",
      color: Colors.pink,
      user: "UID",
      messageType: 0,
      messageBody: "Notes chahiye",
      subject: "Physics"
    ),
    Note(
      notesName: "Chemistry lesson 2",
      color: Colors.purple,
      user: "2zZWzj2gOuOz2XrJIifcoTMqt3C3",
      messageType: 1,
      messageBody: "Notes lele",
      subject: "Chemistry",
      filename: "chem2.pdf"
    ),
        Note(
      notesName: "Physics lesson 1",
      color: Colors.pink,
      user: "UID",
      messageType: 0,
      messageBody: "Notes chahiye",
      subject: "Physics"
    ),
    Note(
      notesName: "Chemistry lesson 2",
      color: Colors.purple,
      user: "2zZWzj2gOuOz2XrJIifcoTMqt3C3",
      messageType: 1,
      messageBody: "Notes lele",
      subject: "Chemistry",
      filename: "chem2.pdf"
    )
  ];

  //Real code
  void addNote({
    String? user,
    String? notesName,
    DateTime? currTime,
    int? messageType,
    String? messageBody,
    Color color = Colors.blueAccent,
    String? subject,
    String? filename,
  }) {
    _notes.add(
      Note(
        user: user,
        notesName: notesName,
        sentTime: currTime,
        messageType: messageType,
        messageBody: messageBody,
        color: color,
        subject: subject,
        filename: filename
      ),
    );
    notifyListeners();
  }

  List<Note> get groupchat {
    final List<Note> currchat = _notes;

    return currchat;
  }
}