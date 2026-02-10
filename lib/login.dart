import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../include/style.dart' as style;
import '../include/drupal_api.dart';
import '../models/user_data.dart';
import 'home.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    final url = Uri.parse('${DrupalAPI().drupalURL}/user/login');
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'username': _usernameController.text, 'password': _passwordController.text}));

    if (response.statusCode == 200) {
      // success login
      final data = json.decode(response.body);

      //print(data);

      // save data
      saveUserData(data['user']);

      // redirect
      // Navigator.of(context).popAndPushNamed("/home");
    } else {
      // error
      final errorBody = json.decode(response.body);
      String errorMessage = '';

      if (errorBody is List && errorBody.isNotEmpty) {
        errorMessage = errorBody[0]; // Získa prvú správu z poľa
      } else if (errorBody is String) {
        errorMessage = errorBody;
      } else {
        errorMessage = 'Neznáma chyba!';
      }

      _showErrorMessage(context, errorMessage);
    }
  }

  // Funkcia pre zobrazenie chyby
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
  }

  void saveUserData(Map<String, dynamic> userData) async {
    String uid = userData['uid'];
    String name = userData['field_meno_n_zov_firmy']['und'][0]['value'] ?? 'Neznáme';
    String mail = userData['mail'] ?? 'Neznáme email';

    // Ulož požadované údaje do SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('mail', mail);
    await prefs.setString('uid', uid);

    // ROLES
    List<String> roles = [];
    if (userData['roles'] != null) {
      userData['roles'].forEach((key, value) {
        roles.add(value); // Pridaj hodnoty (napr. 'authenticated user', 'administrator')
      });
    }
    await prefs.setStringList('roles', roles);

    print('Užívateľské údaje boli uložené');

    // redirect

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  InputDecoration loginInputDecoration({required String label, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),

      filled: false, // žiadny background box
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),

      // iba spodná čiara
      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: style.MainAppStyle().mainColor, width: 2)),

      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // skryje klávesnicu klikom mimo
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('lib/assets/images/login_illustration3.png', height: 300),
                              const SizedBox(height: 20),
                              Text(
                                "Prihlásenie",
                                style: TextStyle(color: style.MainAppStyle().mainColor, fontSize: 22, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _usernameController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: loginInputDecoration(label: 'Používateľské meno'),
                              ),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: loginInputDecoration(
                                  label: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade500, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              InkWell(
                                onTap: _login,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  decoration: BoxDecoration(color: style.MainAppStyle().mainColor, borderRadius: BorderRadius.circular(99)),
                                  child: const Text(
                                    "Prihlásiť sa",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Nemáte ešte konto? ", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: navigácia na registráciu
                                      // Navigator.pushNamed(context, '/register');
                                    },
                                    child: Text(
                                      "Registrujte sa",
                                      style: TextStyle(color: style.MainAppStyle().mainColor, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  // forgot password
                                },
                                child: Text(
                                  "Zabudli ste svoje heslo?",
                                  style: TextStyle(color: style.MainAppStyle().mainColor, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
