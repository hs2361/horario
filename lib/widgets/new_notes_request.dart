import 'package:flutter/material.dart';
import 'package:horario/providers/auth_service.dart';
import 'package:provider/provider.dart';

import '../providers/notes.dart';

class NewNotesRequest extends StatefulWidget {
  static const routeName = '/new-notes-request';
  @override
  _NewNotesRequestState createState() => _NewNotesRequestState();
}

class _NewNotesRequestState extends State<NewNotesRequest> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _notesNameController = TextEditingController();
  final TextEditingController _notesDetailsController = TextEditingController();
  final Color _color = Colors.blueAccent;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Make a request for Notes",
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
                      return "Enter the name of requested notes";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Request for: ',
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
                      return "Enter a title";
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter details: ";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Details: ',
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              FloatingActionButton.extended(
                heroTag: "addrequestbtn",
                onPressed: () {
                  setState(() {
                    if (_formKey.currentState!.validate()) {
                      final String userId = Provider.of<AuthService>(context, listen: false)
                                    .userId!;
                      Provider.of<Notes>(context, listen: false).addNote(
                        subject: _subjectController.text,
                        notesName: _notesNameController.text,
                        messageType: 0,
                        messageBody: _notesDetailsController.text,
                        user: userId,
                      );
                      Navigator.of(context).pop();
                    }
                  });
                },
                label: const Text("Make the Request"),
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
