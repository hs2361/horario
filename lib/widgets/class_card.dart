import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/class.dart';

class ClassCard extends StatelessWidget {
  final Class c;
  const ClassCard(this.c);

  @override
  Widget build(BuildContext context) {
    String timeString;
    if (c.schedule != null) {
      timeString =
          "${(c.schedule ?? [])[0].start.format(context)} - ${(c.schedule ?? [])[0].end.format(context)}";
    } else {
      timeString =
          "Due ${DateFormat('HH:mm').format(c.deadline ?? DateTime.now())}";
    }
    return Container(
      padding: const EdgeInsets.all(8),
      height: 100,
      child: Card(
        color: c.color,
        child: ListTile(
          title: Text(c.subject),
          subtitle: Text(timeString),
          trailing: c.link != null
              ? IconButton(
                  icon: const Icon(Icons.videocam_rounded),
                  onPressed: () async {
                    if (await canLaunch(c.link ?? "")) {
                      await launch(
                        c.link ?? "",
                        forceSafariVC: false,
                      );
                    } else {
                      throw "Could not launch URL";
                    }
                  })
              : null,
        ),
      ),
    );
  }
}
