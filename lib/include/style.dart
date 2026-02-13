import 'package:flutter/material.dart';

class MainAppStyle {
  // font family
  ThemeData themeData = ThemeData(
    fontFamily: 'Montserrat',
    primarySwatch: createMaterialColor(Color.fromRGBO(0, 70, 103, 1)),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: createMaterialColor(Color.fromRGBO(0, 70, 103, 1)), // Nastaví farbu načítavacích koliečok
    ),
    splashColor: Color.fromRGBO(167, 209, 228, 1),
    hoverColor: Color.fromRGBO(167, 209, 228, 1),
    highlightColor: Color.fromRGBO(167, 209, 228, 1),
  );

  // MAIN Color
  Color bledsiamodra = Color.fromRGBO(151, 222, 223, 1);
  Color mainColor = Color.fromRGBO(158, 4, 4, 1);
  Color secondColor = Color.fromRGBO(192, 46, 46, 1);
  Color colorText = Color.fromRGBO(43, 43, 43, 1);
  Color colorOranzova = Color.fromRGBO(254, 102, 0, 1);

  // bodyBG
  Color bodyBG = Color.fromRGBO(221, 242, 245, 1);
  Color headerBg = Color.fromRGBO(0, 70, 103, 1);

  // buttonBG
  Color buttonBG = Color.fromRGBO(77, 183, 74, 1);
  Color buttonTextColor = Colors.white;
}

MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05];
  final swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (var strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(r + ((ds < 0 ? r : (255 - r)) * ds).round(), g + ((ds < 0 ? g : (255 - g)) * ds).round(), b + ((ds < 0 ? b : (255 - b)) * ds).round(), 1);
  }

  return MaterialColor(color.value, swatch);
}
