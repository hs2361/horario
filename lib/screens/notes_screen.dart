import 'package:flutter/material.dart';
import 'package:horario/providers/auth_service.dart';
import 'package:horario/providers/notes.dart';
import 'package:horario/screens/search_screen.dart';
import 'package:horario/screens/subjectwise_notes_screen.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isLoading = true;
  bool _noUserGroup = true;

  void openNotesFromSubject(String subject) {}

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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _noUserGroup
            ? const Center(
                child:
                    Text("You need to be part of a group to use this feature."),
              )
            : Scaffold(
                backgroundColor: Theme.of(context).primaryColor,
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.search),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            Provider.of<Notes>(context).subjectList.length,
                        itemBuilder: (context, index) {
                          final List<String> subjects =
                              Provider.of<Notes>(context).subjectList;
                          return ListTile(
                              title: Text(subjects[index]),
                              onTap: () {
                                //Setter for current subject since arguments cant be passed using getters
                                Provider.of<Notes>(context, listen: false)
                                    .currSubject = subjects[index];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NotesBySubjectScreen(subjects[index]),
                                  ),
                                );
                              });
                        },
                      ),
                    )
                  ],
                ),
              );
  }
}
