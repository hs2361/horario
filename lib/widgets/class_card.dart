import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/class.dart';
import '../providers/classes.dart';
import '../widgets/new_class.dart';
import 'new_assignment.dart';

// ignore: must_be_immutable
class ClassCard extends StatelessWidget {
  final Class c;
  ClassCard(this.c);
  Offset _tapPosition = Offset.zero;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

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
    return GestureDetector(
      onTapDown: _storePosition,
      onLongPress: () {
        showMenu(
          position: RelativeRect.fromRect(
              _tapPosition & const Size(40, 40), // smaller rect, the touch area
              Offset.zero &
                  MediaQuery.of(context).size // Bigger rect, the entire screen
              ),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              value: 0,
              child: Row(
                children: const <Widget>[
                  Icon(Icons.delete),
                  Text("Delete"),
                ],
              ),
            )
          ],
          context: context,
        ).then((choice) async {
          if (choice == 0) {
            await Provider.of<Classes>(context, listen: false)
                .deleteClass(c.id);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          color: c.color,
          child: ListTile(
            title: Text(c.subject),
            subtitle: Text(timeString),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      if (c.schedule != null) {
                        Navigator.of(context)
                            .pushNamed(NewClass.routeName, arguments: {
                          'subject': c.subject,
                          'link': c.link,
                          'schedule':
                              Provider.of<Classes>(context, listen: false)
                                  .getClassbyId(c.id)
                                  .schedule,
                          'color': c.color,
                          'id': c.id
                        });
                      } else {
                        Navigator.of(context)
                            .pushNamed(NewAssignment.routeName, arguments: {
                          'subject': c.subject,
                          'link': c.link,
                          'deadline': c.deadline,
                          'color': c.color,
                          'id': c.id
                        });
                      }
                    }),
                if (c.link != null)
                  IconButton(
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
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
