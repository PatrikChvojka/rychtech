import 'package:flutter/material.dart';
import 'package:rychtech/include/appbar.dart';
import 'package:rychtech/models/user_data.dart';
import 'package:rychtech/page_programy_detail.dart';
import '../include/drupal_api.dart';

class PageProgramy extends StatefulWidget {
  const PageProgramy({super.key});

  @override
  State<PageProgramy> createState() => _PageProgramyState();
}

class _PageProgramyState extends State<PageProgramy> {
  final DrupalAPI api = DrupalAPI();

  int uid = 0;

  // Programy 11 - 30
  final int startCode = 11;
  final int programCount = 20;

  // uložené dáta
  List<String> programStrings = List.filled(20, "0,00:00,0,0,0,0,0,0");
  List<bool> programEnabled = List.filled(20, false);

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    String uidStr = await UserData.getCurrentUser('uid');
    uid = int.tryParse(uidStr) ?? 0;
    await loadPrograms();

    // aktivita
    await api.setZvonyString(uid, 32, "1");
  }

  // =========================
  // Načítanie programov z DB
  // =========================
  Future<void> loadPrograms() async {
    for (int i = 0; i < programCount; i++) {
      int code = startCode + i;

      String result = await api.getZvonyString(uid, code);

      List parts = result.split(',');

      // Ak je prázdne alebo je to default "0,00:00,0,0,0,0,0,0" → prázdne hodnoty
      if (result.isEmpty || parts.join(',') == "0,00:00,0,0,0,0,0,0") {
        parts = ["0", "", "", "", "", "", "", ""];
      } else {
        // Oprava času (2. hodnota)
        String time = parts[1].toString().trim();
        if (time.isEmpty || time == "0" || time == "0:0" || time == "00:0" || time == "0:00") {
          parts[1] = "";
        }
      }

      programStrings[i] = parts.join(',');
      programEnabled[i] = parts[0] == "1";
    }

    setState(() {});
  }

  // =========================
  // Pomocné funkcie
  // =========================
  String getProgramTitle(int index) {
    String data = programStrings[index];
    List parts = data.split(',');

    if (parts.length < 2) {
      return "PROGRAM ${index + 1}";
    }

    // perioda: 0 = týždeň (zobraziť čas), 1 = rok (zobraziť dátum)
    int perioda = parts.length > 5 ? int.tryParse(parts[5].toString()) ?? 0 : 0;

    if (perioda == 1 && parts.length > 7) {
      int den = int.tryParse(parts[6].toString()) ?? 0;
      int mesiac = int.tryParse(parts[7].toString()) ?? 0;

      if (den > 0 && mesiac > 0) {
        return "${den.toString().padLeft(2, '0')}.${mesiac.toString().padLeft(2, '0')}";
      }
    }

    if (parts[1].toString().trim().isEmpty) {
      return "PROGRAM ${index + 1}";
    }

    return parts[1]; // čas
  }

  // =========================
  // Zap/Vyp programu
  // =========================
  Future<void> toggleProgram(int index) async {
    int code = startCode + index;

    List parts = programStrings[index].split(',');

    if (parts.length < 8) {
      parts = ["0", "", "", "", "", "", "", ""];
    }

    bool willEnable = parts[0] != "1";

    // prepni stav
    parts[0] = willEnable ? "1" : "0";

    String newString = parts.join(',');

    bool success = await api.setZvonyString(uid, code, newString);

    if (success) {
      setState(() {
        programStrings[index] = newString;
        programEnabled[index] = parts[0] == "1";
      });
    } else {
      print("Chyba pri ukladaní programu ${index + 1}");
    }
  }

  // =========================
  // Otvorenie detailu
  // =========================
  void openDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PageProgramDetail(
          uid: uid,
          code: startCode + index,
          dataString: programStrings[index],
          onDataChanged: (newString) {
            setState(() {
              programStrings[index] = newString;
              programEnabled[index] = newString.split(',')[0] == "1";
            });
          },
        ),
      ),
    ).then((_) => initData());
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Programy"), backgroundColor: const Color.fromRGBO(0, 0, 150, 1)),
      backgroundColor: const Color.fromRGBO(230, 237, 253, 1),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView.builder(
          itemCount: programCount,
          itemBuilder: (context, index) {
            return _buildProgramRow(index);
          },
        ),
      ),
    );
  }

  Widget _buildProgramRow(int index) {
    bool enabled = programEnabled[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Ľavá časť
          Expanded(
            child: InkWell(
              onTap: () => openDetail(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                decoration: BoxDecoration(
                  color: enabled ? const Color.fromRGBO(0, 0, 150, 1) : const Color.fromRGBO(96, 96, 96, 1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: enabled ? const Color.fromRGBO(0, 0, 150, 1) : Color.fromRGBO(96, 96, 96, 1)),
                ),
                child: Text(
                  getProgramTitle(index),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: enabled ? Colors.white : Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Pravý štvorček (zap/vyp)
          InkWell(
            onTap: () => toggleProgram(index),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: enabled ? const Color.fromRGBO(0, 89, 0, 1) : const Color.fromRGBO(150, 0, 0, 1), borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }
}
