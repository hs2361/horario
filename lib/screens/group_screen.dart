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
  Widget build(BuildContext context) {
    String timeString;
    timeString =
        DateFormat('HH:MM').format(curr_chat_msg.sentTime ?? DateTime.now());
    Card currCard = Card();

    //Get userID from firebase here
    String? currUser = "2zZWzj2gOuOz2XrJIifcoTMqt3C3";

    return Container(
      width: 300,
      padding: EdgeInsets.only(left: 14,right: 14,top: 5,bottom: 5),
      child: Align(
        alignment: (curr_chat_msg.user == currUser?Alignment.topLeft:Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (curr_chat_msg.user == currUser?Colors.blue[200]:Colors.grey.shade200),
          ),
          padding: EdgeInsets.all(8),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (curr_chat_msg.messageType==1)?"Request made for " + (curr_chat_msg.notesName??""):"Notes for "+(curr_chat_msg.notesName??"")+" Uploaded", 
                style: TextStyle(fontSize: 15,color: Colors.black),
              
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
                  Text(curr_chat_msg.messageBody??"", style: TextStyle(fontSize: 15,color: Colors.black),),
                  Text(timeString, style: TextStyle(fontSize: 15,color: Colors.black),),
              //   ],
              // ),

            ],
          ),
        ),
      ),
    );
  }
}
