import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
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
  bool _isLoading = false;

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
              TextFormField(
                textInputAction: TextInputAction.next,
                autofocus: true,
                controller: _notesNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter the name of your request";
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Request for: ',
                ),
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                autofocus: true,
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
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textInputAction: TextInputAction.done,
                autofocus: true,
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
              const Expanded(child: SizedBox()),
              FloatingActionButton.extended(
                heroTag: "addRequestBtn",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });
                    final String userId =
                        Provider.of<AuthService>(context, listen: false)
                            .userId!;
                    await Provider.of<Notes>(context, listen: false).addNote(
                      subject: _subjectController.text,
                      notesName: _notesNameController.text,
                      messageType: 0,
                      messageBody: _notesDetailsController.text,
                      user: userId,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pop();
                  }
                },
                label: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      )
                    : const Text("Send Request"),
                icon: const Icon(Icons.send),
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
