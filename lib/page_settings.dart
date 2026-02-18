import 'package:flutter/material.dart';
import 'package:rychtech/include/appbar.dart';
import 'package:rychtech/models/user_data.dart';
import '../include/drupal_api.dart';

class PageSetting extends StatefulWidget {
  const PageSetting({super.key});

  @override
  State<PageSetting> createState() => _PageSettingState();
}

class _PageSettingState extends State<PageSetting> {
  bool isLeto = true;
  bool automatickeZvonenia = false;
  bool odbijanieCasu = false;

  String zvonyString = ""; // 8-miestny string z DB
  int uid = 0;
  final code = 90;

  final DrupalAPI api = DrupalAPI();

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    // Získame UID
    String uidStr = await UserData.getCurrentUser('uid');
    uid = int.tryParse(uidStr) ?? 0;

    await loadZvonyString();
  }

  Future<void> loadZvonyString() async {
    String result = await api.getZvonyString(uid, code);

    // Ak string prázdny alebo kratší ako 8 miest, doplníme nuly
    if (result.isEmpty || result.split(',').length < 8) {
      result = "0,0,0,0,0,0,0,0";
    }

    // Nastavíme UI hodnoty podľa prvých troch čísiel
    List<int> values = ZvonyUtils.toIntList(result);
    setState(() {
      zvonyString = result;
      isLeto = values[0] == 1;
      automatickeZvonenia = values[1] == 1;
      odbijanieCasu = values[2] == 1;
    });
  }

  // Aktualizuje zvonyString a odosiela do DB
  Future<void> updateZvonyString({bool? leto, bool? autoZvonenie, bool? odbijanie}) async {
    List<int> values = ZvonyUtils.toIntList(zvonyString);

    if (leto != null) values[0] = leto ? 1 : 0;
    if (autoZvonenie != null) values[1] = autoZvonenie ? 1 : 0;
    if (odbijanie != null) values[2] = odbijanie ? 1 : 0;

    String newString = values.join(',');

    bool success = await api.setZvonyString(uid, code, newString);

    if (success) {
      setState(() {
        zvonyString = newString;
        if (leto != null) isLeto = leto;
        if (autoZvonenie != null) automatickeZvonenia = autoZvonenie;
        if (odbijanie != null) odbijanieCasu = odbijanie;
      });
    } else {
      // Nepodarilo sa uložiť, môžeš pridať Snackbar alebo Alert
      print("Chyba pri ukladaní do DB!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(pageTitle: 'Nastavenia'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            _buildSectionCard(
              title: "Zóna UTC",
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateZvonyString(leto: true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: isLeto ? Colors.blue : Colors.grey.shade300),
                      child: Text("Leto", style: TextStyle(color: isLeto ? Colors.white : Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateZvonyString(leto: false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: !isLeto ? Colors.blue : Colors.grey.shade300),
                      child: Text("Zima", style: TextStyle(color: !isLeto ? Colors.white : Colors.black)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            _buildSectionCard(
              title: "Automatické zvonenia",
              child: SwitchListTile(
                value: automatickeZvonenia,
                onChanged: (val) {
                  updateZvonyString(autoZvonenie: val);
                },
                title: Text(automatickeZvonenia ? "Zapnuté" : "Vypnuté"),
              ),
            ),

            const SizedBox(height: 15),

            _buildSectionCard(
              title: "Odbíjanie času",
              child: SwitchListTile(
                value: odbijanieCasu,
                onChanged: (val) {
                  updateZvonyString(odbijanie: val);
                },
                title: Text(odbijanieCasu ? "Zapnuté" : "Vypnuté"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
