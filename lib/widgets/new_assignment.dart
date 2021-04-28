import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/classes.dart';
import '../screens/home_screen.dart';

class NewAssignment extends StatefulWidget {
  static const routeName = '/new-assignment';
  final Map<String, dynamic>? data;
  const NewAssignment(this.data);
  @override
  _NewAssignmentState createState() => _NewAssignmentState();
}

class _NewAssignmentState extends State<NewAssignment> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _subjectController = TextEditingController();
  DateTime? _deadline = DateTime.now();
  Color _color = Colors.blueAccent;
  String? dropdownValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      final Map<String, dynamic> data = widget.data ?? {};
      _subjectController =
          TextEditingController(text: data['subject'] as String);
      _color = data['color'] as Color;
      _deadline = data['deadline'] as DateTime;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
  }

  void showColorPicker() {
    final List<Color> _colors = [
      Colors.pink,
      Colors.green,
      Colors.orange,
      Colors.blueAccent,
      Colors.purple,
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: SizedBox(
          height: 150,
          child: BlockPicker(
            pickerColor: _color,
            availableColors: _colors,
            onColorChanged: (selectedColor) {
              setState(() {
                _color = selectedColor;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> pickDeadline() async {
    final DateTime? date = await showDatePicker(
      confirmText: 'SELECT TIME',
      context: context,
      initialDate:
          widget.data != null ? _deadline ?? DateTime.now() : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            onPrimary: Colors.white,
            primary: _color,
          ),
          accentColor: _color,
          dialogBackgroundColor: Theme.of(ctx).primaryColor,
        ),
        child: child ?? const CircularProgressIndicator(),
      ),
    );
    final TimeOfDay? time = await showTimePicker(
      confirmText: 'DONE',
      context: context,
      initialTime: widget.data != null
          ? TimeOfDay(hour: _deadline!.hour, minute: _deadline!.minute)
          : TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            onPrimary: Colors.white,
            primary: _color,
          ),
          accentColor: _color,
          dialogBackgroundColor: Theme.of(ctx).primaryColor,
        ),
        child: child ?? const CircularProgressIndicator(),
      ),
    );
    setState(() {
      if (time != null && date != null) {
        _deadline =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
      }
    });
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            "Add Assignment",
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(accentColor: _color),
                      child: TextFormField(
                        autofocus: true,
                        style: const TextStyle(fontSize: 20),
                        controller: _subjectController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter a title";
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pick a colour for the Assignment",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: _color,
                          ),
                          onPressed: showColorPicker,
                          child: const Text(
                            'PICK',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pick a Deadline",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: _color,
                          ),
                          onPressed: pickDeadline,
                          child: Text(
                            DateFormat('MMM dd, HH:mm')
                                .format(_deadline ?? DateTime.now()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                FloatingActionButton.extended(
                  heroTag: "createBtn",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_deadline == null) {
                        _showErrorDialog(
                          context,
                          "Error",
                          "Deadline cannot be empty",
                        );
                      } else {
                        if (widget.data == null) {
                          setState(() {
                            _isLoading = true;
                          });
                          await Provider.of<Classes>(context, listen: false)
                              .addClass(
                            subject: _subjectController.text,
                            deadline: _deadline,
                            color: _color,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          await Provider.of<Classes>(context, listen: false)
                              .updateClass(
                            id: widget.data?['id'] as String,
                            subject: _subjectController.text,
                            deadline: _deadline,
                            color: _color,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  label: !_isLoading
                      ? Text(
                          widget.data == null
                              ? "Create Assignment"
                              : "Update Assignment",
                        )
                      : const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                  icon: const Icon(Icons.check),
                  foregroundColor: Colors.white,
                  backgroundColor: _color,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
