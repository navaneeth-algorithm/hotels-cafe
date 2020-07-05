import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'otppage.dart';
import 'loadingscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'constants.dart';

import 'package:http/http.dart' as http;

class PhoneNumberPage extends StatelessWidget {
  String postalcode;

  PhoneNumberPage({this.postalcode});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: backgroundcolor,
      body: PhoneNumberContainer(postalcode: this.postalcode),
    ));
  }
}

class PhoneNumberContainer extends StatefulWidget {
  String postalcode;
  PhoneNumberContainer({Key key, this.postalcode}) : super(key: key);
  @override
  _PhoneNumberContainerState createState() => _PhoneNumberContainerState();
}

class _PhoneNumberContainerState extends State<PhoneNumberContainer> {
  final _formKey = GlobalKey<FormState>();

  Future _fetchdata() async {
    Map data = {
      "premise_id": premise_id,
    };
    // Map data = {"email": "hanson@gmail.com", "password": "123"};

    //submitDialog(context);

    var body = json.encode(data);

    http.Response response = await http.get(
        "https://test.eccolacafedelivery.com/api/v1/takeway/get_otp?premise_id=" +
            premise_id.toString(),
        headers: {"Content-Type": "application/json"});

    var dataUser = json.decode(response.body);

    if (!dataUser.containsKey("error")) {
      //print(dataUser);
      return dataUser;
    }

    // Navigator.pop(context);
  }

  bool checkSocialmediaUrl(homepagedata) {
    return homepagedata["twitter_url"] != "" ||
            homepagedata["linked_in_url"] != "" ||
            homepagedata["linked_in_url"] != ""
        ? true
        : false;
  }

  _launchURL(url) async {
    //const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ackAlert(context, "ERROR", "Could not launch $url");
      //throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    TextEditingController _phonenumber = new TextEditingController();
    return Center(
      child: FutureBuilder(
        future: _fetchdata(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(backgroundColor: Colors.blue),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textcolor),
                ),
              ],
            );
          } else {
            print(snapshot.data.toString());

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  width: width,
                  decoration: BoxDecoration(color: backgroundcolor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          height: height - 450,
                          width: width - 50,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      "" + snapshot.data["image_url"])),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: Text("")),
                      SizedBox(
                        height: 50,
                      ),
                      Html(
                        data: snapshot.data["top_content"].toString(),
                        style: {
                          "p": Style(
                              textAlign: TextAlign.center, color: textcolor),
                          "h6": Style(
                              textAlign: TextAlign.center, color: textcolor),
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: width - 80,
                        child: TextFormField(
                          controller: _phonenumber,
                          validator: (val) {
                            String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                            RegExp regExp = new RegExp(patttern);
                            if (val.length == 0) {
                              return 'Please enter mobile number';
                            } else if (!regExp.hasMatch(val)) {
                              return 'Please enter valid mobile number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: textcolor),
                          decoration: InputDecoration(
                            counterText: "",
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff7D8CA1))),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Color(0xff7D8CA1),
                            ),
                            hintText: "Enter Phone Number",
                            hintStyle: TextStyle(color: Color(0xff7D8CA1)),
                          ),
                          maxLength: 11,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 300,
                        child: RaisedButton(
                          color: buttoncolor,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              print("Postal Code is " + this.widget.postalcode);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          (OtpPage(
                                            postalcode: this.widget.postalcode,
                                            phonenumber: _phonenumber.text,
                                            imageurl:
                                                snapshot.data["image_url"],
                                          ))));
                            }
                          },
                          child: Text(
                            "Get 4 Digit Code",
                            style:
                                TextStyle(color: buttontextcolor, fontSize: 18),
                          ),
                        ),
                      ),
                      checkSocialmediaUrl(snapshot.data)
                          ? Column(
                              children: [
                                Text(
                                  "Reach us via Social media",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade300),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    snapshot.data["fb_url"] != ""
                                        ? IconButton(
                                            icon: Image.asset("images/fb.png"),
                                            onPressed: () {
                                              _launchURL(
                                                  snapshot.data["fb_url"]);
                                            })
                                        : Container(),
                                    snapshot.data["linked_in_url"] != ""
                                        ? IconButton(
                                            icon: Image.asset(
                                                "images/linked_in.png"),
                                            onPressed: () {
                                              _launchURL(snapshot
                                                  .data["linked_in_url"]);
                                            })
                                        : Container(),
                                    snapshot.data["twitter_url"] != ""
                                        ? IconButton(
                                            icon: Image.asset(
                                                "images/twitter.png"),
                                            onPressed: () {
                                              _launchURL(
                                                  snapshot.data["twitter_url"]);
                                            })
                                        : Container(),
                                  ],
                                )
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      Html(
                        data: snapshot.data["bottom_content"].toString(),
                        style: {
                          "p": Style(
                              textAlign: TextAlign.center,
                              color: Colors.grey.shade300),
                          "h6": Style(
                              textAlign: TextAlign.center,
                              color: Colors.grey.shade300),
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "",
                            style: TextStyle(color: Color(0xff7D8CA1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
