import 'package:flutter/material.dart';
import 'package:rychtech/include/appbar.dart';
import 'package:rychtech/models/user_data.dart';
import '../include/drupal_api.dart';

class PageZvony extends StatefulWidget {
  const PageZvony({super.key});

  @override
  State<PageZvony> createState() => _PageZvonyState();
}

class _PageZvonyState extends State<PageZvony> with WidgetsBindingObserver {
  int mask = 0;
  List<bool> zvony = List.filled(5, false);

  int uid = 0;
  final code = 54;

  final DrupalAPI api = DrupalAPI();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initData();
  }

  Future<void> initData() async {
    String uidStr = await UserData.getCurrentUser('uid');
    uid = int.tryParse(uidStr) ?? 0;

    // always start disabled (ignore server state)
    setState(() {
      mask = 0;
      zvony = List.filled(5, false);
    });

    // aktivita
    await api.setZvonyString(uid, 32, "2");
  }

  Future<void> loadZvonyString() async {
    String result = await api.getZvonyString(uid, code);

    int m = int.tryParse(result) ?? 0;

    List<bool> tmp = List.filled(5, false);

    for (int i = 0; i < 5; i++) {
      tmp[i] = (m & (1 << i)) != 0;
    }

    setState(() {
      mask = m;
      zvony = tmp;
    });
  }

  Future<void> updateZvon(int index, bool stav) async {
    setState(() {
      zvony[index] = stav;
    });

    int newMask = 0;

    for (int i = 0; i < 5; i++) {
      if (zvony[i]) {
        newMask |= (1 << i);
      }
    }

    bool success = await api.setZvonyString(uid, code, newMask.toString());

    if (success) {
      setState(() {
        mask = newMask;
      });
    } else {
      print("Chyba pri ukladaní");
    }
  }

  Future<void> _disableAllZvony() async {
    if (mounted) {
      setState(() {
        mask = 0;
        zvony = List.filled(5, false);
      });
    }

    bool success = await api.setZvonyString(uid, code, '0');
    if (!success) {
      print('Chyba pri vypnutí zvonov pri opustení stránky');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Do not call async API updates from dispose, we handle disable on pop in WillPopScope.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _disableAllZvony();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disableAllZvony();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Zvony"), backgroundColor: const Color.fromRGBO(150, 0, 0, 1)),
        backgroundColor: const Color.fromRGBO(230, 237, 253, 1),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(children: [_buildZvonButton("Zvon 1", 0), _buildZvonButton("Zvon 2", 1), _buildZvonButton("Zvon 3", 2), _buildZvonButton("Zvon 4", 3), _buildZvonButton("Zvon 5", 4)]),
        ),
      ),
    );
  }

  Widget _buildZvonButton(String title, int index) {
    bool isActive = zvony[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: () {
          updateZvon(index, !isActive);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: isActive ? const Color.fromRGBO(237, 187, 0, 1) : const Color.fromRGBO(96, 96, 96, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, color: isActive ? Colors.white : Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
