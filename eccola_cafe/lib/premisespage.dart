import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart' as constants;
import 'homepage.dart';

class PremisesPage extends StatefulWidget {
  @override
  _PremisesPageState createState() => _PremisesPageState();
}

class _PremisesPageState extends State<PremisesPage> {
  List<DropdownMenuItem<dynamic>> premiseslist;
  Future getpremises;
  String dropdownvalue;
  String selectedpremises;

  @override
  void initState() {
    // TODO: implement initState
    premiseslist = [];
    selectedpremises = null;
    getpremises = _getpremises();
    dropdownvalue = "0";
    super.initState();
  }

  Future _getpremises() async {
    try {
      http.Response response = await http.get(
          "https://test.eccolacafedelivery.com/api/v1/takeway/get_premises",
          headers: {"Content-Type": "application/json"});

      print("https://test.eccolacafedelivery.com/api/v1/takeway/get_premises");

      print(response.body);

      var dataUser = json.decode(response.body);

      /* if ("error") {
        return [];
      }*/

      return dataUser;
    } on Exception catch (e) {
      print(e.toString());
      return [];
    }

    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        top: false,
        child: Scaffold(
          body: Container(
            child: FutureBuilder(
                future: getpremises,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: Container(
                        child: Text("Loading"),
                      ),
                    );
                  } else {
                    premiseslist = [];
                    premiseslist.add(DropdownMenuItem(
                      child: Text("--Select Premises--"),
                      value: "0",
                      onTap: () {
                        setState(() {
                          selectedpremises = null;
                        });
                      },
                    ));
                    for (var item in snapshot.data) {
                      premiseslist.add(DropdownMenuItem(
                        child: Text(" " + item[0]),
                        value: item[1],
                        onTap: () {
                          setState(() {
                            selectedpremises = item[1];
                          });
                        },
                      ));
                    }
                    return Center(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton(
                                value: dropdownvalue,
                                items: premiseslist,
                                onChanged: (val) {
                                  setState(() {
                                    dropdownvalue = val;
                                  });
                                }),
                            Container(
                              width: 300,
                              child: RaisedButton(
                                color: constants.buttoncolor,
                                onPressed: () {
                                  if (dropdownvalue != "0") {
                                    print("Premises is " + dropdownvalue);

                                    constants.premise_id = dropdownvalue;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                (HomePage())));
                                  } else {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content:
                                            Text("Please select Premises")));
                                  }
                                },
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                      color: constants.buttontextcolor,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }
}
