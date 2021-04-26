import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:horario/providers/notification_service.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import './class.dart';

class Classes with ChangeNotifier {
  BuildContext context;
  NotificationService? notificationService;
  Classes(this.context, this.notificationService);

  //dummy data for testing purposes
  // final List<Class> _classes = [
  //   Class(
  //     subject: "Homework",
  //     deadline: DateTime(2021, 3, 31),
  //     color: Colors.green,
  //   ),
  //   Class(
  //       subject: "Physics",
  //       color: Colors.pink,
  //       link: "http://www.google.com",
  //       schedule: [
  //         TimeSlot(
  //           weekday: 1,
  //           start: const TimeOfDay(hour: 10, minute: 0),
  //           end: const TimeOfDay(hour: 12, minute: 0),
  //         ),
  //         TimeSlot(
  //           weekday: 3,
  //           start: const TimeOfDay(hour: 10, minute: 0),
  //           end: const TimeOfDay(hour: 12, minute: 0),
  //         ),
  //         TimeSlot(
  //           weekday: 6,
  //           start: const TimeOfDay(hour: 10, minute: 0),
  //           end: const TimeOfDay(hour: 12, minute: 0),
  //         ),
  //       ]),
  //   Class(
  //     subject: "Chemistry",
  //     color: Colors.purple,
  //     schedule: [
  //       TimeSlot(
  //         weekday: 1,
  //         start: const TimeOfDay(hour: 13, minute: 0),
  //         end: const TimeOfDay(hour: 15, minute: 0),
  //       ),
  //       TimeSlot(
  //         weekday: 2,
  //         start: const TimeOfDay(hour: 15, minute: 0),
  //         end: const TimeOfDay(hour: 16, minute: 0),
  //       ),
  //       TimeSlot(
  //         weekday: 6,
  //         start: const TimeOfDay(hour: 9, minute: 0),
  //         end: const TimeOfDay(hour: 10, minute: 0),
  //       )
  //     ],
  //   )
  // ];

  final List<Class> _classes = [];
  List<Class> get classes => [..._classes];

  Future<void> addClass({
    required String subject,
    String? link,
    DateTime? deadline,
    List<TimeSlot>? schedule,
    Color color = Colors.blueAccent,
  }) async {
    _classes.add(
      Class(
        id: DateTime.now().toString(),
        subject: subject,
        link: link,
        deadline: deadline,
        schedule: schedule,
        color: color,
      ),
    );
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId =
        Provider.of<AuthService>(context, listen: false).userId!;
    final CollectionReference classes =
        firestore.collection('users').doc(userId).collection('classes');

    try {
      final DocumentReference classDoc = await classes.add({
        'subject': subject,
        'link': link,
        'deadline': deadline,
        'schedule':
            // ignore: prefer_null_aware_operators
            schedule != null ? schedule.map((t) => t.asMap).toList() : null,
        'color': color.value
      });
      _classes.last.id = classDoc.id;
      await notificationService!.scheduleNotification(_classes.last);
      notifyListeners();
    } on Exception {
      rethrow;
    }
  }

  Future<void> updateClass({
    required String id,
    String? subject,
    String? link,
    DateTime? deadline,
    List<TimeSlot>? schedule,
    Color? color,
  }) async {
    final int index = _classes.indexWhere((c) => c.id == id);
    _classes[index].subject = subject ?? _classes[index].subject;
    _classes[index].link = link ?? _classes[index].link;
    _classes[index].deadline = deadline ?? _classes[index].deadline;
    _classes[index].schedule = schedule ?? _classes[index].schedule;
    _classes[index].color = color ?? _classes[index].color;
    await notificationService!.cancelNotifications(_classes[index]);

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId =
        Provider.of<AuthService>(context, listen: false).userId!;
    final DocumentReference c =
        firestore.collection('users').doc(userId).collection('classes').doc(id);

    await c.update({
      'subject': subject ?? _classes[index].subject,
      'link': link ?? _classes[index].link,
      'deadline': deadline ?? _classes[index].deadline,
      'schedule':
          // ignore: prefer_null_aware_operators
          schedule != null
              ? schedule.map((t) => t.asMap).toList()
              // ignore: prefer_null_aware_operators
              : (_classes[index].schedule != null
                  ? _classes[index].schedule?.map((t) => t.asMap).toList()
                  : null),
      'color': (color ?? _classes[index].color).value
    });
    await notificationService!.scheduleNotification(_classes[index]);
    notifyListeners();
  }

