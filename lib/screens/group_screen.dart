import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:horario/providers/group_chat_class.dart';
import 'package:horario/providers/group_chat_provider.dart';
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Provider.of<GroupChatCollection>(context).chat.length,
              itemBuilder: (context, index) {
                final List<GroupChatClass> chat =
                    Provider.of<GroupChatCollection>(context).chat;
                return GroupChatCard(chat[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}

class GroupChatCard extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final GroupChatClass curr_chat_msg;
  const GroupChatCard(this.curr_chat_msg);

  @override
  @override
  Widget build(BuildContext context) {
    String timeString;
    timeString = DateFormat('HH:MM').format(curr_chat_msg.sentTime ?? DateTime.now());
    return Container(
      padding: const EdgeInsets.all(8),
      height: 100,
      child: Card(
        color: curr_chat_msg.color,
        child: ListTile(
          title: Text(curr_chat_msg.notesName ?? ""),
          subtitle: Text(timeString),
        ),
      ),
    );
  }
}
