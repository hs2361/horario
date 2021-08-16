import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/auth_service.dart';
import '../providers/notes.dart';
import 'new_notes.dart';

class GroupChatCard extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final Note curr_chat_msg;

  const GroupChatCard(this.curr_chat_msg);

  @override
  _GroupChatCardState createState() => _GroupChatCardState();
}

class _GroupChatCardState extends State<GroupChatCard> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  Offset _tapPosition = Offset.zero;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    final String timeString = DateFormat('MMM dd, HH:mm')
        .format(widget.curr_chat_msg.sentTime ?? DateTime.now());

    final String currUser =
        Provider.of<AuthService>(context, listen: false).userId!;

    void _showUpdateForm() {
      Navigator.of(context).pushNamed(NewNotes.routeName, arguments: {
        'id': widget.curr_chat_msg.id,
        'subject': widget.curr_chat_msg.subject,
        'filename': widget.curr_chat_msg.filename,
        'fileUrl': widget.curr_chat_msg.fileUrl,
        'notesDetails': widget.curr_chat_msg.messageBody,
        'notesName': widget.curr_chat_msg.notesName,
      });
    }

    return Row(
      children: [
        if (widget.curr_chat_msg.user == currUser)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
          ),
        Expanded(
          child: GestureDetector(
            onTapDown: _storePosition,
            onLongPress: widget.curr_chat_msg.user == currUser
                ? () {
                    showMenu(
                      position: RelativeRect.fromRect(
                        _tapPosition & const Size(40, 40),
                        Offset.zero & MediaQuery.of(context).size,
                      ),
                      items: <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const <Widget>[
                              Icon(Icons.edit),
                              Text("Edit"),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const <Widget>[
                              Icon(Icons.delete),
                              Text("Delete"),
                            ],
                          ),
                        )
                      ],
                      context: context,
                    ).then((choice) async {
                      if (choice == 0) {
                        _showUpdateForm();
                      } else if (choice == 1) {
                        await Provider.of<Notes>(context, listen: false)
                            .deleteNote(widget.curr_chat_msg.id);
                      }
                    });
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.curr_chat_msg.user == currUser
                      ? Theme.of(context).accentColor
                      : const Color(0xff363636),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      //TYPE 0 is request type 1 is Upload
                      (widget.curr_chat_msg.isRequest == 0)
                          ? "Request for ${widget.curr_chat_msg.notesName ?? ""} notes"
                          : widget.curr_chat_msg.notesName ?? "",
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.curr_chat_msg.user == currUser
                            ? Colors.black
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.curr_chat_msg.subject ?? "",
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.curr_chat_msg.user == currUser
                            ? Colors.black
                            : Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(
                        widget.curr_chat_msg.messageBody ?? "",
                        style: TextStyle(
                          fontSize: 15,
                          color: widget.curr_chat_msg.user == currUser
                              ? Colors.black
                              : Colors.white70,
                        ),
                      ),
                    ),
                    if (widget.curr_chat_msg.isRequest == 1)
                      InkWell(
                        onTap: () async {
                          final String? currLink = widget.curr_chat_msg.fileUrl;
                          final String? currFileName =
                              widget.curr_chat_msg.filename;
                          final Directory tempDir =
                              await getTemporaryDirectory();
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
                            OpenFile.open(fullPath);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(50),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.attach_file,
                                color: Colors.white70,
                              ),
                              if (!_isDownloading || _downloadProgress == 1)
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      widget.curr_chat_msg.filename ?? "",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.black.withAlpha(50),
                                    value: _downloadProgress,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.curr_chat_msg.user == currUser
                            ? Colors.black87
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.curr_chat_msg.user != currUser)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
          ),
      ],
    );
  }
}
