import 'package:flutter/material.dart';
import 'package:horario/providers/note.dart';

class GroupChatCard extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final Note curr_chat_msg;
  const GroupChatCard(this.curr_chat_msg);

  @override
  Widget build(BuildContext context) {
    String timeString;
    // timeString = DateFormat('HH:MM').format(curr_chat_msg.sentTime ?? DateTime.now());
    timeString = "11:04";
    Card currCard = Card();

    //Get userID from firebase here
    String? currUser = "2zZWzj2gOuOz2XrJIifcoTMqt3C3";

    return Container(
      width: 300,
      padding: EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
      child: Align(
        alignment: (curr_chat_msg.user == currUser
            ? Alignment.topLeft
            : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (curr_chat_msg.user == currUser
                ? Colors.blue[200]
                : Colors.grey.shade200),
          ),
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (curr_chat_msg.messageType == 1)
                    ? "Request made for " + (curr_chat_msg.notesName ?? "")
                    : "Notes for " +
                        (curr_chat_msg.notesName ?? "") +
                        " Uploaded",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              Text(
                curr_chat_msg.messageBody ?? "",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              Text(
                timeString,
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
