import 'package:flutter/material.dart';
import 'package:rychtech/include/style.dart' as style;
import '../include/drupal_api.dart';

class ZvonenieZosnulemu extends StatefulWidget {
  final Function(String)? onDataChanged; // callback späť do hlavnej

  const ZvonenieZosnulemu({super.key, this.onDataChanged});

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

  Widget _controlButton({required String text, required Color color, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent, // odstráni “ripple”
      highlightColor: Colors.transparent, // odstráni “press” efekt
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
          border: Border.all(color: isActive ? color : Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ======================
  // LOAD
  // ======================
  Future<void> loadData() async {
    String result = await api.getZvonyString(0, 77); // použijeme kód 77

    if (result.isEmpty) {
      result = "0,07:00,18:00,30,0,1,1"; // default: deaktivované, dva časy, dĺžka, zvony=0, den=1, mesiac=1
    }

    List<String> p = result.split(',');

    // doplniť prázdne položky, aby list mal aspoň 7 prvkov
    while (p.length < 7) {
      p.add("0");
    }

    // teraz je bezpečné pristupovať k p[0], p[1], ...
    aktivne = p[0] == "1";

    // bezpečné parsovanie časov
    List<String> t1 = (p.length > 1 ? p[1] : "07:00").split(':');
    List<String> t2 = (p.length > 2 ? p[2] : "18:00").split(':');

    time1 = TimeOfDay(hour: t1.isNotEmpty ? int.tryParse(t1[0]) ?? 7 : 7, minute: t1.length > 1 ? int.tryParse(t1[1]) ?? 0 : 0);

    time2 = TimeOfDay(hour: t2.isNotEmpty ? int.tryParse(t2[0]) ?? 18 : 18, minute: t2.length > 1 ? int.tryParse(t2[1]) ?? 0 : 0);

    dlzkaController.text = p.length > 3 ? p[3] : "30";

    // zvony ako bitmask
    int zvMask = p.length > 4 ? int.tryParse(p[4]) ?? 0 : 0;
    for (int i = 0; i < 5; i++) {
      zvony[i] = (zvMask & (1 << i)) != 0;
    }

    den = p.length > 5 ? int.tryParse(p[5]) ?? 1 : 1;
    mesiac = p.length > 6 ? int.tryParse(p[6]) ?? 1 : 1;

    setState(() => isLoading = false);
  }

  // ======================
  // SAVE
  // ======================
  Future<void> saveData(bool? stav, {bool showSnack = false, bool showSavedMessage = false}) async {
    if (stav != null) {
      setState(() {
        aktivne = stav;
      });
    }

    String t1 = "${time1.hour.toString().padLeft(2, '0')}:${time1.minute.toString().padLeft(2, '0')}";
    String t2 = "${time2.hour.toString().padLeft(2, '0')}:${time2.minute.toString().padLeft(2, '0')}";

    String dlzka = dlzkaController.text.trim();
    if (dlzka.isEmpty) dlzka = "0";

    // zvony bitmask
    int zvMask = 0;
    for (int i = 0; i < 5; i++) {
      if (zvony[i]) zvMask |= (1 << i);
    }

    String data = "${aktivne ? 1 : 0},$t1,$t2,$dlzka,$zvMask,$den,$mesiac";

    bool success = await api.setZvonyString(0, 77, data);

    if (mounted && success) {
      if (showSnack) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(showSavedMessage ? "Data boli uložené" : (aktivne ? "Zapnuté" : "Vypnuté"))));
      }

      if (widget.onDataChanged != null) {
        widget.onDataChanged!(data);
      }
    }
  }

  // ======================
  // PICKERS
  // ======================
  Future<void> pickTime(bool first) async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: first ? time1 : time2);

    if (t != null) {
      setState(() {
        if (first)
          time1 = t;
        else
          time2 = t;
      });
    }
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    DateTime initial = DateTime(now.year, mesiac, den);

    if (initial.isBefore(now)) initial = now;

    DateTime? d = await showDatePicker(context: context, initialDate: initial, firstDate: now, lastDate: DateTime(now.year + 5));

    if (d != null)
      setState(() {
        den = d.day;
        mesiac = d.month;
      });
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zvonenie zosnulému"),
        actions: [IconButton(icon: const Icon(Icons.save), tooltip: "Uložiť nastavenia", onPressed: () => saveData(null, showSnack: true, showSavedMessage: true))],
      ),
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
                child: _controlButton(
                  text: "Zapnúť",
                  color: Colors.green,
                  isActive: aktivne, // ak je aktivne = true, Zapnúť je farebné
                  onTap: () => saveData(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _controlButton(
                  text: "Vypnúť",
                  color: style.MainAppStyle().mainColor,
                  isActive: !aktivne, // ak je aktivne = false, Vypnúť je farebné
                  onTap: () => saveData(false),
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
