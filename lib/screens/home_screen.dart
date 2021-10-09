import 'package:flutter/material.dart';
import 'package:horario/providers/user_service.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import '../providers/notification_service.dart';
import '../widgets/new_assignment.dart';
import '../widgets/new_class.dart';
import '../widgets/new_notes.dart';
import '../widgets/new_notes_request.dart';
import 'notes_by_subject_screen.dart';
import 'profile_screen.dart';
import 'tabs_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await Provider.of<NotificationService>(context, listen: false)
          .initializeService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) => MaterialApp(
        title: 'Horario',
        theme: ThemeData(
          // dark theme
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF121212),
          cardColor: const Color(0xFF252525),
          errorColor: Colors.redAccent,
          accentColor: Colors.blueAccent,
          unselectedWidgetColor: Colors.grey,
          appBarTheme: const AppBarTheme(
            textTheme: TextTheme(
              headline6: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              overline: TextStyle(
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          textTheme: const TextTheme(
            bodyText1: TextStyle(
              color: Colors.white,
            ),
            bodyText2: TextStyle(
              color: Colors.white54,
            ),
            headline6: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        routes: {
          HomeScreen.routeName: (_) => const TabsScreen(0),
          ProfileScreen.routeName: (_) => Consumer<UserService>(
                builder: (context, userService, _) =>
                    ProfileScreen(auth, userService),
              ),
          NewNotesRequest.routeName: (_) => NewNotesRequest(),
        },
        onGenerateRoute: (settings) {
          // passing arguments to routes
          if (settings.name == TabsScreen.routeName) {
            final int selected = (settings.arguments ?? 0) as int;
            return MaterialPageRoute(
              builder: (context) => TabsScreen(selected),
            );
          } else if (settings.name == NewClass.routeName) {
            final Map<String, dynamic>? data =
                settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => NewClass(data),
            );
          } else if (settings.name == NewAssignment.routeName) {
            final Map<String, dynamic>? data =
                settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => NewAssignment(data),
            );
          } else if (settings.name == NewNotes.routeName) {
            final Map<String, dynamic>? data =
                settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => NewNotes(data),
            );
          } else if (settings.name == NotesBySubjectScreen.routeName) {
            final String subject = (settings.arguments ?? "") as String;
            return MaterialPageRoute(
              builder: (context) => NotesBySubjectScreen(subject),
            );
          }
        },
      ),
    );
  }
}
