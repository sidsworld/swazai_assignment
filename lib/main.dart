import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swazai_assignment/activities/home.dart';
import 'package:swazai_assignment/activities/login.dart';
import 'package:swazai_assignment/utils/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swazai Assignment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case loginRoute:
            return MaterialPageRoute(
              builder: (_) => const Login(),
              settings: settings,
            );
          case homeRoute:
            return MaterialPageRoute(
              builder: (_) => const Home(),
              settings: settings,
            );

          default:
            return null;
        }
      },
      home: const Login(),
    );
  }
}
