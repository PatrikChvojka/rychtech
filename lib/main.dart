import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:rychtech/home.dart';
import 'package:rychtech/login.dart';
import 'package:rychtech/page_hodiny.dart';
import 'package:rychtech/page_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../include/style.dart' as style;
import 'package:flutter_app_badger/flutter_app_badger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Odstránenie ikony notifikácie
  FlutterAppBadger.removeBadge();

  await OnePref.init();

  // Skontrolujeme, či sú uložené údaje o používateľovi
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name');
  final mail = prefs.getString('mail');

  // Ak sú uložené údaje o používateľovi, je prihlásený
  final loggedIn = (name != null && mail != null);

  runApp(
    MaterialApp(
      theme: style.MainAppStyle().themeData,
      home: MyApp(loggedIn: loggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({Key? key, required this.loggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlineBell',
      theme: style.MainAppStyle().themeData,
      home: loggedIn ? HomePage() : login(), // Ak je prihlásený, zobraziť domovskú stránku, inak prihlásenie
      routes: {'/home': (context) => HomePage(), '/PageHodiny': (context) => PageHodiny(), '/PageSetting': (context) => PageSetting(), '/login': (context) => login()},
    );
  }
}
