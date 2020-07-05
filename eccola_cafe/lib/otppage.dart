import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'loadingscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'constants.dart';

import 'package:http/http.dart' as http;
import 'orderpage.dart';

class OtpPage extends StatelessWidget {
  String postalcode;
  String phonenumber;
  String imageurl;
  OtpPage({this.postalcode, this.phonenumber, this.imageurl});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: backgroundcolor,
      body: OtpContainer(
          phonenumber: this.phonenumber,
          postalcode: this.postalcode,
          imageurl: this.imageurl),
    ));
  }
}

class OtpContainer extends StatefulWidget {
  String postalcode;
  String phonenumber;
  String imageurl;
  OtpContainer({Key key, this.phonenumber, this.postalcode, this.imageurl})
      : super(key: key);
  @override
  _OtpContainerState createState() => _OtpContainerState();
}

class _OtpContainerState extends State<OtpContainer> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<ErrorAnimationType> errorController;
  TextEditingController otp;
  String currentText = "";
  String _phone_session_id = "";
  String o1 = "", o2 = "", o3 = "", o4 = "";
  bool _hasotp;
  String recievedOtp = "";
  bool hasError;
  bool isLoading;

  String usersession;

  Future<bool> setUserId(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString("usersession", value);
  }

  Future _fetchdata() async {
    _hasotp = false;
    var postcode = this.widget.postalcode.toString() == ""
        ? null
        : this.widget.postalcode.toString();
    print("Value of Postal Code before calling send_otp ");
    print(postcode);
    Map data = {
      "premise_id": premise_id,
      "postcode": postcode,
      "phone_number": this.widget.phonenumber.toString(),
    };
    print("Data posted to send_otp");
    print(data);
    // Map data = {"email": "hanson@gmail.com", "password": "123"};

    //submitDialog(context);

    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/send_otp",
        headers: {"Content-Type": "application/json"},
        body: body);

    var dataUser = json.decode(response.body);
    print("Response got for send_otp");
    print(dataUser);
    if (dataUser["success"]) {
      // print(dataUser);
      _phone_session_id = dataUser["phone_session_id"].toString();
      recievedOtp = dataUser["otp_code"].toString();

      usersession = premise_id.toString() +
          "*" +
          _phone_session_id.toString() +
          "*" +
          recievedOtp;
      // print("Recieved otp " + recievedOtp);

      setState(() {
        _hasotp = true;
      });
      //Scaffold.of(context).showSnackBar(SnackBar(content: Text("got otp")));
    } else {
      _hasotp = false;
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text("resend otp")));
    }

    // Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    isLoading = false;
    _fetchdata();

    errorController = StreamController<ErrorAnimationType>();
    otp = new TextEditingController();
    super.initState();
  }

  validateOtp() async {
    var postcode = this.widget.postalcode.toString() == ""
        ? null
        : this.widget.postalcode.toString();
    setState(() {
      isLoading = true;
    });
    var otplist = otp.text.toString().split("");
    o1 = otplist[0].toString();
    o2 = otplist[1].toString();
    o3 = otplist[2].toString();
    o4 = otplist[3].toString();
    //print(o1);

    Map data = {
      "premise_id": premise_id,
      "postcode": postcode,
      "o1": o1,
      "o2": o2,
      "o3": o3,
      "o4": o4,
      "phone_session_id": _phone_session_id
    };
    print(data);
    // Map data = {"email": "hanson@gmail.com", "password": "123"};

    //submitDialog(context, msg: "Validating OTP");

    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/validate_otp",
        headers: {"Content-Type": "application/json"},
        body: body);
    //await Navigator.pop(context);
    setState(() {
      isLoading = false;
    });

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;

    print("Respose  got for validate_otp");
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    print(dataUser["menu_items"].toString());

    if (dataUser["status"] != 401) {
      setUserId(usersession);
      //print(dataUser);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => (OrderPage(
                    otpdata: data,
                    orderpagedata: dataUser,
                  ))));

      //Scaffold.of(context).showSnackBar(SnackBar(content: Text("got otp")));
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("OTP is invalid")));
      setState(() {
        otp.clear();
      });
    }

    /*Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => (OrderPage())));*/
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Center(
        child: SingleChildScrollView(
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
                          image: NetworkImage("" + this.widget.imageurl)),
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Text("")),
              SizedBox(
                height: 50,
              ),
              Text(
                "Enter the 4 digit PIN sent to your mobile via SMS",
                textAlign: TextAlign.center,
                style: TextStyle(color: textcolor, fontSize: 16),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: width - 80,
                child: PinCodeTextField(
                  validator: (val) {
                    if (val.length == 4) {
                      return null;
                    } else {
                      return "Cannot be empty";
                    }
                  },
                  onSubmitted: (val) {},
                  textStyle: TextStyle(color: textcolor, fontSize: 24),
                  length: 4,
                  obsecureText: false,
                  textInputType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                  animationType: AnimationType.none,
                  textInputAction: TextInputAction.next,
                  pinTheme: PinTheme(
                      disabledColor: textcolor,
                      inactiveColor: textcolor,
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      selectedColor: textcolor,
                      activeColor: textcolor),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  errorAnimationController: errorController,
                  controller: otp,
                  onCompleted: (v) {
                    print("Completed ");
                    if (recievedOtp != v.toString()) {}
                  },
                  onChanged: (value) {
                    //   print("otp " + otp.text);
                    // print("on change" + value);
                    setState(() {
                      currentText = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    print("Allowing to paste");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              isLoading
                  ? Text("Validating OTP",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textcolor, fontSize: 16))
                  : Container(
                      width: 300,
                      child: RaisedButton(
                        color: buttoncolor,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            validateOtp();
                          }
                        },
                        child: Text(
                          "Enter",
                          style:
                              TextStyle(color: buttontextcolor, fontSize: 18),
                        ),
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Haven't received otp yet? ",
                    style: TextStyle(color: Color(0xff7D8CA1)),
                  ),
                  GestureDetector(
                    onTap: () {
                      //  _formKey.currentState.validate();
                      setState(() {
                        otp.clear();
                      });
                      errorController.add(ErrorAnimationType.shake);
                      //print("otp is " + _otp.text);
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text("OTP resent")));
                      _fetchdata();

                      // Triggering error shake animation
                    },
                    child: Text(
                      "Resend",
                      style: TextStyle(color: Color(0xff39DAF7)),
                    ),
                  ),
                ],
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
    ));
  }
}
