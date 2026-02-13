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
}
