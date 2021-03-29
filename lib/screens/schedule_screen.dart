import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime today = DateTime.now();
  int selectedDay = DateTime.now().weekday;

  // ignore: avoid_positional_boolean_parameters
  ClipRRect weekdayButton(BuildContext context, DateTime day, bool selected) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          width: 50,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context)
                    .accentColor
                    .withAlpha(selected ? 255 : 60)),
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

  Widget _offsetPopup() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: InkWell(
              onTap: () {},
              child: const Text(
                "Add Class",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: InkWell(
              onTap: () {},
              child: const Text(
                "Add Assignment",
                style: TextStyle(
                  color: Colors.white,
                ),
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
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      floatingActionButton: SizedBox(
        height: 75.0,
        width: 75.0,
        child: _offsetPopup(),
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
                  selectedDay == day,
                )
            ],
          )
        ],
      ),
    );
  }
}
