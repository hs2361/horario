import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/class.dart';
import '../providers/classes.dart';
import '../widgets/class_card.dart';
import '../widgets/new_assignment.dart';
import '../widgets/new_class.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime today = DateTime.now();
  int selectedDay = DateTime.now().weekday;
  bool _isLoading = true;

  ClipRRect weekdayButton(BuildContext context, DateTime day) => ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          width: 50,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context)
                    .accentColor
                    .withAlpha(selectedDay == day.weekday ? 255 : 60)),
            onPressed: () {
              setState(() {
                selectedDay = day.weekday;
              });
            },
            child: Text(
              DateFormat('E').format(day)[0],
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      );

  void showNewClassForm(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(NewClass.routeName);
  }

  void showNewAssignmentForm(BuildContext context) {
    Navigator.of(context).pushNamed(NewAssignment.routeName);
  }

  Widget _showFABPopupMenu() => PopupMenuButton<int>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 0,
            child: Text(
              "Add Class",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const PopupMenuItem(
            value: 1,
            child: Text(
              "Add Assignment",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
        icon: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: ShapeDecoration(
            color: Theme.of(context).cardColor,
            shape: const CircleBorder(),
          ),
          child: Icon(
            Icons.add,
            color: Theme.of(context).accentColor,
          ),
        ),
        offset: const Offset(0, -140),
        onSelected: (index) {
          if (index == 0) {
            showNewClassForm(context);
          } else {
            showNewAssignmentForm(context);
          }
        },
      );
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await Provider.of<Classes>(context, listen: false).fetchFromFirestore();
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            floatingActionButton: SizedBox(
              height: 75.0,
              width: 75.0,
              child: _showFABPopupMenu(),
            ),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int day = 1; day <= 7; day++)
                      weekdayButton(
                        context,
                        today.subtract(Duration(days: today.weekday - day)),
                      ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Provider.of<Classes>(context)
                        .schedule[selectedDay - 1]
                        .length,
                    itemBuilder: (context, index) {
                      final List<Class> classes = Provider.of<Classes>(context)
                          .schedule[selectedDay - 1];
                      return ClassCard(classes[index]);
                    },
                  ),
                )
              ],
            ),
          );
  }
}
