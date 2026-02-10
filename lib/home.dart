import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../include/appbar.dart';
import '../include/bottom_menu.dart';
import '../include/style.dart' as style;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../models/user_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _userRoles = [];

  @override
  void initState() {
    super.initState();

    // Start loading data immediately
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    // TEST: simuluj dáta
    final uid_role = prefs.getStringList('roles') ?? ['Obyvateľ', 'Firma']; // <- defaultne nech tam niečo je

    setState(() {
      _userRoles = uid_role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(pageTitle: 'Home'),
      backgroundColor: Colors.white,
      body: _userRoles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0, top: 15.0),
              child: Column(children: [Text("test")]),
            ),
      /* BOTTOM MENU */
      bottomNavigationBar: const BottomMenu(index: 0),
    );
  }

  Widget _buildBox(String title, String icon, BuildContext context, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/$route');
      },
      child: Container(
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          //  color: Color.fromRGBO(197, 197, 197, 1).withOpacity(0.9),
          color: Color.fromRGBO(232, 234, 240, 1),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: EdgeInsets.all(16), child: Image.asset("lib/assets/images/$icon.png", height: 55, width: 55)),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  // color: iconBgColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
