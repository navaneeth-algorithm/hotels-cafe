import 'package:flutter/material.dart';

import 'constants.dart';

import 'premisespage.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Scaffold(
        backgroundColor: backgroundcolor, //Color(0xff304059),
        body: PremisesPage(),
      )),
    );
  }
}
