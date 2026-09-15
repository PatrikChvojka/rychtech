import 'package:flutter/material.dart';
import 'package:rychtech/include/drupal_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../include/appbar.dart';
import '../include/bottom_menu.dart';
import '../include/style.dart' as style;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

class _HomeMenuItem {
  final String title;
  final Color color;
  final String route;

  const _HomeMenuItem({required this.title, required this.color, required this.route});
}

const Map<int, _HomeMenuItem> _menuByTid = {
  692: _HomeMenuItem(title: 'Zvony', color: Color.fromRGBO(150, 0, 0, 1), route: 'PageZvony'),
  693: _HomeMenuItem(title: 'Programy', color: Color.fromRGBO(0, 0, 150, 1), route: 'PageProgramy'),
  694: _HomeMenuItem(title: 'Hodiny', color: Color.fromRGBO(0, 89, 0, 1), route: 'PageHodiny'),
  695: _HomeMenuItem(title: 'Zvonenie zosnulému', color: Color.fromRGBO(100, 0, 100, 1), route: 'ZvonenieZosnulemu'),
  696: _HomeMenuItem(title: 'Nastavenia', color: Color.fromRGBO(220, 118, 0, 1), route: 'PageSetting'),
};

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final DrupalAPI api = DrupalAPI();

  int uid = 0;
  bool isLoading = true;
  List<_HomeMenuItem> menuItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initData();
    }
  }

  // ================= INIT =================

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    uid = int.tryParse(prefs.getString('uid')?.trim() ?? '') ?? 0;

    final tids = await api.getMenuTids(uid);
    final items = <_HomeMenuItem>[];

    for (final tid in tids) {
      final item = _menuByTid[tid];
      if (item != null) items.add(item);
    }

    debugPrint('Home menu uid=$uid tids=$tids items=${items.map((e) => e.title).toList()}');

    if (mounted) {
      setState(() {
        menuItems = items;
        isLoading = false;
      });
    }

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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : menuItems.isEmpty
            ? const Center(child: Text('Žiadne položky menu'))
            : ListView(children: [for (final item in menuItems) _buildBox(item.title, item.color, context, item.route)]),
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
