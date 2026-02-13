import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../include/style.dart' as style;

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String pageTitle; // Pridáme parameter pre názov stránky

  const MainAppBar({Key? key, required this.pageTitle}) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(200.0);
}

class _MainAppBarState extends State<MainAppBar> {
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    // Načítame používateľské údaje raz pri inicializácii widgetu
    _userNameFuture = UserData.getCurrentUser("name");
  }

  // Funkcia pre logout s presmerovaním na prihlasovaciu stránku
  void _logout(BuildContext context) async {
    await UserData.logout(); // Vymaže používateľské údaje
    Navigator.of(context).popAndPushNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(200.0),
      child: ClipRRect(
        child: Container(
          height: 140,
          // color: style.MainAppStyle().mainColor,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 75, left: 10, right: 10, bottom: 0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: widget.pageTitle == 'Home'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              FutureBuilder<String>(
                                future: _userNameFuture, // Použijeme uložený Future
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator(); // Zobrazí sa počas načítania
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    return Row(
                                      children: [
                                        Text(
                                          'Ahoj, ',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                                        ),
                                        Text(
                                          '${snapshot.data}',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Text('Prihlásený: N/A'); // Ak nie je žiadny používateľ
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.black.withOpacity(0.90)),
                          onPressed: () => _logout(context),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        widget.pageTitle != 'Nastavenia' && widget.pageTitle != 'Informácie' && widget.pageTitle != 'Oskenuj QR'
                            ? Padding(
                                padding: const EdgeInsets.only(left: 0.0, top: 0.0, right: 20),
                                child: TextButton(
                                  style: TextButton.styleFrom(backgroundColor: Color.fromRGBO(0, 0, 0, 0.05), maximumSize: Size(40.0, 40.0), minimumSize: Size(40.0, 40.0)),
                                  child: Icon(size: 23.0, Icons.arrow_back, color: Color.fromRGBO(0, 0, 0, 0.5)),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              )
                            : SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            widget.pageTitle, // Zobrazí názov stránky
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
