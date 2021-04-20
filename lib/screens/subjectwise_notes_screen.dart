import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:horario/providers/note.dart';
import 'package:horario/providers/notes.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
                onTap: () async {
                  final String? currLink = subjectNotes[index].fileUrl;
                  final String? currFileName = subjectNotes[index].filename;
                  final Directory tempDir = await getTemporaryDirectory();
                  final String tempPath = tempDir.path;
                  final String fullPath = "$tempPath/$currFileName";
                  final status = await Permission.storage.request();
                  if (status.isGranted) {
                    final Dio dio = Dio();
                    await dio.download(currLink!, fullPath);
                    //TODO: Show download progress here.
                    OpenFile.open(fullPath);
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
}
