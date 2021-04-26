
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import './class.dart';

class NotificationService with ChangeNotifier {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  Future<void> initializeService() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        if (payload != null && payload.isNotEmpty) {
          if (await canLaunch(payload)) {
            await launch(
              payload,
              forceSafariVC: false,
            );
          } else {
            throw "Could not launch URL";
          }
        }
      },
    );
    await initializeFCM();
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTimeSlot(TimeSlot timeSlot) {
    final int tenMinutesBefore =
        timeSlot.start.hour * 60 + timeSlot.start.minute - 10;
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(
      TimeOfDay(
        hour: tenMinutesBefore ~/ 60,
        minute: tenMinutesBefore % 60,
      ),
    );
    while (scheduledDate.weekday != timeSlot.weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleNotification(Class _class) async {
    if (_class.schedule != null) {
      for (final TimeSlot t in _class.schedule ?? []) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          t.start.hour * 60 + t.start.minute + t.weekday,
          'Reminder: ${_class.subject} class',
          'Your class starts in 10 minutes',
          _nextInstanceOfTimeSlot(t),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _class.id,
              _class.subject,
              '${_class.subject} Class reminder',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: _class.link,
        );
      }
      notifyListeners();
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        ((_class.deadline?.millisecondsSinceEpoch) ?? 0) ~/ 60000,
        'Reminder: ${_class.subject}',
        'Your assignment is due in 10 minutes',
        // ignore: cast_nullable_to_non_nullable
        tz.TZDateTime.from(
            _class.deadline?.subtract(const Duration(minutes: 10)) ??
                DateTime.now(),
            tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _class.id,
            _class.subject,
            '${_class.subject} Assignment reminder',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _class.link,
      );
      notifyListeners();
    }
  }

  Future initializeFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final RemoteNotification notification = message.notification!;
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
            ),
          ));
    });
  }
  
  Future<void> cancelNotifications(Class _class) async {
    if (_class.schedule != null) {
      for (final TimeSlot t in _class.schedule ?? []) {
        await flutterLocalNotificationsPlugin
            .cancel(t.start.hour * 60 + t.start.minute + t.weekday);
      }
    } else {
      await flutterLocalNotificationsPlugin
          .cancel(((_class.deadline?.millisecondsSinceEpoch) ?? 0) ~/ 60000);
    }
  }
}
