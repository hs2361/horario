import 'package:flutter/material.dart';
import 'package:horario/providers/auth_service.dart';
import 'package:horario/providers/note.dart';
import 'package:horario/providers/notes.dart';
import 'package:horario/widgets/new_notes.dart';
import 'package:provider/provider.dart';
import 'package:horario/widgets/group_chat_card.dart';
import 'package:horario/widgets/new_notes_request.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  void showNotesRequestForm(BuildContext context) {
    Navigator.of(context).pushNamed(NewNotesRequest.routeName);
  }

  void showUploadNotesForm(BuildContext context) {
    Navigator.of(context).pushNamed(NewNotes.routeName);
  }

  bool _isLoading = true;
  bool _noUserGroup = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await Provider.of<AuthService>(context, listen: false).checkGroupID();
      final String? groupId =
          Provider.of<AuthService>(context, listen: false).getGroupId;

      if (groupId != null && groupId.isNotEmpty) {
        _noUserGroup = false;
        await Provider.of<Notes>(context, listen: false)
            .fetchNotesFromFirestore(groupId);
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget _offsetPopup() => PopupMenuButton<int>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 0,
            child: Text(
              "Make a request for Notes",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const PopupMenuItem(
            value: 1,
            child: Text(
              "Upload Notes",
              style: TextStyle(
                color: Colors.white,
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
        onSelected: (index) {
          if (index == 0) {
            showNotesRequestForm(context);
          } else {
            showUploadNotesForm(context);
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (_noUserGroup) {
        return const Center(
          child: Text(
              "You need to be part of a group to use this feature."),
        );
      } else {
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
  }
}
