import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../include/style.dart' as style;

class BottomMenu extends StatefulWidget {
  final int index;

  const BottomMenu({Key? key, required this.index}) : super(key: key);

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  late int index;
  List<String> _userRoles = [];

  @override
  void initState() {
    super.initState();

    // Start loading data immediately
    _initializeData();

    index = widget.index;
  }

  // New method to handle initialization
  Future<void> _initializeData() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final uid_role = prefs.getStringList('roles') ?? [];

    setState(() {
      _userRoles = uid_role;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_userRoles);
    onTapFunction(i) {
      if (i == 0) {
        Navigator.of(context).popAndPushNamed("/home");
      }

      if (i == 1 && _userRoles.contains("Zamestnanecká skupina")) {
        Navigator.of(context).popAndPushNamed("/scan");
      }
      if (i == 1 && !_userRoles.contains("Zamestnanecká skupina")) {
        Navigator.pushNamed(context, '/OznamyVypis');
      }

      if (i == 2) {
        Navigator.of(context).popAndPushNamed("/settingspage");
      }
    }

    return StyleProvider(
      style: StyleBottomMenu(),
      child: ConvexAppBar(
        backgroundColor: Color.fromRGBO(240, 241, 245, 1),
        activeColor: style.MainAppStyle().secondColor,
        color: Color.fromRGBO(19, 65, 101, 1),
        cornerRadius: 0.0,
        height: 50.0,
        elevation: 0.5, // tien
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home),
          if (_userRoles.contains("Zamestnanecká skupina")) ...[TabItem(icon: Icons.qr_code, title: 'Oskenuj')] else ...[TabItem(icon: Icons.list_alt_outlined, title: 'Zamknuté')],
          TabItem(icon: Icons.settings),
        ],
        initialActiveIndex: index,
        onTap: (int i) => onTapFunction(i),
      ),
    );
  }
}

class StyleBottomMenu extends StyleHook {
  @override
  double get activeIconSize => 30;

  @override
  double get activeIconMargin => 10;

  @override
  double get iconSize => 28;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 13, color: color);
  }
}
