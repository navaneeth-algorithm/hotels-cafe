import 'package:flutter/material.dart';
import 'dart:convert';
import 'constants.dart';
import 'dart:async';
import 'main.dart';

import 'package:http/http.dart' as http;

class ActiveOrderPageContainer extends StatefulWidget {
  Map otpdata, orderdata;
  ActiveOrderPageContainer({Key key, this.orderdata, this.otpdata})
      : super(key: key);
  @override
  _ActiveOrderPageContainerState createState() =>
      _ActiveOrderPageContainerState();
}

class ActiveOrders {
  String orderid;
  String totalamount;
  String orderdate;
  List orderitems;

  ActiveOrders({
    this.orderdate,
    this.orderid,
    this.orderitems,
    this.totalamount,
  });
}

class CurrentOrders {
  String orderid;
  String totalamount;
  String phonesessionid;
  String postcode;
  String ordernumber;
  List items;

  CurrentOrders({
    this.orderid,
    this.totalamount,
  });
}

List<ActiveOrders> activeOrders;
List<CurrentOrders> currentorders;

class _ActiveOrderPageContainerState extends State<ActiveOrderPageContainer> {
  int _selectedIndex = null;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  validateOtp() async {
    //print(o1);

    Map data = {
      "premise_id": this.widget.otpdata["premise_id"],
      "o1": this.widget.otpdata["o1"],
      "postcode": this.widget.otpdata["postcode"],
      "o2": this.widget.otpdata["o2"],
      "o3": this.widget.otpdata["o3"],
      "o4": this.widget.otpdata["o4"],
      "phone_session_id": this.widget.otpdata["phone_session_id"]
    };
    print(data);

    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/validate_otp",
        headers: {"Content-Type": "application/json"},
        body: body);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;

    print("XXXXXXXXX");
    for (var item in dataUser["current_order"]["items"]) {
      print(item);
      print("\n");
    }

    if (dataUser["status"] != 401) {
      //print(dataUser);

      if (dataUser["active_order_list"].length != 0) {
        activeOrders.removeWhere((element) => true);
        for (var item in dataUser["active_order_list"]) {
          setState(() {
            activeOrders.add(new ActiveOrders(
                orderid: item["id"].toString(),
                orderdate: item["ordered_date"].toString(),
                totalamount: item["amount"].toStringAsFixed(2),
                orderitems: item["items"]));
          });
        }
      }
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(dataUser["message"])));

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (route) => false);
    }
  }

  void _fetchdata() {
    print("IN ACTIVE ORDER PAGE");

    validateOtp();
  }

  @override
  void initState() {
    // TODO: implement initState

    activeOrders = [];

    for (var item in this.widget.orderdata["active_order_list"]) {
      setState(() {
        activeOrders
            .add(new ActiveOrders(orderid: "", orderdate: "", orderitems: []));
      });
    }

    //print("Length og ordr histro" + activeOrders.length.toString());

    _fetchdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Active Orders",
          style: TextStyle(color: textcolor, fontSize: 14),
        ),
        activeOrders.length == 0
            ? Center(
                child: Container(
                child: Text("Empty"),
              ))
            : Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: activeOrders.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext contex, int index) {
                      return Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          boxShadow: [
                            //Right Shadow
                            BoxShadow(
                                offset: Offset(1, 0),
                                color: Colors.black,
                                blurRadius: 0.1,
                                spreadRadius: 0),
                            //Bottom shadow
                            BoxShadow(
                                offset: Offset(0, 1),
                                color: Colors.black,
                                blurRadius: 0.8,
                                spreadRadius: 0),
                            /*Top shadow
                      BoxShadow(
                          offset: Offset(-1, -1),
                          color: Colors.black,
                          blurRadius: 0.1,
                          spreadRadius: 0.5),*/
                          ],
                          color: boxbackgroundcolor,
                        ),
                        width: width,
                        child: activeOrders[index].orderid == ""
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.network_wifi,
                                    color: iconcolor,
                                  ),
                                  Text(
                                    "Loading....",
                                    style: TextStyle(color: textcolor),
                                  )
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Amount: " +
                                            this.widget.orderdata["currency"] +
                                            " " +
                                            activeOrders[index].totalamount,
                                        style: TextStyle(
                                            color: textcolor, fontSize: 14),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Order Number: " +
                                            activeOrders[index].orderid,
                                        style: TextStyle(
                                            color: textcolor, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Order date: " +
                                            activeOrders[index].orderdate,
                                        style: TextStyle(
                                            color: textcolor, fontSize: 14),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Items:",
                                        style: TextStyle(color: textcolor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                      children: activeOrders[index]
                                          .orderitems
                                          .map((data) {
                                    return Text("" + data["name"].toString());
                                  }).toList()),
                                ],
                              ),
                      );
                    }),
              ),
      ],
    );
  }
}
