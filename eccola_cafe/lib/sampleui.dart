import 'package:flutter/material.dart';

class SampleExtension extends StatefulWidget {
  @override
  _SampleExtensionState createState() => _SampleExtensionState();
}

class _SampleExtensionState extends State<SampleExtension> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
        top: false,
        child: Scaffold(
            body: Container(
          height: height,
          child: ListView(
            children: [],
          ),
        )));
  }
}
