import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';

class DrupalAPI {
  // variables
  String drupalURLWeb = "https://cms.rychtech.sk/";
  String drupalURL = "https://cms.rychtech.sk/api";
  final username = 'api_424';
  final password = 'apiHb@Clean24';

  /// Funkcia, ktorá z PHP skriptu načíta string podľa UID a CODE
  Future<String> getZvonyString(int uid, int code) async {
    try {
      // tvoja PHP adresa, kde je skript napr. zvony.php
      final url = Uri.parse('http://api.rychtech.sk/$uid/$code');

      // volanie GET requestu
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // vrátime body odpovede
        return response.body;
      } else {
        // niečo sa pokazilo
        return "0,0,0,0,0,0,0,0";
      }
    } catch (e) {
      // chyba pri requeste
      return "0,0,0,0,0,0,0,0";
    }
  }

  /// Príklad funkcie na zápis stringu do DB
  Future<bool> setZvonyString(int uid, int code, String string) async {
    try {
      final url = Uri.parse('http://api.rychtech.sk/$uid/$code/${Uri.encodeComponent(string)}');

      final response = await http.get(url);

      if (response.statusCode == 200 && response.body == "OK") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

class ZvonyUtils {
  /// Funkcia z CSV stringu vracia číslo na zvolenom indexe (0-based)
  /// Ak string nemá dostatok hodnôt, vráti 0
  static int getValueFromString(String csvString, int index) {
    try {
      List<String> parts = csvString.split(',');
      if (index < 0 || index >= parts.length) return 0;
      return int.tryParse(parts[index].trim()) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Voliteľne: funkcia na prevod celého CSV stringu na List<int>
  static List<int> toIntList(String csvString) {
    try {
      return csvString.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    } catch (e) {
      return List.filled(8, 0); // default 8 núl
    }
  }
}
