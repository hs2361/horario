import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';

import '../models/time_slot.dart';
import '../providers/classes.dart';
import '../screens/home_screen.dart';

class NewClass extends StatefulWidget {
  static const routeName = '/new-class';
  final Map<String, dynamic>? data;
  const NewClass(this.data);
  @override
  _NewClassState createState() => _NewClassState();
}

class _NewClassState extends State<NewClass> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _linkController = TextEditingController();
  List<TimeSlot> _schedule = [];
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
      _linkController =
          TextEditingController(text: (data['link'] ?? "") as String);
      _color = data['color'] as Color;
      _schedule = data['schedule'] as List<TimeSlot>;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
    _linkController.dispose();
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

  void showSchedulePicker(int index) {
    showTimeRangePicker(
      context: context,
      start: _schedule[index].start,
      end: _schedule[index].end,
      onStartChange: (start) {
        setState(() {
          if (_schedule[index].end.hour + _schedule[index].end.minute / 60 <=
              start.hour + start.minute / 60) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Error"),
                content:
                    const Text("End time cannot be earlier than start time"),
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
          } else {
            _schedule[index].start = start;
          }
        });
      },
      onEndChange: (end) {
        setState(() {
          if (end.hour + end.minute / 60 <=
              _schedule[index].start.hour +
                  _schedule[index].start.minute / 60) {
            _showErrorDialog(
              context,
              "Error",
              "End time cannot be earlier than start time",
            );
          } else {
            _schedule[index].end = end;
          }
        });
      },
      padding: 30,
      strokeWidth: 20,
      handlerRadius: 14,
      strokeColor: _color.withAlpha(100),
      interval: const Duration(minutes: 30),
      handlerColor: _color,
      backgroundColor: Theme.of(context).backgroundColor,
      snap: true,
      timeTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.normal,
      ),
      activeTimeTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 26,
      ),
    );
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
            "Add Class",
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
                  data: Theme.of(context).copyWith(accentColor: _color),
                  child: TextFormField(
                    autofocus: true,
                    style: const TextStyle(fontSize: 20),
                    textInputAction: TextInputAction.next,
                    controller: _subjectController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter a subject";
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                    ),
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(accentColor: _color),
                  child: TextFormField(
                    keyboardType: TextInputType.url,
                    style: const TextStyle(fontSize: 20),
                    textInputAction: TextInputAction.done,
                    controller: _linkController,
                    decoration: const InputDecoration(
                      labelText: 'Link',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!Uri.parse(value).isAbsolute) {
                          return "Enter a valid URL";
                        }
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pick a colour for the class",
                      style: TextStyle(fontSize: 20, color: Colors.white),
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
                Container(
                  margin: const EdgeInsets.all(20.0),
                  child: const Center(
                    child: Text(
                      "SCHEDULE",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      const List<String> days = [
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday',
                        'Sunday'
                      ];

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            items: days
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              );
                            }).toList(),
                            value: days[_schedule[index].weekday - 1],
                            icon: Icon(
                              Icons.arrow_downward,
                              color: _color,
                            ),
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: _color,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  _schedule[index].weekday =
                                      days.indexOf(newValue) + 1;
                                }
                              });
                            },
                          ),
                          ElevatedButton(
                            onPressed: () => showSchedulePicker(index),
                            style: ElevatedButton.styleFrom(
                              primary: _color,
                            ),
                            child: Text(
                              "${_schedule[index].start.hour.toString().padLeft(2, '0')}:${_schedule[index].start.minute.toString().padLeft(2, '0')}" +
                                  " - ${_schedule[index].end.hour.toString().padLeft(2, '0')}:${_schedule[index].end.minute.toString().padLeft(2, '0')}",
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _schedule.removeAt(index);
                              });
                            },
                          )
                        ],
                      );
                    },
                    itemCount: _schedule.length,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                FloatingActionButton.extended(
                  heroTag: "addBtn",
                  onPressed: () {
                    setState(() {
                      _schedule.add(
                        TimeSlot(
                          weekday: 1,
                          start: const TimeOfDay(hour: 0, minute: 0),
                          end: const TimeOfDay(hour: 0, minute: 0),
                        ),
                      );
                    });
                  },
                  label: const Text("Add Schedule"),
                  icon: const Icon(Icons.add),
                  foregroundColor: Colors.white,
                  backgroundColor: _color,
                ),
                const SizedBox(
                  height: 10,
                ),
                FloatingActionButton.extended(
                  heroTag: "createBtn",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_schedule.isEmpty) {
                        _showErrorDialog(
                          context,
                          "Error",
                          "Schedule cannot be empty",
                        );
                      } else {
                        if (widget.data == null) {
                          setState(() {
                            _isLoading = true;
                          });
                          await Provider.of<Classes>(context, listen: false)
                              .addClass(
                            subject: _subjectController.text,
                            schedule: _schedule,
                            color: _color,
                            link: _linkController.text.isEmpty
                                ? null
                                : _linkController.text,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context)
                              .pushReplacementNamed(HomeScreen.routeName);
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          await Provider.of<Classes>(context, listen: false)
                              .updateClass(
                            id: widget.data?['id'] as String,
                            subject: _subjectController.text,
                            schedule: _schedule,
                            color: _color,
                            link: _linkController.text.isEmpty
                                ? null
                                : _linkController.text,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context)
                              .pushReplacementNamed(HomeScreen.routeName);
                        }
                      }
                    }
                  },
                  label: !_isLoading
                      ? Text(
                          widget.data == null ? "Create Class" : "Update Class",
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
