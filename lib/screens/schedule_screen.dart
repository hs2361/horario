import 'package:flutter/material.dart';
import 'package:horario/providers/class.dart';
import 'package:horario/providers/classes.dart';
import 'package:horario/widgets/class_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime today = DateTime.now();
  int selectedDay = DateTime.now().weekday;

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
    // Arguments => context: The context for the modal sheet to be created in
    //
    // Opens up the NewTask modal sheet to add a new task

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: Container(),
        );
      },
    );
  }

  Widget _offsetPopup() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: InkWell(
              onTap: () => showNewClassForm(context),
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
                final List<Class> classes =
                    Provider.of<Classes>(context).schedule[selectedDay - 1];
                return ClassCard(classes[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}
