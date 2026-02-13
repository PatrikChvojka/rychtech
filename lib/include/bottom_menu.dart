import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
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

    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    onTapFunction(i) {
      if (i == 0) {
        Navigator.of(context).popAndPushNamed("/home");
      }

      if (i == 1) {
        Navigator.pushNamed(context, '/home');
      }

      if (i == 2) {
        Navigator.of(context).popAndPushNamed("/PageSetting");
      }
    }

    return StyleProvider(
      style: StyleBottomMenu(),
      child: ConvexAppBar(
        backgroundColor: Color.fromRGBO(240, 241, 245, 1),
        activeColor: style.MainAppStyle().secondColor,
        color: style.MainAppStyle().mainColor,
        cornerRadius: 0.0,
        height: 50.0,
        elevation: 0.5, // tien
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.info),
          TabItem(icon: Icons.home),
          TabItem(icon: Icons.settings),
        ],
        initialActiveIndex: 1,
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
