import 'package:flutter/material.dart';
import 'package:rychtech/include/style.dart' as style;
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

    // aktivita
    api.setZvonyString(uid, 32, "1");
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
    final yellowSwitchTheme = Theme.of(context).copyWith(
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return style.MainAppStyle().zlta;
          }
          return const Color.fromARGB(255, 104, 104, 104);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return style.MainAppStyle().zlta.withOpacity(0.5);
          }
          return const Color.fromARGB(255, 123, 123, 123).withOpacity(0.3);
        }),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Nastavenia"), backgroundColor: const Color.fromRGBO(220, 118, 0, 1)),

      backgroundColor: const Color.fromRGBO(230, 237, 253, 1),

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
                      style: ElevatedButton.styleFrom(backgroundColor: isLeto ? style.MainAppStyle().zlta : const Color.fromRGBO(110, 110, 110, 1)),
                      child: Text("Leto", style: TextStyle(color: isLeto ? Colors.black : Colors.white)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateMask(leto: false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: !isLeto ? style.MainAppStyle().zlta : const Color.fromRGBO(110, 110, 110, 1)),
                      child: Text("Zima", style: TextStyle(color: !isLeto ? Colors.black : Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// AUTO
            _buildSectionCard(
              title: "Automatické zvonenia",
              child: Theme(
                data: yellowSwitchTheme,
                child: SwitchListTile(
                  value: automatickeZvonenia,
                  onChanged: (val) {
                    updateMask(autoZvonenie: val);
                  },
                  title: Text(automatickeZvonenia ? "Zapnuté" : "Vypnuté"),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// ODBIJANIE
            _buildSectionCard(
              title: "Odbíjanie času",
              child: Theme(
                data: yellowSwitchTheme,
                child: SwitchListTile(
                  value: odbijanieCasu,
                  onChanged: (val) {
                    updateMask(odbijanie: val);
                  },
                  title: Text(odbijanieCasu ? "Zapnuté" : "Vypnuté"),
                ),
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
                      style: ElevatedButton.styleFrom(backgroundColor: cyklusPol ? style.MainAppStyle().zlta : const Color.fromARGB(255, 104, 104, 104)),
                      child: Text("1/2", style: TextStyle(color: cyklusPol ? Colors.black : Colors.white)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateMask(cyklus: false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: !cyklusPol ? style.MainAppStyle().zlta : const Color.fromARGB(255, 104, 104, 104)),
                      child: Text("1/4", style: TextStyle(color: !cyklusPol ? Colors.black : Colors.white)),
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
