import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:horario/providers/class.dart';
import 'package:horario/providers/classes.dart';
import 'package:horario/providers/note.dart';
import 'package:horario/providers/notes.dart';
import 'package:provider/provider.dart';
import 'providers/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData theme = ThemeData(
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
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => Class(),
        ),
        ChangeNotifierProvider(
          create: (_) => Classes(),
        ),
        ChangeNotifierProvider(
          create: (_) => Note(),
        ),
        ChangeNotifierProvider(
          create: (_) => Notes()
        )
      ],
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return MaterialApp(
              theme: theme,
              home: LoginScreen(),
            );
          } else {
            if (snapshot.data?.emailVerified ?? false) {
              return MaterialApp(
                theme: theme,
                home: HomeScreen(),
              );
            } else {
              return MaterialApp(
                theme: theme,
                home: LoginScreen(),
              );
            }
          }
        },
      ),
    );
  }
}
