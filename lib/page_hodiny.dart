import 'dart:async';
import 'package:flutter/material.dart';

class PageHodiny extends StatefulWidget {
  const PageHodiny({super.key});

  @override
  State<PageHodiny> createState() => _PageHodinyState();
}

class _PageHodinyState extends State<PageHodiny> {
  // ====== STAVY ======
  String systemState = "OK"; // OK | STOJ (ilustračne)
  TimeOfDay clockTime = const TimeOfDay(hour: 12, minute: 0);

  TimeOfDay? editedTime;

  bool loading = false;

  Timer? statusTimer;
  Timer? timeTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    timeTimer?.cancel();
    super.dispose();
  }

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
            style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  // ====== POLLING ======
  void _startPolling() {
    // Stav systému každých 5s
    statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadSystemState();
    });

    // Čas každú minútu
    timeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (systemState != "STOJ") {
        _loadClockTime();
      }
    });

    // prvé načítanie
    _loadSystemState();
    _loadClockTime();
  }

  // ====== ILUSTRAČNÉ API ======
  Future<void> _loadSystemState() async {
    // simulácia API
    await Future.delayed(const Duration(milliseconds: 300));

    // tu bude neskôr API
    // napr.: systemState = await Api.getState();

    setState(() {});
  }

  Future<void> _loadClockTime() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // simulácia – zatiaľ lokálny čas
    final now = DateTime.now();
    clockTime = TimeOfDay(hour: now.hour, minute: now.minute);

    setState(() {});
  }

  Future<void> _sendState(String state) async {
    setState(() => loading = true);

    // simulácia API
    await Future.delayed(const Duration(seconds: 1));

    systemState = state;

    setState(() => loading = false);
  }

  Future<void> _sendTimeAndStart() async {
    if (editedTime == null) return;

    setState(() => loading = true);

    // simulácia odoslania času
    await Future.delayed(const Duration(seconds: 1));

    // tu bude API:
    // await Api.setClock(editedTime);

    systemState = "OK";
    editedTime = null;

    setState(() => loading = false);
  }

  // ====== UI ======
  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: editedTime ?? clockTime);

    if (picked != null) {
      setState(() {
        editedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

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
                // ===== STAV SYSTEMU =====
                Card(
                  child: ListTile(
                    title: const Text("Stav systému"),
                    subtitle: Text(systemState, style: const TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== CAS NA HODINACH =====
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
                          if (systemState == "STOJ" && editedTime != null) {
                            await _sendTimeAndStart();
                          } else {
                            await _sendState("OK");
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _controlButton(
                        text: "STOP",
                        color: Colors.red,
                        isActive: systemState == "STOJ",
                        onTap: () async {
                          await _sendState("STOJ");
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          // ===== FULLSCREEN LOADER =====
          if (loading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
