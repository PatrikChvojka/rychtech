import 'package:flutter/material.dart';
import 'package:rychtech/include/appbar.dart';
import 'package:rychtech/models/user_data.dart';
import '../include/drupal_api.dart';

class PageZvony extends StatefulWidget {
  const PageZvony({super.key});

  @override
  State<PageZvony> createState() => _PageZvonyState();
}

class _PageZvonyState extends State<PageZvony> {
  String zvonyString = "0,0,0,0,0,0,0,0";
  List<int> values = List.filled(8, 0);

  int uid = 0;
  final code = 54;

  final DrupalAPI api = DrupalAPI();

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    String uidStr = await UserData.getCurrentUser('uid');
    uid = int.tryParse(uidStr) ?? 0;
    await loadZvonyString();
  }

  Future<void> loadZvonyString() async {
    String result = await api.getZvonyString(uid, code);

    if (result.isEmpty || result.split(',').length < 8) {
      result = "0,0,0,0,0,0,0,0";
    }

    setState(() {
      zvonyString = result;
      values = ZvonyUtils.toIntList(result);
    });
  }

  Future<void> updateZvon(int index, bool stav) async {
    values[index] = stav ? 1 : 0;

    String newString = values.join(',');

    bool success = await api.setZvonyString(uid, code, newString);

    if (success) {
      setState(() {
        zvonyString = newString;
      });
    } else {
      print("Chyba pri ukladaní!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(pageTitle: 'Zvony'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(children: [_buildZvonButton("Zvon 1", 0), _buildZvonButton("Zvon 2", 1), _buildZvonButton("Zvon 3", 2), _buildZvonButton("Zvon 4", 3), _buildZvonButton("Zvon 5", 4)]),
      ),
    );
  }

  Widget _buildZvonButton(String title, int index) {
    bool isActive = values[index] == 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: () {
          updateZvon(index, !isActive);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: isActive ? Colors.green : Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