  Future<void> deleteClass(String id) async {
    final int index = _classes.indexWhere((c) => c.id == id);
    await notificationService!.cancelNotifications(_classes[index]);
    _classes.removeAt(index);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId =
        Provider.of<AuthService>(context, listen: false).userId!;
    final DocumentReference c =
        firestore.collection('users').doc(userId).collection('classes').doc(id);
    await c.delete();
    notifyListeners();
  }

  Class getClassbyId(String id) => _classes.firstWhere((c) => c.id == id);

  List<List<Class>> get schedule {
    final List<List<Class>> schedule = [[], [], [], [], [], [], []];
    for (final class_ in _classes) {
      if (class_.schedule != null) {
        for (final TimeSlot t in class_.schedule!) {
          final Class scheduledClass = Class(
            id: class_.id,
            subject: class_.subject,
            link: class_.link,
            schedule: [t],
            color: class_.color,
          );
          schedule[t.weekday - 1].add(scheduledClass);
        }
      } else {
        if (class_.deadline!
                .isBefore(DateTime.now().add(const Duration(days: 6))) &&
            class_.deadline!.isAfter(DateTime.now())) {
          final Class scheduleAssignment = Class(
            id: class_.id,
            subject: class_.subject,
            link: class_.link,
            deadline: class_.deadline,
            color: class_.color,
          );
          schedule[((class_.deadline?.weekday ?? 1) - 1)]
              .add(scheduleAssignment);
        }
      }
    }
    for (final row in schedule) {
      row.sort((c1, c2) {
        if (c1.schedule != null) {
          if (c2.schedule != null) {
            final TimeOfDay t1 = (c1.schedule ?? [])[0].start;
            final TimeOfDay t2 = (c2.schedule ?? [])[0].start;
            return (t1.hour + t1.minute / 60.0 - t2.hour + t2.minute / 60.0)
                .toInt();
          } else {
            final TimeOfDay t1 = (c1.schedule ?? [])[0].start;
            final DateTime t2 = c2.deadline ?? DateTime.now();
            return (t1.hour + t1.minute / 60.0 - t2.hour + t2.minute / 60.0)
                .toInt();
          }
        } else {
          if (c2.schedule != null) {
            final DateTime t1 = c1.deadline ?? DateTime.now();
            final TimeOfDay t2 = (c2.schedule ?? [])[0].start;
            return (t1.hour + t1.minute / 60.0 - t2.hour + t2.minute / 60.0)
                .toInt();
          } else {
            final DateTime t1 = c1.deadline ?? DateTime.now();
            final DateTime t2 = c2.deadline ?? DateTime.now();
            return t1.isAfter(t2) ? 1 : 0;
          }
        }
      });
    }
    return schedule;
  }

  Future<void> fetchFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId =
        Provider.of<AuthService>(context, listen: false).userId!;
    final CollectionReference classes =
        firestore.collection('users').doc(userId).collection('classes');
    _classes.clear();

    try {
      final firestoreClasses = (await classes.get()).docs;
      for (final QueryDocumentSnapshot doc in firestoreClasses) {
        final classData = doc.data();
        final schedule = classData?['schedule'] as List<dynamic>?;
        _classes.add(
          Class(
            id: doc.id,
            subject: classData?['subject'] as String,
            link: classData?['link'] as String?,
            color: Color(classData?['color'] as int),
            deadline: classData?['deadline'] != null
                ? (classData?['deadline'] as Timestamp).toDate()
                : null,
            // ignore: prefer_null_aware_operators
            schedule: schedule != null
                ? schedule
                    .map((t) => TimeSlot.fromMap(t as Map<String, dynamic>))
                    .toList()
                : null,
          ),
        );
      }
      notifyListeners();
    } on Exception {
      rethrow;
    }
  }
}
