import 'package:flutter/material.dart';
import 'package:horario/providers/note.dart';
import 'package:horario/providers/notes.dart';
import 'package:provider/provider.dart';

class NotesBySubjectScreen extends StatefulWidget {
  final String subject;
  const NotesBySubjectScreen(this.subject);

  @override
  _NotesBySubjectScreenState createState() => _NotesBySubjectScreenState();
}

class _NotesBySubjectScreenState extends State<NotesBySubjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: Provider.of<Notes>(context).subjectwiseNotes.length,
            itemBuilder: (context, index) {
              final List<Note> subjectNotes =
                  Provider.of<Notes>(context).subjectwiseNotes;

              // TODO: Make this a card in two listbuilder columns and add the on tap thingy
              return ListTile(
                title: Text(subjectNotes[index].notesName!),
              );
            },
          )
        ],
      ),
    );
  }
}
