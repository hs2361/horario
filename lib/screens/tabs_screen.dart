import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import './group_screen.dart';
import './notes_screen.dart';
import './profile_screen.dart';
import './schedule_screen.dart';

// Screen that displays all the tabs
class TabsScreen extends StatefulWidget {
  // Arguments => selected: The index of the selected tab to be highlighted
  static const routeName = '/tabs-screen';
  final int selected;
  const TabsScreen(this.selected);
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<Widget> _pages;
  late int _selectedIndex;
  bool _isInit = true;

  late List<Color> _tabColors;

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
    final String photoUrl =
        Provider.of<AuthService>(context, listen: true).photoUrl ?? '';
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProfileScreen.routeName);
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundImage: (photoUrl == ''
                  ? const AssetImage(
                      'assets/images/default_pfp.png',
                    )
                  : NetworkImage(photoUrl)) as ImageProvider,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: RichText(
          text: TextSpan(children: <TextSpan>[
            TextSpan(
              text: 'HORA',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: Theme.of(context).textTheme.bodyText1?.color,
              ),
            ),
            TextSpan(
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
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              spreadRadius: 30,
              color: Colors.black26,
            )
          ],
        ),
        child: ClipRRect(
          child: BottomAppBar(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Theme.of(context).accentColor,
            notchMargin: -22,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                navBtn(0, Icons.schedule, 'Schedule', () {
                  setState(() {
                    _selectedIndex = 0;
                    setSelectedColor(context);
                  });
                }),
                navBtn(1, Icons.group, 'Group', () {
                  setState(() {
                    _selectedIndex = 1;
                    setSelectedColor(context);
                  });
                }),
                navBtn(2, Icons.note_rounded, 'Notes', () {
                  setState(() {
                    _selectedIndex = 2;
                    setSelectedColor(context);
                  });
                }),
              ],
            ),
          ),
        ),
      ),
      // Plus button
    );
  }
}
