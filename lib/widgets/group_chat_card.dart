import 'package:flutter/material.dart';
import 'package:horario/providers/auth_service.dart';
import 'package:horario/providers/note.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupChatCard extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final Note curr_chat_msg;
  const GroupChatCard(this.curr_chat_msg);

  @override
  Widget build(BuildContext context) {
    final String timeString =
        DateFormat('HH:mm').format(curr_chat_msg.sentTime ?? DateTime.now());


    final String currUser =
        Provider.of<AuthService>(context, listen: false).userId!;

    return Row(
      children: [
        if (curr_chat_msg.user == currUser)
          const SizedBox(
            width: 60,
          ),
        Container(
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
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    Text(
                      curr_chat_msg.messageBody ?? "",
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    Text(
                      timeString,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ],
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
