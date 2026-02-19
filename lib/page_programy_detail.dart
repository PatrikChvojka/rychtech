import 'package:flutter/material.dart';
import '../include/drupal_api.dart';

class PageProgramDetail extends StatefulWidget {
  final int uid;
  final int code;
  final String dataString;

  // callback späť do hlavnej stránky (voliteľný)
  final Function(String)? onDataChanged;

  const PageProgramDetail({super.key, required this.uid, required this.code, required this.dataString, this.onDataChanged});

  @override
  State<PageProgramDetail> createState() => _PageProgramDetailState();
}

class _PageProgramDetailState extends State<PageProgramDetail> {
  final DrupalAPI api = DrupalAPI();

  late List<String> parts;

  // čas
  TimeOfDay time = const TimeOfDay(hour: 0, minute: 0);

  // TextEditingController-y
  late TextEditingController dlzkaController;
  late TextEditingController denController;
  late TextEditingController mesiacController;

  bool isLoading = true; // nový flag

  // zvony 1-5
  List<bool> zvony = List.filled(5, false);

  // perióda: 0 = týždeň, 1 = rok
  int perioda = 0;

  // dni v týždni
  List<bool> dni = List.filled(7, false);

  int den = 1;
  int mesiac = 1;

  @override
  void initState() {
    super.initState();
    loadDataFromServer();
  }

  Future<void> loadDataFromServer() async {
    String result = await api.getZvonyString(widget.uid, widget.code);

    List<String> tmp = result.split(',');

    // default ak chýbajú dáta
    if (tmp.isEmpty || tmp.join(',') == "0,00:00,0,0,0,0,0,0") {
      tmp = ["1", "00:00", "0", "0", "0", "0", "1", "1"];
    }

    parts = tmp;

    // čas
    List<String> t = parts[1].split(':');
    int h = int.tryParse(t[0]) ?? 0;
    int m = int.tryParse(t[1]) ?? 0;
    time = TimeOfDay(hour: h, minute: m);

    // dĺžka
    dlzkaController = TextEditingController(text: parts[2]);

    // zvony
    String zv = parts[3];
    for (int i = 0; i < 5; i++) {
      zvony[i] = zv.contains("${i + 1}");
    }

    // dni
    int dniMask = int.tryParse(parts[4]) ?? 0;
    for (int i = 0; i < 7; i++) {
      dni[i] = (dniMask & (1 << i)) != 0;
    }

    perioda = int.tryParse(parts[5]) ?? 0;
    den = int.tryParse(parts[6]) ?? 1;
    mesiac = int.tryParse(parts[7]) ?? 1;

    denController = TextEditingController(text: den.toString());
    mesiacController = TextEditingController(text: mesiac.toString());

    setState(() {
      isLoading = false; // načítanie hotové
    });
  }

  Future<void> pickDate() async {
    // Ošetrenie den a mesiac
    int safeDen = den.clamp(1, 28); // najbezpečnejšie: max 28
    int safeMesiac = mesiac.clamp(1, 12);

    DateTime initialDate = DateTime(DateTime.now().year, safeMesiac, safeDen);

    DateTime? picked = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(DateTime.now().year, 1, 1), lastDate: DateTime(DateTime.now().year, 12, 31));

    if (picked != null) {
      setState(() {
        den = picked.day;
        mesiac = picked.month;
        denController.text = den.toString();
        mesiacController.text = mesiac.toString();
      });
    }
  }

  // =====================
  // Uloženie dát
  // =====================
  Future<void> saveData() async {
    String timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    String dlzka = dlzkaController.text.trim();
    if (dlzka.isEmpty) dlzka = "0";

    // zvony
    String zvStr = "";
    for (int i = 0; i < 5; i++) {
      if (zvony[i]) zvStr += "${i + 1}";
    }
    if (zvStr.isEmpty) zvStr = "0";

    // dni bitmask
    int dniMask = 0;
    for (int i = 0; i < 7; i++) {
      if (dni[i]) dniMask |= (1 << i);
    }

    String newString = "${parts[0]},$timeStr,$dlzka,$zvStr,$dniMask,$perioda,$den,$mesiac";

    bool success = await api.setZvonyString(widget.uid, widget.code, newString);

    if (success && mounted) {
      // callback späť do hlavnej stránky, ak je
      if (widget.onDataChanged != null) widget.onDataChanged!(newString);

      Navigator.pop(context, newString);
    }
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nastavenie programu"),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: saveData)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ČAS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // jemné šedé pozadie
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(title: const Text("Čas zvonenia"), subtitle: Text("${time.format(context)}"), trailing: const Icon(Icons.access_time), onTap: pickTime),
          ),

          const SizedBox(height: 15),

          // DLŽKA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 246, 225, 225), // jemné šedé pozadie
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: dlzkaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Dĺžka zvonenia (sekundy)"),
            ),
          ),

          const SizedBox(height: 10),

          for (int i = 0; i < 5; i++) SwitchListTile(title: Text("Zvon ${i + 1}"), value: zvony[i], onChanged: (v) => setState(() => zvony[i] = v)),

          const Divider(),

          const Text("Perióda", style: TextStyle(fontSize: 18)),
          Row(
            children: [
              ChoiceChip(label: const Text("Týždeň"), selected: perioda == 0, onSelected: (_) => setState(() => perioda = 0)),
              const SizedBox(width: 10),
              ChoiceChip(label: const Text("Rok"), selected: perioda == 1, onSelected: (_) => setState(() => perioda = 1)),
            ],
          ),

          const SizedBox(height: 15),

          if (perioda == 0) buildDni(),
          if (perioda == 1) buildDatum(),
        ],
      ),
    );
  }

  // =====================
  // Pomocné UI
  // =====================
  Future<void> pickTime() async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: time);
    if (t != null) setState(() => time = t);
  }

  Widget buildDni() {
    List<String> nazvy = ["Po", "Ut", "St", "Št", "Pi", "So", "Ne"];
    return Wrap(
      spacing: 8,
      children: List.generate(7, (i) {
        return FilterChip(label: Text(nazvy[i]), selected: dni[i], onSelected: (v) => setState(() => dni[i] = v));
      }),
    );
  }

  Widget buildDatum() {
    return InkWell(
      onTap: pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
        child: Text("Dátum: ${den.toString().padLeft(2, '0')}.${mesiac.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
