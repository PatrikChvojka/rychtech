import 'package:flutter/material.dart';
import 'package:rychtech/include/appbar.dart';

class PageSetting extends StatefulWidget {
  const PageSetting({super.key});

  @override
  State<PageSetting> createState() => _PageHodinyState();
}

class _PageHodinyState extends State<PageSetting> {
  bool isLeto = true;
  bool automatickeZvonenia = false;
  bool odbijanieCasu = false;

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
                        setState(() {
                          isLeto = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: isLeto ? Colors.blue : Colors.grey.shade300),
                      child: Text("Leto", style: TextStyle(color: isLeto ? Colors.white : Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLeto = false;
                        });
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
                  setState(() {
                    automatickeZvonenia = val;
                  });
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
                  setState(() {
                    odbijanieCasu = val;
                  });
                },
                title: Text(odbijanieCasu ? "Zapnuté" : "Vypnuté"),
              ),
            ),

            const SizedBox(height: 15),

            _buildSectionCard(
              title: "Prázdne",
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text("Na doplnenie v budúcnosti", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            _buildSectionCard(
              title: "Prázdne",
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text("Na doplnenie v budúcnosti", style: TextStyle(color: Colors.grey)),
                ),
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
