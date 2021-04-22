import 'package:flutter/material.dart';
import 'package:horario/providers/notes.dart';
import 'package:horario/widgets/new_notes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import '../providers/note.dart';

class GroupChatCard extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final Note curr_chat_msg;
  GroupChatCard(this.curr_chat_msg);
  Offset _tapPosition = Offset.zero;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    final String timeString =
        DateFormat('HH:mm').format(curr_chat_msg.sentTime ?? DateTime.now());

    final String currUser =
        Provider.of<AuthService>(context, listen: false).userId!;

    void _showUpdateForm() {
      Navigator.of(context).pushNamed(NewNotes.routeName, arguments: {
        'id': curr_chat_msg.id,
        'subject': curr_chat_msg.subject,
        'filename': curr_chat_msg.filename,
        'fileUrl': curr_chat_msg.fileUrl,
        'notesDetails': curr_chat_msg.messageBody,
        'notesName': curr_chat_msg.notesName,
      });
    }

    return Row(
      children: [
        if (curr_chat_msg.user == currUser)
          const SizedBox(
            width: 60,
          ),
        GestureDetector(
          onTapDown: _storePosition,
          onLongPress: () {
            showMenu(
              position: RelativeRect.fromRect(
                  _tapPosition &
                      const Size(40, 40), // smaller rect, the touch area
                  Offset.zero &
                      MediaQuery.of(context)
                          .size // Bigger rect, the entire screen
                  ),
              items: <PopupMenuEntry>[
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: const <Widget>[
                      Icon(Icons.edit),
                      Text("Edit"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
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
                _showUpdateForm();
              } else {
                await Provider.of<Notes>(context, listen: false)
                    .deleteNote(curr_chat_msg.id);
              }
            });
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: curr_chat_msg.user != currUser
                    ? Alignment.topLeft
                    : Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: curr_chat_msg.user == currUser
                        ? Colors.blue[200]
                        : Colors.grey.shade200,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        //TYPE 0 is request type 1 is Upload
                        (curr_chat_msg.messageType == 0)
                            ? "Request made for ${curr_chat_msg.notesName ?? ""}"
                            : "Notes for ${curr_chat_msg.notesName ?? ""} Uploaded",
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      Text(
                        curr_chat_msg.messageBody ?? "",
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      Text(
                        timeString,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (curr_chat_msg.user != currUser)
          const SizedBox(
            width: 60,
          ),
      ],
    );
  }
}
