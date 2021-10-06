import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class Notes with ChangeNotifier {
  BuildContext context;

  Notes(this.context);

  final List<String> _subjects = [];
  final List<Note> _notes = [];

  Future<void> addNote({
    String? user,
    String? notesName,
    DateTime? currTime,
    bool isRequest = false,
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
        isRequest: isRequest,
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
        'is_request': isRequest,
        'user': user,
        'notes_name': notesName,
        'sent_at': DateTime.now(),
        'subject': subject,
        'filename': filename,
        'fileurl': fileURL,
      });
      _notes.last.id = notesDoc.id;

      await Provider.of<NotificationService>(context, listen: false)
          .sendGroupNotification(
        title: "Notes for $notesName ${isRequest ? "Requested" : "Uploaded"}",
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
    bool isRequest = false,
    String? messageBody,
    String? subject,
    String? filename,
    String? fileUrl,
  }) async {
    final int index = _notes.indexWhere((c) => c.id == id);
    _notes[index].notesName = notesName ?? _notes[index].notesName;
    _notes[index].isRequest = isRequest;
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
      'is_request': isRequest,
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
      _notes.where((n) => n.isRequest && n.subject == subject).toList();

  List<Note> get allNotes => _notes.where((n) => n.isRequest).toList();

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
        final String currSubject = notesData['subject'] as String;
        _notes.add(
          Note(
            id: doc.id,
            subject: currSubject,
            isRequest: notesData['is_request'] as bool,
            messageBody: notesData['message_body'] as String?,
            notesName: notesData['notes_name'] as String,
            sentTime: notesData['sent_at'].toDate() as DateTime,
            user: notesData['user'] as String,
            filename: notesData['filename'] as String?,
            fileUrl: notesData['fileurl'] as String?,
          ),
        );

        if (!_subjects.contains(currSubject) &&
            (notesData['is_request'] as bool)) {
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
