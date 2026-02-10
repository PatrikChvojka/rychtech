import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_data.dart';

class DrupalAPI {
  // variables
  String drupalURLWeb = "https://clegoo.com/";
  String drupalURL = "https://clegoo.com/api";
  final username = 'api_375';
  final password = 'apiHb@Clean24';
}
