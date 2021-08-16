import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import '../providers/notes.dart';

class NotesBySubjectScreen extends StatefulWidget {
  static const routeName = '/notes-by-subject';
  final String subject;
  const NotesBySubjectScreen(this.subject);

  @override
  _NotesBySubjectScreenState createState() => _NotesBySubjectScreenState();
}

class _NotesBySubjectScreenState extends State<NotesBySubjectScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  IconData iconFromFileName(String filename) {
    switch (filename.split('.').last) {
      case 'mp4':
        return Icons.movie_rounded;
      case 'wav':
      case 'mp3':
        return Icons.music_note;
      case 'pdf':
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectNotes = Provider.of<Notes>(context, listen: false)
        .subjectwiseNotes(widget.subject);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.subject,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            color: Theme.of(context).textTheme.bodyText1?.color,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: subjectNotes.length,
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.white60,
                );
              },
              itemBuilder: (context, index) {
                final uploadPath =
                    "uploads/${Provider.of<AuthService>(context).userId}";

                // TODO: Make this a card in two listbuilder columns and add the on tap thingy
                return ListTile(
                  title: Text(subjectNotes[index].notesName!),
                  leading: Icon(
                    iconFromFileName(subjectNotes[index].filename ?? ""),
                    size: 40,
                  ),
                  subtitle: FutureBuilder(
                    future: storage
                        .ref("$uploadPath/${subjectNotes[index].filename}")
                        .getMetadata(),
                    builder: (ctx, AsyncSnapshot<FullMetadata> snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                            '${((snapshot.data?.size ?? 0) / 1000000).toStringAsPrecision(2)} MB');
                      } else {
                        return const Text("Loading...");
                      }
                    },
                  ),
                  trailing: (!_isDownloading || _downloadProgress == 1)
                      ? null
                      : CircularProgressIndicator(
                          value: _downloadProgress,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                  onTap: () async {
                    final String? currLink = subjectNotes[index].fileUrl;
                    final String? currFileName = subjectNotes[index].filename;
                    final Directory tempDir = await getTemporaryDirectory();
                    final String tempPath = tempDir.path;
                    final String fullPath = "$tempPath/$currFileName";
                    final permission = await Permission.storage.request();
                    if (permission.isGranted) {
                      setState(() {
                        _isDownloading = true;
                        _downloadProgress = 0;
                      });
                      final Dio dio = Dio();
                      await dio.download(
                        currLink!,
                        fullPath,
                        onReceiveProgress: (received, total) {
                          if (total != -1) {
                            setState(() {
                              _downloadProgress = received / total;
                              if (_downloadProgress == 1) {
                                _isDownloading = false;
                                _downloadProgress = 0;
                              }
                            });
                          }
                        },
                      );
                      //TODO: Show download progress here.
                      OpenFile.open(fullPath);
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
