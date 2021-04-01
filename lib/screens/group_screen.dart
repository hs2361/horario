import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:horario/providers/note.dart';
import 'package:horario/providers/notes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  void showNewClassForm(BuildContext context) {
    // Arguments => context: The context for the modal sheet to be created in
    //
    // Opens up the NewTask modal sheet to add a new task

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: Container(),
        );
      },
    );
  }

  Widget _offsetPopup() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: InkWell(
              onTap: () => showNewClassForm(context),
              child: const Text(
                "Add Class",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: InkWell(
              onTap: () {},
              child: const Text(
                "Add Assignment",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        icon: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: ShapeDecoration(
            color: Theme.of(context).cardColor,
            shape: const CircleBorder(),
          ),
          child: Icon(
            Icons.add,
            color: Theme.of(context).accentColor,
          ),
        ),
        offset: const Offset(0, -140),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      floatingActionButton: SizedBox(
        height: 75.0,
        width: 75.0,
        child: _offsetPopup(),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: Provider.of<Notes>(context).groupchat.length,
        itemBuilder: (context, index) {
          final List<Note> chat = Provider.of<Notes>(context).groupchat;
          return GroupChatCard(chat[index]);
        },
      ),
    );
  }
}

class GroupChatCard extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final Note curr_chat_msg;
  const GroupChatCard(this.curr_chat_msg);

  @override
  @override
  Widget build(BuildContext context) {
    String timeString;
    timeString =
        DateFormat('HH:MM').format(curr_chat_msg.sentTime ?? DateTime.now());
    Card currCard = Card();

    //Get userID from firebase here
    String? currUser = "2zZWzj2gOuOz2XrJIifcoTMqt3C3";
    Alignment currAlignment = Alignment.centerLeft;
    if (currUser == curr_chat_msg.user) {
      currAlignment = Alignment.centerRight;
    }

    if (curr_chat_msg.messageType == 1) {
      //Notes have been Uploaded card
      currCard = Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.file_download),
              //TODO:Concatenated but not being displayed
              title: Text(curr_chat_msg.notesName??"" + " Uploaded"),
              subtitle: Text(
                "Subject: ${curr_chat_msg.subject??""}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                curr_chat_msg.messageBody??"",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
 
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                  timeString,
                  style: const TextStyle(color: Colors.white),
                  
                ),
              ),

          ],
        ),
      );
    } else {
      // Request for notes card
      currCard = Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text(curr_chat_msg.notesName??"" + " Requested"),
              subtitle: Text(
                "Subject: ${curr_chat_msg.subject??""}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                curr_chat_msg.messageBody??"",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
 
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                  timeString,
                  style: const TextStyle(color: Colors.white),
                  
                ),
              ),

          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      width: 200,
      alignment: currAlignment,
      child: currCard, //currAlignment,
    );
  }
}
