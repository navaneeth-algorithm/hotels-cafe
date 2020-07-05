import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'phonenumberpage.dart';

import 'dart:convert';
import 'constants.dart';
import 'orderpage.dart';

import 'package:http/http.dart' as http;

class OnDeliveryPage extends StatelessWidget {
  String companyName = "";
  bool validsession;
  OnDeliveryPage({this.companyName, this.validsession});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          /* appBar: AppBar(
        title: Text(""),
        backgroundColor: Color(0xff8B80E6),
        centerTitle: true,
      ),*/
          backgroundColor: backgroundcolor,
          body: OnDeliveryContainer(
            companyName: this.companyName,
            validsession: validsession,
          ),
        ));
  }
}

class OnDeliveryContainer extends StatefulWidget {
  String companyName;
  bool validsession;
  OnDeliveryContainer({Key key, this.companyName, this.validsession})
      : super(key: key);
  @override
  _OnDeliveryContainerState createState() => _OnDeliveryContainerState();
}

class _OnDeliveryContainerState extends State<OnDeliveryContainer> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  TextEditingController _postcode = new TextEditingController();
  void _checkPostalCode() async {
    String postcode = _postcode.text;
    setState(() {
      isLoading = true;
    });

    Map data = {"premise_id": premise_id, "postcode": postcode};
    // Map data = {"email": "hanson@gmail.com", "password": "123"};

    // submitDialog(context);

    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/validate_postcode",
        headers: {"Content-Type": "application/json"},
        body: body);
    //await Navigator.pop(context);

    var dataUser = json.decode(response.body);
    print("Response for validate_postcode");
    print(dataUser);

    if (dataUser["proceed"]) {
      print(dataUser);

      if (this.widget.validsession) {
        validateOtp();
      } else {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => (PhoneNumberPage(
                      postalcode: postcode,
                    ))));
      }
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(dataUser["message"])));
    }
  }

  bool validsession;
  String sessionid;

  validateOtp({ordertype = 1}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var usersession = prefs.getString('usersession');
    sessionid = usersession;
    var otp = sessionid.toString().split("*")[2];
    String phonesessionid = sessionid.toString().split("*")[1];
    // print(postcode);
    var postcodeotp = ordertype == 1 ? _postcode.text : null;
    String o1, o2, o3, o4;

    /* if (ordertype == 1 && postcode == null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => OnDeliveryPage(
                    companyName: homePageData.companyname,
                  )));
    } else {*/
    var otplist = otp.toString().split("");
    o1 = otplist[0].toString();
    o2 = otplist[1].toString();
    o3 = otplist[2].toString();
    o4 = otplist[3].toString();
    //print(o1);

    Map data = {
      "premise_id": premise_id,
      "postcode": postcodeotp,
      "o1": o1,
      "o2": o2,
      "o3": o3,
      "o4": o4,
      "phone_session_id": phonesessionid
    };
    // print(data);
    // Map data = {"email": "hanson@gmail.com", "password": "123"};

    //submitDialog(context, msg: "Validating OTP");

    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/validate_otp",
        headers: {"Content-Type": "application/json"},
        body: body);
    //await Navigator.pop(context);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;
    setState(() {
      isLoading = false;
    });

    // print("Respose  got for validate_otp");
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    //print(dataUser["menu_items"].toString());

    if (dataUser["status"] != 401) {
      //setUserId(usersession);
      //print(dataUser);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => (OrderPage(
                    otpdata: data,
                    orderpagedata: dataUser,
                  ))));

      /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => (CreditDebitCard())));*/

      //Scaffold.of(context).showSnackBar(SnackBar(content: Text("got otp")));
    } else {
      // Scaffold.of(context)
      //  .showSnackBar(SnackBar(content: Text("OTP is invalid")));

    }
    //}
    /*Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => (OrderPage())));*/
  }

  @override
  void initState() {
    // TODO: implement initState
    isLoading = false;

    super.initState();
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
            height: height - 200,
            decoration: BoxDecoration(color: backgroundcolor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "" + this.widget.companyName,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textcolor),
                ),
                SizedBox(
                  height: 60,
                ),
                Text(
                  "We need to check if we deliver to where you are",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textcolor, fontSize: 16),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: width - 80,
                  child: TextFormField(
                    controller: _postcode,
                    validator: (val) {
                      if (val.isEmpty) {
                        return "Post Code is required";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: textcolor),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff7D8CA1))),
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Color(0xff7D8CA1),
                      ),
                      hintText: "Enter Postal Code",
                      hintStyle: TextStyle(color: Color(0xff7D8CA1)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                isLoading
                    ? Text(
                        "Checking.....",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textcolor, fontSize: 16),
                      )
                    : Container(
                        width: 300,
                        child: RaisedButton(
                          color: buttoncolor,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _checkPostalCode();
                            }
                          },
                          child: Text(
                            "CHECK",
                            style:
                                TextStyle(color: buttontextcolor, fontSize: 18),
                          ),
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "",
                      style: TextStyle(color: textcolor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
