import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:horario/providers/auth_service.dart';
import 'package:provider/provider.dart';

import 'note.dart';

class Notes with ChangeNotifier {
  BuildContext context;

  Notes(this.context);

  //dummy data for testing purposes
  final List<Note> _notes = [
    // Note(
    //   notesName: "Physics lesson 1",
    //   user: "UID",
    //   messageType: 0,
    //   messageBody: "Notes chahiye plzplzplzplzp lzplzpzlp zplzpzllzpz lppzllzplzpl zpzlpzlpz lzplzplz zlpzlpzplz lzpoplzplzlp zlpzlplzp",
    //   subject: "Physics"
    // ),
    // Note(
    //   notesName: "Chemistry lesson 2",
    //   user: "2zZWzj2gOuOz2XrJIifcoTMqt3C3",
    //   messageType: 1,
    //   messageBody: "Notes lele",
    //   subject: "Chemistry",
    //   filename: "chem2.pdf"
    // ),
    //     Note(
    //   notesName: "Physics lesson 1",
    //   user: "UID",
    //   messageType: 0,
    //   messageBody: "Notes chahiye",
    //   subject: "Physics"
    // ),
    // Note(
    //   notesName: "Chemistry lesson 2",
    //   user: "2zZWzj2gOuOz2XrJIifcoTMqt3C3",
    //   messageType: 1,
    //   messageBody: "Notes lele",
    //   subject: "Chemistry",
    //   filename: "chem2.pdf"
    // ),
    //     Note(
    //   notesName: "Physics lesson 1",
    //   user: "UID",
    //   messageType: 0,
    //   messageBody: "Notes chahiye",
    //   subject: "Physics"
    // ),
    // Note(
    //   notesName: "Chemistry lesson 2",
    //   user: "2zZWzj2gOuOz2XrJIifcoTMqt3C3",
    //   messageType: 1,
    //   messageBody: "Notes lele",
    //   subject: "Chemistry",
    //   filename: "chem2.pdf"
    // )
  ];

  //Real code
  Future<void> addNote({
    String? user,
    String? notesName,
    DateTime? currTime,
    int? messageType,
    String? messageBody,
    String? subject,
    String? filename,
  }) async {
    _notes.add(
      Note(
        user: user,
        notesName: notesName,
        sentTime: currTime,
        messageType: messageType,
        messageBody: messageBody,
        subject: subject,
        filename: filename
      ),
    );
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    //TODO: make logic for finding group ID from user profile
    const String groupId = "PgbZfCnPgRQPRxSEwG5a";
    final CollectionReference notes =
        firestore.collection('groups').doc(groupId).collection('chat');

    try {
      await notes.add({
        'message_body': messageBody,
        'message_type': messageType,
        'user':user,
        'notes_name':notesName,
        'sent_at': DateTime.now(),
        'subject': subject,
      });
      notifyListeners();
    } on Exception {
      rethrow;
    }
  }

  List<Note> get groupchat {
    final List<Note> currchat = _notes;

    return currchat;
  }
    
  Future<void> fetchNotesFromFirestore() async {
    //TODO: make logic for finding group ID from user profile
    const String groupId = "PgbZfCnPgRQPRxSEwG5a";
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference notes =
        firestore.collection('groups').doc(groupId).collection('chat');

    _notes.clear();

    try {
      final firestoreClasses = (await notes.get()).docs;
      for (final QueryDocumentSnapshot doc in firestoreClasses) {
        final notesData = doc.data();
        _notes.add(
          Note(
            subject: notesData?['subject'] as String,
            messageType: notesData?['message_type'] as int,
            messageBody: notesData?['message_body'] as String,
            notesName: notesData?['notes_name'] as String,
            sentTime: notesData?['sent_at'].toDate() as DateTime,
            user: notesData?['user'] as String
          ),
        );
      }
      notifyListeners();
    } on Exception {
      rethrow;
    }
  }
}