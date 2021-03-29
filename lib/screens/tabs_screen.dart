import 'package:flutter/material.dart';

import '../widgets/main_drawer.dart';
import './schedule_screen.dart';
import './notes_screen.dart';
import './group_screen.dart';

// Screen that displays all the tabs
class TabsScreen extends StatefulWidget {
  // Arguments => selected: The index of the selected tab to be highlighted
  static const routeName = '/tabs-screen';
  final int selected;
  TabsScreen(this.selected);
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<dynamic> _pages;
  late int _selectedIndex;
  bool _isInit = true;

  late List<dynamic> _tabColors;

  void setSelectedColor(BuildContext context) {
    // function that sets the tab of index 'selected' as the accent colour
    _tabColors[_selectedIndex] = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).accentColor
        : Colors.white;
    for (int i = 0; i < 3; i++) {
      if (i != _selectedIndex) {
        _tabColors[i] = Colors.white60;
      }
    }
  }

  Widget navBtn(
    int selfIndex,
    IconData icon,
    String title,
    void Function() callback,
  ) {
    // Arguments => selfIndex: Index of the currently selected tab
    //              icon: The icon to be used for the tab
    //              title: The title for the tab
    //              callback: The function to be executed on tapping on the tab
    //
    // Creates a tab to be displayed in the bottom navigation bar

    return GestureDetector(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          color: Colors.transparent,
          height: 50,
          width: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(
                icon,
                color: _tabColors[selfIndex],
                size: selfIndex == _selectedIndex ? 28 : 24,
              ),
              Text(
                title,
                style: TextStyle(
                  color: _tabColors[selfIndex],
                  fontWeight: selfIndex == _selectedIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _selectedIndex = widget.selected;

    _pages = [
      ScheduleScreen(),
      GroupScreen(),
      NotesScreen(),
    ];

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _tabColors = [];
      for (int i = 0; i < 3; i++) {
        if (i == _selectedIndex) {
          _tabColors.add(Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).accentColor
              : Colors.white);
        } else {
          _tabColors.add(Colors.white60);
        }
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: RichText(
          text: new TextSpan(children: <TextSpan>[
            new TextSpan(
              text: 'HORA',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: Theme.of(context).textTheme.bodyText1?.color,
              ),
            ),
            new TextSpan(
              text: 'RIO',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor,
              ),
            ),
          ]),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              spreadRadius: 30,
              color: Colors.black26,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0), topRight: Radius.circular(0)),
          child: BottomAppBar(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Theme.of(context).accentColor,
            notchMargin: -22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                navBtn(0, Icons.class_, 'Schedule', () {
                  setState(() {
                    _selectedIndex = 0;
                    setSelectedColor(context);
                  });
                }),
                navBtn(1, Icons.assignment, 'Group', () {
                  setState(() {
                    _selectedIndex = 1;
                    setSelectedColor(context);
                  });
                }),
                navBtn(2, Icons.group, 'Notes', () {
                  setState(() {
                    _selectedIndex = 2;
                    setSelectedColor(context);
                  });
                }),
                SizedBox(
                  width: 75,
                ),
              ],
            ),
            shape: CircularNotchedRectangle(),
          ),
        ),
      ),
      // Plus button
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: FloatingActionButton(
            child: Icon(
              Icons.add,
              size: 35,
            ),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Theme.of(context).accentColor,
            foregroundColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).accentColor
                : Theme.of(context).cardColor,
            onPressed: () => {}),
      ),
    );
  }
}
