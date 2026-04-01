import 'package:flutter/material.dart';
import 'package:rychtech/include/drupal_api.dart';
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
  final DrupalAPI api = DrupalAPI();

  int uid = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  // ================= INIT =================

  Future<void> initData() async {
    String uidStr = await UserData.getCurrentUser('uid');
    uid = int.tryParse(uidStr) ?? 0;

    // aktivita
    print("uid");
    print(uid);

    // aktivita
    await api.setZvonyString(uid, 32, "1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(pageTitle: 'Home'),
      backgroundColor: const Color.fromRGBO(230, 237, 253, 1),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            _buildBox("Zvony", Color.fromRGBO(150, 0, 0, 1), context, "PageZvony"),
            _buildBox("Programy", Color.fromRGBO(0, 0, 150, 1), context, "PageProgramy"),
            _buildBox("Hodiny", Color.fromRGBO(0, 89, 0, 1), context, "PageHodiny"),
            _buildBox("Zvonenie zosnulému", Color.fromRGBO(100, 0, 100, 1), context, "ZvonenieZosnulemu"),
            _buildBox("Nastavania", Color.fromRGBO(220, 118, 0, 1), context, "PageSetting"),
          ],
        ),
      ),

      /* BOTTOM MENU */
      // bottomNavigationBar: const BottomMenu(index: 0),
    );
  }

  Widget _buildBox(String title, Color color, BuildContext context, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/$route').then((_) => initData());
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
