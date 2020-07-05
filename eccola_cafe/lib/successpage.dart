import 'package:flutter/material.dart';
import 'dart:convert';
import 'constants.dart';
import 'main.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class SuccessPageContainer extends StatefulWidget {
  String msg;

  SuccessPageContainer({this.msg, Key key}) : super(key: key);
  @override
  _SuccessPageContainerState createState() => _SuccessPageContainerState();
}

class _SuccessPageContainerState extends State<SuccessPageContainer> {
  String msg;

  getSuccessPage() async {
    //print(o1);

    /*ap data = {
      "order_id": this.widget.orderid,
      "premise_id": this.widget.otpdata["premise_id"],
      "phone_session_id": this.widget.otpdata["phone_session_id"]
    };
*/
    //var body = json.encode(data);

    /* http.Response response = await http.get(
      "https://test.eccolacafedelivery.com/api/v1/takeway/payment_page_details?order_id=" +
          this.widget.orderid.toString() +
          "&&premise_id=" +
          this.widget.otpdata["premise_id"],
      headers: {"Content-Type": "application/json"},
    );

    // var dataUser = json.decode(response.body);
    //Map mapData = dataUser;
    setState(() {
      //  previewData = mapData;
    });
    //print(previewData);*/

    // print("Respose  got for validate_otp");
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    //print(response.body);
    //ackAlert(context, "Payment", "Successful");

    /* Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()),
                    (route) => false);*/

    // if (dataUser["status"] != 401) {
    //print(dataUser);

    //Scaffold.of(context).showSnackBar(SnackBar(content: Text("got otp")));
    //  } else {}

    /*Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => (OrderPage())));*/
  }

  @override
  void initState() {
    // TODO: implement initState
    msg = "";
    super.initState();
  }

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return false; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Color(0xff304059),
            appBar: AppBar(
              title: Text("Success"),
              centerTitle: true,
              backgroundColor: Color(0xff8B80E6),
            ),
            body: Center(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Text(
                      "" + this.widget.msg,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  IconButton(
                      iconSize: 40,
                      color: Colors.white,
                      icon: Icon(Icons.home),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (BuildContext context) => HomePage()),
                            (route) => false);
                      }),
                  Container(
                    child: Text(
                      "HOME",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
