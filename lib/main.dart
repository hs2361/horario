import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:horario/providers/user_service.dart';
import 'package:provider/provider.dart';

import 'providers/auth_service.dart';
import 'providers/classes.dart';
import 'providers/notes.dart';
import 'providers/notification_service.dart';
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

  bool _hasVerifiedEmail(AsyncSnapshot<User?> snapshot) =>
      snapshot.hasData && snapshot.data!.emailVerified;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthService(FirebaseAuth.instance),
          ),
          ChangeNotifierProvider(
            create: (_) => UserService(),
          ),
          ChangeNotifierProvider(
            create: (_) => NotificationService(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Notes(ctx),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Classes(ctx, null),
          ),
          ChangeNotifierProxyProvider<NotificationService, Classes>(
            create: (ctx) => Classes(ctx, null),
            update: (ctx, notificationService, previous) =>
                Classes(ctx, notificationService),
          )
        ],
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) => MaterialApp(
            theme: theme,
            home: _hasVerifiedEmail(snapshot) ? HomeScreen() : LoginScreen(),
          ),
        ),
      );
}
