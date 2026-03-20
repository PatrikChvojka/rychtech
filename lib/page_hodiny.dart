import 'dart:async';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:rychtech/include/style.dart' as style;
import 'package:rychtech/models/user_data.dart';
import '../include/drupal_api.dart';

class PageHodiny extends StatefulWidget {
  const PageHodiny({super.key});

  @override
  State<PageHodiny> createState() => _PageHodinyState();
}

class _PageHodinyState extends State<PageHodiny> {
  String systemState = "OK";
  TimeOfDay clockTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? editedTime;

  final DrupalAPI api = DrupalAPI();

  int uid = 0;

  bool loading = false;

  bool waitingForState = false;
  String? expectedState;

  Timer? statusTimer;

  int pickerHour = 12;
  int pickerMinute = 0;

  // ================= INIT =================

  Future<void> initData() async {
    String uidStr = await UserData.getCurrentUser('uid');
    uid = int.tryParse(uidStr) ?? 0;

    _startPolling();
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    super.dispose();
  }

  // ================= HELPERS =================

  bool _isSameTime(TimeOfDay a, TimeOfDay b) {
    return a.hour == b.hour && a.minute == b.minute;
  }

  String _formatTime(TimeOfDay t) {
    int hour = t.hour % 12;
    if (hour == 0) hour = 12;

    final minute = t.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  // ================= POLLING =================

  void _startPolling() {
    statusTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadFromApi());

    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    if (uid == 0) return;

    try {
      // ---- stav ----
      final stateRes = await api.getZvonyString(uid, 74);

      // ---- čas ----
      final timeRes = await api.getZvonyString(uid, 75);

      final stateStr = stateRes.trim(); // "1" / "2"
      final timeStr = timeRes.trim(); // "12:50"

      // prevod stavu na text

      String newState = "OK";

      if (stateStr == "2") {
        newState = "STOJ";
      } else {
        newState = "OK";
      }

      // parsovanie času

      final t = timeStr.split(":");

      if (t.length < 2) return;

      final h = int.tryParse(t[0]) ?? 0;
      final m = int.tryParse(t[1]) ?? 0;

      setState(() {
        systemState = newState;

        clockTime = TimeOfDay(hour: h, minute: m);

        // keď ide CHOD → zruš edit
        if (systemState != "STOJ") {
          editedTime = null;
        }

        // ===== kontrola čakania =====

        if (waitingForState) {
          // čakali sme STOJ

          if (expectedState == "2" && systemState == "STOJ") {
            loading = false;
            waitingForState = false;
            expectedState = null;
          }

          // čakali sme CHOD

          if (expectedState == "1" && systemState != "STOJ") {
            loading = false;
            waitingForState = false;
            expectedState = null;
          }
        }
      });
    } catch (e) {
      print("loadFromApi error: $e");
    }
  }

  // ================= API SEND =================

  Future<void> _sendState(String state) async {
    setState(() {
      loading = true;
      waitingForState = true;
      expectedState = state;
    });

    try {
      await api.setZvonyString(uid, 80, state);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendTimeAndStart() async {
    if (editedTime == null) return;

    setState(() {
      loading = true;
      waitingForState = true;
      expectedState = "1";
    });

    final t = editedTime!;

    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');

    final time = "$h:$m";

    try {
      await api.setZvonyString(uid, 81, time);

      editedTime = null;
    } catch (e) {
      print(e);
    }
  }

  // ================= TIME PICKER =================

  Future<void> _pickTime() async {
    pickerHour = editedTime?.hourOfPeriod ?? (clockTime.hourOfPeriod == 0 ? 12 : clockTime.hourOfPeriod);

    pickerMinute = editedTime?.minute ?? clockTime.minute;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Vyber hodiny"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NumberPicker(
                    minValue: 1,
                    maxValue: 12,
                    value: pickerHour,
                    onChanged: (val) => setDialogState(() {
                      pickerHour = val;
                    }),
                  ),

                  const Text(" : "),

                  NumberPicker(
                    minValue: 0,
                    maxValue: 59,
                    value: pickerMinute,
                    zeroPad: true,
                    onChanged: (val) => setDialogState(() {
                      pickerMinute = val;
                    }),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Zrušiť")),

            TextButton(
              onPressed: () {
                setState(() {
                  editedTime = TimeOfDay(hour: pickerHour % 12, minute: pickerMinute);
                });

                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ================= UI =================

  Widget _controlButton({required String text, required Color color, required bool isActive, required VoidCallback onTap}) {
    final opacity = isActive ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
            border: Border.all(color: isActive ? color : Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final isStop = systemState == "STOJ";

    return Scaffold(
      appBar: AppBar(title: const Text("Hodiny")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    title: const Text("Stav systému"),
                    subtitle: Text(systemState, style: const TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  child: ListTile(
                    title: const Text("Čas na hodinách"),
                    subtitle: Text(isStop ? _formatTime(editedTime ?? clockTime) : _formatTime(clockTime), style: const TextStyle(fontSize: 28)),
                    trailing: isStop ? IconButton(icon: const Icon(Icons.edit), onPressed: _pickTime) : null,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: _controlButton(
                        text: "CHOD",
                        color: Colors.green,
                        isActive: systemState != "STOJ",
                        onTap: () async {
                          if (systemState == "STOJ") {
                            if (editedTime != null && !_isSameTime(editedTime!, clockTime)) {
                              await _sendTimeAndStart();
                            } else {
                              await _sendState("1");
                            }
                          } else {
                            await _sendState("1");
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _controlButton(
                        text: "STOP",
                        color: style.MainAppStyle().mainColor,
                        isActive: systemState == "STOJ",
                        onTap: () async {
                          await _sendState("2");
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          if (loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 4)),
              ),
            ),
        ],
      ),
    );
  }
}
