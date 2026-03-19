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
  int mask = 0;

  bool isLeto = true;
  bool automatickeZvonenia = false;
  bool odbijanieCasu = false;
  bool cyklusPol = true; // true = 1/2, false = 1/4

  int uid = 0;
  final code = 90;

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

    int m = int.tryParse(result) ?? 0;

    setState(() {
      mask = m;

      isLeto = (m & (1 << 0)) != 0;
      automatickeZvonenia = (m & (1 << 1)) != 0;
      odbijanieCasu = (m & (1 << 2)) != 0;
      cyklusPol = (m & (1 << 3)) != 0;
    });
  }

  Future<void> updateMask({bool? leto, bool? autoZvonenie, bool? odbijanie, bool? cyklus}) async {
    int newMask = mask;

    if (leto != null) {
      if (leto) {
        newMask |= (1 << 0);
      } else {
        newMask &= ~(1 << 0);
      }
    }

    if (autoZvonenie != null) {
      if (autoZvonenie) {
        newMask |= (1 << 1);
      } else {
        newMask &= ~(1 << 1);
      }
    }

    if (odbijanie != null) {
      if (odbijanie) {
        newMask |= (1 << 2);
      } else {
        newMask &= ~(1 << 2);
      }
    }

    if (cyklus != null) {
      if (cyklus) {
        newMask |= (1 << 3);
      } else {
        newMask &= ~(1 << 3);
      }
    }

    bool success = await api.setZvonyString(uid, code, newMask.toString());

    if (success) {
      setState(() {
        mask = newMask;

        if (leto != null) isLeto = leto;
        if (autoZvonenie != null) automatickeZvonenia = autoZvonenie;
        if (odbijanie != null) odbijanieCasu = odbijanie;
        if (cyklus != null) cyklusPol = cyklus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nastavenia")),

      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(15.0),

        child: ListView(
          children: [
            /// UTC
            _buildSectionCard(
              title: "Zóna UTC",
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateMask(leto: true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: isLeto ? Colors.blue : Colors.grey.shade300),
                      child: Text("Leto", style: TextStyle(color: isLeto ? Colors.white : Colors.black)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateMask(leto: false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: !isLeto ? Colors.blue : Colors.grey.shade300),
                      child: Text("Zima", style: TextStyle(color: !isLeto ? Colors.white : Colors.black)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// AUTO
            _buildSectionCard(
              title: "Automatické zvonenia",
              child: SwitchListTile(
                value: automatickeZvonenia,
                onChanged: (val) {
                  updateMask(autoZvonenie: val);
                },
                title: Text(automatickeZvonenia ? "Zapnuté" : "Vypnuté"),
              ),
            ),

            const SizedBox(height: 15),

            /// ODBIJANIE
            _buildSectionCard(
              title: "Odbíjanie času",
              child: SwitchListTile(
                value: odbijanieCasu,
                onChanged: (val) {
                  updateMask(odbijanie: val);
                },
                title: Text(odbijanieCasu ? "Zapnuté" : "Vypnuté"),
              ),
            ),

            const SizedBox(height: 15),

            /// CYKLUS
            _buildSectionCard(
              title: "Cyklus",
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateMask(cyklus: true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: cyklusPol ? Colors.blue : Colors.grey.shade300),
                      child: Text("½", style: TextStyle(color: cyklusPol ? Colors.white : Colors.black)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateMask(cyklus: false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: !cyklusPol ? Colors.blue : Colors.grey.shade300),
                      child: Text("¼", style: TextStyle(color: !cyklusPol ? Colors.white : Colors.black)),
                    ),
                  ),
                ],
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
