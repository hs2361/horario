import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:horario/providers/class.dart';

class ClassCard extends StatelessWidget {
  final Class c;
  const ClassCard(this.c);

  @override
  Widget build(BuildContext context) {
    String timeString;
    if (c.schedule != null) {
      timeString =
          "${(c.schedule ?? [])[0][0].item1.format(context)} - ${(c.schedule ?? [])[0][0].item2.format(context)}";
    } else {
      timeString =
          "Due ${DateFormat('HH:MM').format(c.deadline ?? DateTime.now())}";
    }
    return Container(
      padding: const EdgeInsets.all(8),
      height: 100,
      child: Card(
        color: c.color,
        child: ListTile(
          title: Text(c.subject),
          subtitle: Text(timeString),
        ),
      ),
    );
  }
}