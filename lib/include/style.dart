import 'package:flutter/material.dart';

class MainAppStyle {
  // hlavné farby
  final Color bledsiamodra = Color.fromRGBO(151, 222, 223, 1);
  final Color mainColor = Color.fromRGBO(158, 4, 4, 1); // tmavočervená
  final Color secondColor = Color.fromRGBO(192, 46, 46, 1);
  final Color colorText = Color.fromRGBO(43, 43, 43, 1);
  final Color colorOranzova = Color.fromRGBO(254, 102, 0, 1);

  final Color bodyBG = Color.fromRGBO(221, 242, 245, 1);
  final Color headerBg = Color.fromRGBO(158, 4, 4, 1);

  final Color buttonBG = Color.fromRGBO(192, 46, 46, 1); // tu už neodkazujeme secondColor
  final Color buttonTextColor = Colors.white;

  ThemeData themeData = ThemeData(
    fontFamily: 'Montserrat',
    primarySwatch: createMaterialColor(Color.fromRGBO(158, 4, 4, 1)),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Color.fromRGBO(158, 4, 4, 1))).copyWith(
      secondary: Color.fromRGBO(192, 46, 46, 1), // pre Switch a ďalšie accent widgety
    ),
    appBarTheme: AppBarTheme(backgroundColor: Color.fromRGBO(158, 4, 4, 1), foregroundColor: Colors.white),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Color.fromRGBO(158, 4, 4, 1)),
    splashColor: Color.fromRGBO(254, 102, 0, 1),
    hoverColor: Color.fromRGBO(254, 102, 0, 1),
    highlightColor: Color.fromRGBO(254, 102, 0, 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(192, 46, 46, 1), foregroundColor: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(158, 4, 4, 1), width: 2)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Color.fromRGBO(158, 4, 4, 1); // červený pri ON
        }
        return Colors.grey; // farba pri OFF
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Color.fromRGBO(192, 46, 46, 0.5); // track pri ON
        }
        return Colors.grey.withOpacity(0.3); // track pri OFF
      }),
    ),
  );
}

MaterialColor createMaterialColor(Color color) {
  final swatch = <int, Color>{};
  final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];

  for (var strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      color.red + ((ds < 0 ? color.red : (255 - color.red)) * ds).round(),
      color.green + ((ds < 0 ? color.green : (255 - color.green)) * ds).round(),
      color.blue + ((ds < 0 ? color.blue : (255 - color.blue)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}
