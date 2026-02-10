import 'dart:convert';

import 'package:rychtech/include/drupal_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserData {
  // load user data
  static Future<Map<String, dynamic>> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    String? name = prefs.getString('name');
    String? mail = prefs.getString('mail');
    List<String>? roles = prefs.getStringList('roles');

    return {'name': name, 'mail': mail, 'roles': roles, 'uid': uid};
  }

  // get Current User name
  static Future<String> getCurrentUser(String type) async {
    Map<String, dynamic> userData = await loadUserData();
    return userData[type] ?? 'Neznámy používateľ'; // Ak nie je meno, vráti sa predvolený text
  }

  // logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Vymaže všetky údaje
  }
}
