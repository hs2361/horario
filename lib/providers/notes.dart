import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import 'auth_service.dart';
import 'note.dart';

class Notes with ChangeNotifier {
  BuildContext context;

  Notes(this.context);

  final List<String> _subjects = [];
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
    String? fileURL,
  }) async {
    _notes.add(
      Note(
        id: DateTime.now().toString(),
        user: user,
        notesName: notesName,
        sentTime: currTime,
        messageType: messageType,
        messageBody: messageBody,
        subject: subject,
        filename: filename,
        fileUrl: fileURL,
      ),
    );
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    //TODO: make logic for finding group ID from user profile
    final String groupId = Provider.of<AuthService>(context).getGroupId!;
    final CollectionReference notes =
        firestore.collection('groups').doc(groupId).collection('chat');

    try {
      final DocumentReference notesDoc = await notes.add({
        'message_body': messageBody,
        'message_type': messageType,
        'user': user,
        'notes_name': notesName,
        'sent_at': DateTime.now(),
        'subject': subject,
        'filename': filename,
        'fileurl': fileURL,
      });
      _notes.last.id = notesDoc.id;
      notifyListeners();
    } on Exception {
      rethrow;
    }
  }

  Future<void> updateNote({
    required String id,
    String? user,
    String? notesName,
    int? messageType,
    String? messageBody,
    String? subject,
    String? filename,
    String? fileUrl,
  }) async {
    final int index = _notes.indexWhere((c) => c.id == id);
    _notes[index].notesName = notesName ?? _notes[index].notesName;
    _notes[index].messageType = messageType ?? _notes[index].messageType;
    _notes[index].messageBody = messageBody ?? _notes[index].messageBody;
    _notes[index].subject = subject ?? _notes[index].subject;
    _notes[index].filename = filename ?? _notes[index].filename;
    _notes[index].fileUrl = fileUrl ?? _notes[index].fileUrl;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    //TODO: make logic for finding group ID from user profile
    final String groupId = Provider.of<AuthService>(context).getGroupId!;
    final DocumentReference c =
        firestore.collection('groups').doc(groupId).collection('chat').doc(id);

    await c.update({
      'message_body': messageBody ?? _notes[index].messageBody,
      'message_type': messageType ?? _notes[index].messageType,
      'notes_name': notesName ?? _notes[index].notesName,
      'subject': subject ?? _notes[index].subject,
      'filename': filename ?? _notes[index].filename,
      'fileurl': fileUrl ?? _notes[index].fileUrl
    });
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((c) => c.id == id);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    //TODO: make logic for finding group ID from user profile
    final String groupId = Provider.of<AuthService>(context).getGroupId!;
    final DocumentReference c =
        firestore.collection('groups').doc(groupId).collection('chat').doc(id);
    await c.delete();
    notifyListeners();
  }

  List<Note> get groupchat {
    return _notes;
  }

  List<String> get subjectList {
    return _subjects;
  }

  String? currSubject;
  // ignore: avoid_setters_without_getters
  set currsub(String subject) {
    currSubject = subject;
  }

  List<Note> get subjectwiseNotes {
    final List<Note> subjectNotes = [];

    for (final Note currnote in _notes) {
      if (currnote.subject == currSubject && currnote.messageType == 1) {
        subjectNotes.add(currnote);
      }
    }

    return subjectNotes;
  }

  List<Note> get allNotes {
    final List<Note> allNotes = [];

    for (final Note currnote in _notes) {
      if (currnote.messageType == 1) {
        allNotes.add(currnote);
      }
    }

    return allNotes;
  }

  Future<void> fetchNotesFromFirestore(String groupId) async {
    //TODO: make logic for finding group ID from user profile

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference notes =
        firestore.collection('groups').doc(groupId).collection('chat');

    _notes.clear();
    _subjects.clear();

    try {
      final firestoreNotes = (await notes.get()).docs;
      for (final QueryDocumentSnapshot doc in firestoreNotes) {
        final notesData = doc.data();
        final String currSubject = notesData?['subject'] as String;
        _notes.add(
          Note(
              id: doc.id,
              subject: currSubject,
              messageType: notesData?['message_type'] as int,
              messageBody: notesData?['message_body'] as String,
              notesName: notesData?['notes_name'] as String,
              sentTime: notesData?['sent_at'].toDate() as DateTime,
              user: notesData?['user'] as String,
              filename: notesData?['filename'] as String,
              fileUrl: notesData?['fileurl'] as String),
        );

        if (!_subjects.contains(currSubject)) {
          _subjects.add(currSubject);
        }
      }
      notifyListeners();
    } on Exception {
      rethrow;
    }
  }
}
