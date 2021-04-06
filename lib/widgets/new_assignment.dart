import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:horario/providers/classes.dart';
import 'package:provider/provider.dart';

class NewAssignment extends StatefulWidget {
  static const routeName = '/new-assignment';
  @override
  _NewAssignmentState createState() => _NewAssignmentState();
}

class _NewAssignmentState extends State<NewAssignment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  DateTime? _deadline = DateTime.now();
  Color _color = Colors.blueAccent;
  String? dropdownValue;

  void showColorPicker() {
    final List<Color> _colors = [
      Colors.pink,
      Colors.green,
      Colors.greenAccent,
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
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2121),
    );
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
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
                        child: const Text(
                          'PICK',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              FloatingActionButton.extended(
                heroTag: "createBtn",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_deadline == null) {
                      _showErrorDialog(
                        context,
                        "Error",
                        "Deadline cannot be empty",
                      );
                    } else {
                      Provider.of<Classes>(context, listen: false).addClass(
                        subject: _subjectController.text,
                        deadline: _deadline,
                        color: _color,
                      );
                      Navigator.of(context).pop();
                    }
                  }
                },
                label: const Text("Create Assignment"),
                icon: const Icon(Icons.check),
                foregroundColor: Colors.white,
                backgroundColor: _color,
              )
            ],
          ),
        ),
      ),
    );
  }
}
