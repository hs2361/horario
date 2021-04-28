import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import '../providers/notification_service.dart';
import './auth_service.dart';
import './note.dart';

class Notes with ChangeNotifier {
  BuildContext context;

  Notes(this.context);

  final List<String> _subjects = [];
  final List<Note> _notes = [];

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
    final String groupId =
        Provider.of<AuthService>(context, listen: false).getGroupId!;
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

      final List<String> actions = ["Requested", "Uploaded"];
      await Provider.of<NotificationService>(context, listen: false)
          .sendGroupNotification(
        title: "Notes for $notesName ${actions[messageType!]}",
        body: "Subject: $subject",
        token: (await Provider.of<AuthService>(context, listen: false).token) ??
            "",
        groupId: groupId,
      );
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
    final String groupId =
        Provider.of<AuthService>(context, listen: false).getGroupId!;
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
    final int index = _notes.indexWhere((c) => c.id == id);
    final FirebaseStorage storage = FirebaseStorage.instance;
    final String uploadPath =
        "uploads/${Provider.of<AuthService>(context, listen: false).userId}";
    await storage.ref("$uploadPath/${_notes[index].filename}").delete();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String groupId =
        Provider.of<AuthService>(context, listen: false).getGroupId!;
    final DocumentReference c =
        firestore.collection('groups').doc(groupId).collection('chat').doc(id);
    await c.delete();
    _notes.removeAt(index);
    notifyListeners();
  }

  List<Note> get groupChat => [..._notes];

  List<String> get subjectList => [..._subjects];

  List<Note> subjectwiseNotes(String subject) =>
      _notes.where((n) => n.messageType == 1 && n.subject == subject).toList();

  List<Note> get allNotes => _notes.where((n) => n.messageType == 1).toList();

  Future<void> fetchNotesFromFirestore(String groupId) async {
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
            messageBody: notesData?['message_body'] as String?,
            notesName: notesData?['notes_name'] as String,
            sentTime: notesData?['sent_at'].toDate() as DateTime,
            user: notesData?['user'] as String,
            filename: notesData?['filename'] as String?,
            fileUrl: notesData?['fileurl'] as String?,
          ),
        );

        if (!_subjects.contains(currSubject) &&
            (notesData?['message_type'] as int) != 0) {
          _subjects.add(currSubject);
        }
      }
      _notes.sort((a, b) => a.sentTime!.compareTo(b.sentTime!));
      notifyListeners();
    } on Exception {
      rethrow;
    }
  }
}
