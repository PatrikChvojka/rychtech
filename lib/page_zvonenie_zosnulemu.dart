import 'package:flutter/material.dart';
import 'package:rychtech/include/style.dart' as style;
import '../include/drupal_api.dart';

class ZvonenieZosnulemu extends StatefulWidget {
  const ZvonenieZosnulemu({super.key});

  @override
  State<ZvonenieZosnulemu> createState() => _ZvonenieZosnulemuState();
}

class _ZvonenieZosnulemuState extends State<ZvonenieZosnulemu> {
  final DrupalAPI api = DrupalAPI();

  bool isLoading = true;
  bool aktivne = false;

  TimeOfDay time1 = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay time2 = const TimeOfDay(hour: 18, minute: 0);

  late TextEditingController dlzkaController;

  List<bool> zvony = List.filled(5, false);

  int den = 1;
  int mesiac = 1;

  @override
  void initState() {
    super.initState();
    dlzkaController = TextEditingController(text: "30");
    loadData();
  }

  // ======================
  // LOAD
  // ======================
  Future<void> loadData() async {
    String result = await api.getZvonenieZosnulemu();

    // default
    if (result.isEmpty || result == "0") {
      setState(() => isLoading = false);
      return;
    }

    List<String> p = result.split(',');

    aktivne = p[0] == "1";

    List t1 = p[1].split(':');
    List t2 = p[2].split(':');

    time1 = TimeOfDay(hour: int.parse(t1[0]), minute: int.parse(t1[1]));
    time2 = TimeOfDay(hour: int.parse(t2[0]), minute: int.parse(t2[1]));

    dlzkaController.text = p[3];

    // zvony
    for (int i = 0; i < 5; i++) {
      zvony[i] = p[4].contains("${i + 1}");
    }

    den = int.parse(p[5]);
    mesiac = int.parse(p[6]);

    setState(() => isLoading = false);
  }

  // ======================
  // SAVE
  // ======================
  Future<void> saveData(bool stav) async {
    aktivne = stav;

    String t1 = "${time1.hour.toString().padLeft(2, '0')}:${time1.minute.toString().padLeft(2, '0')}";
    String t2 = "${time2.hour.toString().padLeft(2, '0')}:${time2.minute.toString().padLeft(2, '0')}";

    String dlzka = dlzkaController.text.trim();
    if (dlzka.isEmpty) dlzka = "0";

    String zvStr = "";
    for (int i = 0; i < 5; i++) {
      if (zvony[i]) zvStr += "${i + 1}";
    }
    if (zvStr.isEmpty) zvStr = "0";

    String data = "${aktivne ? 1 : 0},$t1,$t2,$dlzka,$zvStr,$den,$mesiac";

    await api.setZvonenieZosnulemu(data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(aktivne ? "Zapnuté" : "Vypnuté")));
    }
  }

  // ======================
  // PICKERS
  // ======================
  Future<void> pickTime(bool first) async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: first ? time1 : time2);

    if (t != null) {
      setState(() {
        if (first) {
          time1 = t;
        } else {
          time2 = t;
        }
      });
    }
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();

    // dátum z nastavení
    DateTime initial = DateTime(now.year, mesiac, den);

    // ak je v minulosti → nastav na dnešok
    if (initial.isBefore(now)) {
      initial = now;
    }

    DateTime? d = await showDatePicker(context: context, initialDate: initial, firstDate: now, lastDate: DateTime(now.year + 5));

    if (d != null) {
      setState(() {
        den = d.day;
        mesiac = d.month;
      });
    }
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Zvonenie zosnulému")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildTimeTile("Čas zvonenia 1", time1, () => pickTime(true)),
          const SizedBox(height: 10),
          buildTimeTile("Čas zvonenia 2", time2, () => pickTime(false)),

          const SizedBox(height: 15),

          TextField(
            controller: dlzkaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Dĺžka zvonenia (sekundy)", border: OutlineInputBorder()),
          ),

          const SizedBox(height: 15),

          const Text("Výber zvonov", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          for (int i = 0; i < 5; i++) SwitchListTile(title: Text("Zvon ${i + 1}"), value: zvony[i], onChanged: (v) => setState(() => zvony[i] = v)),

          const SizedBox(height: 10),

          InkWell(
            onTap: pickDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: Text("Dátum do: ${den.toString().padLeft(2, '0')}.${mesiac.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => saveData(true),
                  child: const Text("Zapnúť"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: style.MainAppStyle().mainColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => saveData(false),
                  child: const Text("Vypnúť"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTimeTile(String title, TimeOfDay time, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
      child: ListTile(title: Text(title), subtitle: Text(time.format(context)), trailing: const Icon(Icons.access_time), onTap: onTap),
    );
  }
}
