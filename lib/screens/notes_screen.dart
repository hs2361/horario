import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import '../providers/note.dart';
import '../providers/notes.dart';
import 'notes_by_subject_screen.dart';

class NotesScreen extends StatefulWidget {
  final List<Color> colors = [
    Colors.pink,
    Colors.redAccent,
    Colors.orange,
    Colors.green,
    Colors.lightBlueAccent,
    Colors.blueAccent,
    Colors.purple,
  ];
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
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
                    showSearch(context: context, delegate: DataSearch());
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
                          return Card(
                            margin: const EdgeInsets.fromLTRB(5, 15, 5, 0),
                            color: widget.colors[(subjects[index].length %
                                widget.colors.length)],
                            child: InkWell(
                              onTap: () {
                                //Setter for current subject since arguments cant be passed using getters
                                Navigator.of(context).pushNamed(
                                  NotesBySubjectScreen.routeName,
                                  arguments: subjects[index],
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        NotesBySubjectScreen.routeName,
                                        arguments: subjects[index],
                                      );
                                    },
                                  ),
                                  title: Text(
                                    subjects[index],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
  }
}

class DataSearch extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      primaryColor: Theme.of(context).primaryColor,
      scaffoldBackgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Note> allNotes = Provider.of<Notes>(context)
        .allNotes
        .where((n) =>
            (n.notesName?.toLowerCase().startsWith(query.toLowerCase()) ??
                false) ||
            (n.subject?.toLowerCase().startsWith(query.toLowerCase()) ??
                false) ||
            (n.filename?.toLowerCase().startsWith(query.toLowerCase()) ??
                false))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(allNotes[index].notesName!),
        subtitle: Text(
          "Subject: ${allNotes[index].subject!}",
        ),
      ),
      itemCount: allNotes.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Note> allNotes = Provider.of<Notes>(context)
        .allNotes
        .where((n) =>
            (n.notesName?.toLowerCase().startsWith(query.toLowerCase()) ??
                false) ||
            (n.subject?.toLowerCase().startsWith(query.toLowerCase()) ??
                false) ||
            (n.filename?.toLowerCase().startsWith(query.toLowerCase()) ??
                false))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(allNotes[index].notesName ?? ""),
        subtitle: Text(
          "Subject: ${allNotes[index].subject ?? ""}",
        ),
      ),
      itemCount: allNotes.length,
    );
  }
}
