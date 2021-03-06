import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import '../providers/notes.dart';

class NewNotes extends StatefulWidget {
  static const routeName = '/new-notes';
  final Map<String, dynamic>? data;
  const NewNotes(this.data);
  @override
  _NewNotesState createState() => _NewNotesState();
}

class _NewNotesState extends State<NewNotes> {
  bool _isLoading = false;
  bool _isAdding = false;
  double _uploadProgress = 0;
  String? _fileName;
  String? _fileURL;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _notesNameController = TextEditingController();
  TextEditingController _notesDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      final Map<String, dynamic> data = widget.data ?? {};
      _subjectController =
          TextEditingController(text: data['subject'] as String);
      _notesNameController =
          TextEditingController(text: data['notesName'] as String);
      _notesDetailsController =
          TextEditingController(text: data['notesDetails'] as String);
      _fileName = data['filename'] as String;
      _fileURL = data['fileUrl'] as String;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
    _notesNameController.dispose();
    _notesDetailsController.dispose();
  }

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
    final uploadPath = "uploads/${Provider.of<AuthService>(context).userId}";
    final storage = firebase_storage.FirebaseStorage.instance;
    return WillPopScope(
      onWillPop: () async {
        if (_fileURL != null) {
          await storage.ref("$uploadPath/$_fileName").delete();
        }
        return true;
      },
      child: Scaffold(
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
                TextFormField(
                  textInputAction: TextInputAction.next,
                  autofocus: true,
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
                TextFormField(
                  textInputAction: TextInputAction.next,
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
                TextFormField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  controller: _notesDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Details: ',
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      if (_fileURL != null) {
                        await storage.ref("$uploadPath/$_fileName").delete();
                      }
                      final FilePickerResult? result =
                          await FilePicker.platform.pickFiles();

                      if (result != null) {
                        final File file = File(result.files.single.path!);
                        final int fileSize =
                            await file.length(); //Returns file size in bytes

                        if (fileSize < 26214400) {
                          try {
                            setState(() {
                              _isLoading = true;
                            });
                            final firebase_storage.UploadTask uploadTask = storage
                                .ref("$uploadPath/${file.path.split('/').last}")
                                .putFile(file);

                            uploadTask.snapshotEvents.listen((snapshot) async {
                              setState(() {
                                _uploadProgress =
                                    snapshot.bytesTransferred.toDouble() /
                                        snapshot.totalBytes.toDouble();
                              });
                              if (_uploadProgress == 1) {
                                final String downloadUrl = await storage
                                    .ref(
                                        '$uploadPath/${file.path.split('/').last}')
                                    .getDownloadURL();
                                setState(() {
                                  _fileName = file.path.split('/').last;
                                  _fileURL = downloadUrl;
                                  _isLoading = false;
                                });
                              }
                            });
                          } on firebase_storage.FirebaseException {
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
                        setState(() {
                          _isLoading = false;
                          _fileName = null;
                          _fileURL = null;
                        });
                        _showErrorDialog(
                          context,
                          "Error",
                          "A file must be selected.",
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      minimumSize: const Size(200, 50),
                    ),
                    label: _isLoading
                        ? SizedBox(
                            width: 100,
                            child: LinearProgressIndicator(
                              value: _uploadProgress,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _fileName ?? "SELECT FILE",
                            style: const TextStyle(fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                    icon: const Icon(
                      Icons.attach_file,
                      size: 30,
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                FloatingActionButton.extended(
                  heroTag: "addNotesBtn",
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_fileURL != null) {
                              setState(() {
                                _isAdding = true;
                              });
                              if (widget.data == null) {
                                await Provider.of<Notes>(context, listen: false)
                                    .addNote(
                                  subject: _subjectController.text,
                                  notesName: _notesNameController.text,
                                  messageBody: _notesDetailsController.text,
                                  user: Provider.of<AuthService>(context,
                                          listen: false)
                                      .userId,
                                  filename: _fileName,
                                  fileURL: _fileURL,
                                );
                                setState(() {
                                  _isAdding = false;
                                });
                                Navigator.of(context).pop();
                              } else {
                                await Provider.of<Notes>(context, listen: false)
                                    .updateNote(
                                  id: widget.data?['id'] as String,
                                  subject: _subjectController.text,
                                  notesName: _notesNameController.text,
                                  messageBody: _notesDetailsController.text,
                                  user: Provider.of<AuthService>(context,
                                          listen: false)
                                      .userId,
                                  filename: _fileName,
                                  fileUrl: _fileURL,
                                );
                                setState(() {
                                  _isAdding = false;
                                });
                                Navigator.of(context).pop();
                              }
                            } else {
                              _showErrorDialog(
                                context,
                                "Error",
                                "A file must be selected.",
                              );
                            }
                          }
                        },
                  label: _isAdding
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Text(
                          widget.data == null ? "Send Notes" : "Update Notes",
                        ),
                  icon: const Icon(Icons.send),
                  foregroundColor: Colors.white,
                  backgroundColor: _isLoading
                      ? Theme.of(context).disabledColor
                      : Theme.of(context).accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
