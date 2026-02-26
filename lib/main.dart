import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:rychtech/home.dart';
import 'package:rychtech/login.dart';
import 'package:rychtech/page_hodiny.dart';
import 'package:rychtech/page_programy.dart';
import 'package:rychtech/page_settings.dart';
import 'package:rychtech/page_zvonenie_zosnulemu.dart';
import 'package:rychtech/page_zvony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../include/style.dart' as style;
import 'package:flutter_app_badger/flutter_app_badger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterAppBadger.removeBadge();
  await OnePref.init();

  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name');
  final mail = prefs.getString('mail');

  final loggedIn = (name != null && mail != null);

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({Key? key, required this.loggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlineBell',
      theme: style.MainAppStyle().themeData, // tu sa načíta červená téma
      home: loggedIn ? HomePage() : login(),
      routes: {
        '/home': (context) => HomePage(),
        '/PageHodiny': (context) => PageHodiny(),
        '/PageSetting': (context) => PageSetting(),
        '/PageZvony': (context) => PageZvony(),
        '/PageProgramy': (context) => PageProgramy(),
        '/ZvonenieZosnulemu': (context) => ZvonenieZosnulemu(),
        '/login': (context) => login(),
      },
    );
  }
}
