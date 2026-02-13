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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(pageTitle: 'Home'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            _buildBox("Zvony", Color.fromRGBO(136, 33, 29, 1), context, "WebAdresy"),
            _buildBox("Programy", Color.fromRGBO(11, 67, 216, 1), context, "WebAdresy"),
            _buildBox("Hodiny", Color.fromRGBO(48, 152, 55, 1), context, "WebAdresy"),
            _buildBox("Zvonenie zosnulému", Color.fromRGBO(156, 39, 176, 1), context, "WebAdresy"),
            _buildBox("Nastavania", Color.fromRGBO(237, 173, 42, 1), context, "WebAdresy"),
          ],
        ),
      ),

      /* BOTTOM MENU */
      bottomNavigationBar: const BottomMenu(index: 0),
    );
  }

  Widget _buildBox(String title, Color color, BuildContext context, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/$route');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // aby bol text čitateľný
          ),
        ),
      ),
    );
  }
}
