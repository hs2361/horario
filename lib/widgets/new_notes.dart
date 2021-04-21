import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import '../providers/notes.dart';

class NewNotes extends StatefulWidget {
  static const routeName = '/new-notes';
  @override
  _NewNotesState createState() => _NewNotesState();
}

class _NewNotesState extends State<NewNotes> {
  bool _isLoading = false;
  String? _fileName;
  String? _fileURL;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _notesNameController = TextEditingController();
  final TextEditingController _notesDetailsController = TextEditingController();
  final Color _color = Colors.blueAccent;

  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Upload Notes",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            color: Theme.of(context).textTheme.bodyText1?.color,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(primaryColor: _color),
                child: TextFormField(
                  autofocus: true,
                  style: const TextStyle(fontSize: 25),
                  controller: _notesNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a title";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Title: ',
                  ),
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(primaryColor: _color),
                child: TextFormField(
                  autofocus: true,
                  style: const TextStyle(fontSize: 25),
                  controller: _subjectController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a subject";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Subject: ',
                  ),
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(primaryColor: _color),
                child: TextFormField(
                  autofocus: true,
                  style: const TextStyle(fontSize: 25),
                  controller: _notesDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Details: ',
                  ),
                ),
              ),
              //TODO add widget for file upload
              Row(
                children: [
                  const Text("Select a file to upload: "),
                  ElevatedButton(
                    onPressed: () async {
                      final FilePickerResult? result =
                          await FilePicker.platform.pickFiles();

                      if (result != null) {
                        final File file = File(result.files.single.path!);

                        final int fileSize = await file.length();//REturns file sie in bytes

                        if (fileSize < 26214400) {
                          try {
                            setState(() {
                              _isLoading = true;
                            });

                            final instance =
                                firebase_storage.FirebaseStorage.instance;
                            await instance
                                .ref("uploads/${file.path.split('/').last}")
                                .putFile(file);
                            final String downloadUrl = await instance
                                .ref('uploads/${file.path.split('/').last}')
                                .getDownloadURL();
                            setState(() {
                              _fileName = file.path.split('/').last;
                              _fileURL = downloadUrl;
                              _isLoading = false;
                            });
                          } on firebase_core.FirebaseException {
                            rethrow;
                          }
                        } else {
                          _showErrorDialog(
                            context,
                            "Error",
                            "File size must be less than 25 MB.",
                          );
                        }
                      } else {
                        _showErrorDialog(
                          context,
                          "Error",
                          "A file must be selected.",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).accentColor,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text("SELECT"),
                  )
                ],
              ),
              const Expanded(child: SizedBox()),
              FloatingActionButton.extended(
                heroTag: "addrequestbtn",
                onPressed: () {
                  setState(() {
                    if (_formKey.currentState!.validate()) {
                      Provider.of<Notes>(context, listen: false).addNote(
                          subject: _subjectController.text,
                          notesName: _notesNameController.text,
                          messageType: 1,
                          messageBody: _notesDetailsController.text,
                          user: Provider.of<AuthService>(context, listen: false)
                              .userId,
                          filename: _fileName,
                          fileURL: _fileURL);

                      Navigator.of(context).pop();
                    }
                  });
                },
                label: const Text("Upload Notes"),
                icon: const Icon(Icons.add),
                foregroundColor: Colors.white,
                backgroundColor: _color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
