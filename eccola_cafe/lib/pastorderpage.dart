import 'package:flutter/material.dart';
import 'dart:convert';
import 'constants.dart';
import 'main.dart';
import 'dart:async';
import 'orderpage.dart';
import 'package:http/http.dart' as http;

class PastOrderPageContainer extends StatefulWidget {
  Map otpdata, orderdata;
  TabController tabcontroller;
  PastOrderPageContainer(
      {Key key, this.orderdata, this.otpdata, this.tabcontroller})
      : super(key: key);
  @override
  _PastOrderPageContainerState createState() => _PastOrderPageContainerState();
}

class OrderHistory {
  String orderid;
  String totalamount;
  String orderdate;
  List orderitems;

  OrderHistory(
      {this.orderdate, this.orderid, this.orderitems, this.totalamount});
}

List<OrderHistory> orderHistory;

class _PastOrderPageContainerState extends State<PastOrderPageContainer> {
  int _selectedIndex = null;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  orderagain(orderid) async {
    //print(o1);

    Map data = {
      "premise_id": this.widget.otpdata["premise_id"],
      "phone_session_id": this.widget.otpdata["phone_session_id"],
      "order_id": orderid.toString()
    };

    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/repeat",
        headers: {"Content-Type": "application/json"},
        body: body);

    print(response.body);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;

    if (dataUser["message"] == "success") {
      //print(dataUser);
      validateOtp();

      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Item ordered again")));
      this.widget.tabcontroller.index = 1;

      /*  Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => OrderPage(
                    orderpagedata: this.widget.orderdata,
                    otpdata: this.widget.otpdata,
                  )),
          (route) => false);*/
    } else {
      /* Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(dataUser["message"])));*/

      /* Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (route) => false);*/
    }

    /*Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => (OrderPage())));*/
  }

  validateOtp() async {
    //print(o1);

    Map data = {
      "premise_id": this.widget.otpdata["premise_id"],
      "o1": this.widget.otpdata["o1"],
      "o2": this.widget.otpdata["o2"],
      "o3": this.widget.otpdata["o3"],
      "o4": this.widget.otpdata["o4"],
      "postcode": this.widget.otpdata["postcode"],
      "phone_session_id": this.widget.otpdata["phone_session_id"]
    };

    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/validate_otp",
        headers: {"Content-Type": "application/json"},
        body: body);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;

    print("Respose  got for validate_otp");
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    print(dataUser["order_history_list"]);

    if (dataUser["status"] != 401) {
      //print(dataUser);

      if (dataUser["order_history_list"].length != 0) {
        orderHistory.removeWhere((element) => true);
        for (var item in dataUser["order_history_list"]) {
          setState(() {
            orderHistory.add(new OrderHistory(
                orderid: item["id"].toString(),
                orderdate: item["ordered_date"].toString(),
                totalamount: item["amount"].toStringAsFixed(2),
                orderitems: item["items"]));
          });
        }
      }

      //Scaffold.of(context).showSnackBar(SnackBar(content: Text("got otp")));
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(dataUser["message"])));

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (route) => false);
    }

    /*Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => (OrderPage())));*/
  }

  void _fetchdata() {
    print("IN PAST ORDER PAGE");
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    // print(this.widget.orderdata);

    print("AGAIN fetch data");
    validateOtp();
  }

  @override
  void initState() {
    // TODO: implement initState

    orderHistory = [];

    for (var item in this.widget.orderdata["order_history_list"]) {
      setState(() {
        orderHistory
            .add(new OrderHistory(orderid: "", orderdate: "", orderitems: []));
      });
    }

    print("Length og ordr histro" + orderHistory.length.toString());

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
          "ORDER HISTORY",
          style: TextStyle(color: textcolor, fontSize: 14),
        ),
        orderHistory.length == 0
            ? Center(
                child: Container(
                child: Text("Empty"),
              ))
            : Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orderHistory.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext contex, int index) {
                      return Container(
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.all(10),
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
                        child: orderHistory[index].orderid == ""
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
                                        "Amount: ",
                                        style: TextStyle(
                                            color: textcolor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        " " +
                                            this.widget.orderdata["currency"] +
                                            " " +
                                            orderHistory[index].totalamount,
                                        style: TextStyle(
                                            color: textcolor, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Order date: ",
                                        style: TextStyle(
                                            color: textcolor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "" + orderHistory[index].orderdate,
                                        style: TextStyle(
                                            color: textcolor, fontSize: 14),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      IconButton(
                                        tooltip: "Order again",
                                        icon: Icon(Icons.repeat),
                                        onPressed: () {
                                          orderagain(
                                              orderHistory[index].orderid);
                                        },
                                        color: Colors.redAccent,
                                      )
                                    ],
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
                                    height: 20,
                                  ),
                                  Column(
                                      children: orderHistory[index]
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
