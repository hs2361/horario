import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import './class.dart';

class Classes with ChangeNotifier {
  //dummy data for testing purposes
  final List<Class> _classes = [
    Class(
      subject: "Homework",
      deadline: DateTime(2021, 3, 31),
      color: Colors.green,
    ),
    Class(
        subject: "Physics",
        color: Colors.pink,
        link: "http://www.google.com",
        schedule: [
          TimeSlot(
            weekday: 1,
            start: const TimeOfDay(hour: 10, minute: 0),
            end: const TimeOfDay(hour: 12, minute: 0),
          ),
          TimeSlot(
            weekday: 3,
            start: const TimeOfDay(hour: 10, minute: 0),
            end: const TimeOfDay(hour: 12, minute: 0),
          ),
          TimeSlot(
            weekday: 6,
            start: const TimeOfDay(hour: 10, minute: 0),
            end: const TimeOfDay(hour: 12, minute: 0),
          ),
        ]),
    Class(
      subject: "Chemistry",
      color: Colors.purple,
      schedule: [
        TimeSlot(
          weekday: 1,
          start: const TimeOfDay(hour: 13, minute: 0),
          end: const TimeOfDay(hour: 15, minute: 0),
        ),
        TimeSlot(
          weekday: 2,
          start: const TimeOfDay(hour: 15, minute: 0),
          end: const TimeOfDay(hour: 16, minute: 0),
        ),
        TimeSlot(
          weekday: 6,
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 10, minute: 0),
        )
      ],
    )
  ];

  List<Class> get classes => [..._classes];

  void addClass({
    required String subject,
    String? link,
    DateTime? deadline,
    List<TimeSlot>? schedule,
    Color color = Colors.blueAccent,
  }) {
    _classes.add(
      Class(
        subject: subject,
        link: link,
        deadline: deadline,
        schedule: schedule,
        color: color,
      ),
    );
    notifyListeners();
  }

  List<List<Class>> get schedule {
    final List<List<Class>> schedule = [[], [], [], [], [], [], []];
    for (final class_ in _classes) {
      if (class_.schedule != null) {
        for (final TimeSlot t in class_.schedule!) {
          final Class scheduledClass = Class(
            subject: class_.subject,
            link: class_.link,
            schedule: [t],
            color: class_.color,
          );
          schedule[t.weekday - 1].add(scheduledClass);
        }
      } else {
        final Class scheduleAssignment = Class(
            subject: class_.subject,
            link: class_.link,
            deadline: class_.deadline,
            color: class_.color);
        schedule[((class_.deadline?.weekday ?? 1) - 1)].add(scheduleAssignment);
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
}
