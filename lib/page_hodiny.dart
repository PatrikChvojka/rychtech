import 'package:flutter/material.dart';
import 'package:rychtech/include/appbar.dart';

class PageHodiny extends StatefulWidget {
  const PageHodiny({super.key});

  @override
  State<PageHodiny> createState() => _PageHodinyState();
}

class _PageHodinyState extends State<PageHodiny> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(pageTitle: 'Home'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(children: [Text("data")]),
      ),
    );
  }
}
