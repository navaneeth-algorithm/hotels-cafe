import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'constants.dart';
import 'dart:async';

import 'cartview.dart';

import 'subitemspage.dart';
import 'homepage.dart';
import 'package:http/http.dart' as http;

class CurrentOrderPageContainer extends StatefulWidget {
  Map otpdata, orderdata;
  CurrentOrderPageContainer({Key key, this.orderdata, this.otpdata})
      : super(key: key);
  @override
  _CurrentOrderPageContainerState createState() =>
      _CurrentOrderPageContainerState();
}

class CurrentOrders {
  String orderid;
  String totalamount;
  String phonesessionid;
  String postcode;
  String ordernumber;
  List currentorderitems; //{id,name,qt,amount}

  CurrentOrders(
      {this.orderid,
      this.totalamount,
      this.phonesessionid,
      this.postcode,
      this.ordernumber,
      this.currentorderitems});
}

CurrentOrders currentOrders;

class MenuItems {
  String name;
  String imageurl;
  String menuid;
  bool selected;
  MenuItems({this.name, this.imageurl, this.menuid, this.selected});
}

List<MenuItems> menuitems;

class _CurrentOrderPageContainerState extends State<CurrentOrderPageContainer> {
  int _selectedIndex = null;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _notes;
  TextEditingController _address1;
  TextEditingController _address2;
  TextEditingController _name;
  TextEditingController _postalcode;

  Future validateOtp() async {
    //print(o1);

    Map data = {
      "premise_id": this.widget.otpdata["premise_id"],
      "o1": this.widget.otpdata["o1"],
      "o2": this.widget.otpdata["o2"],
      "o3": this.widget.otpdata["o3"],
      "postcode": this.widget.otpdata["postcode"],
      "o4": this.widget.otpdata["o4"],
      "phone_session_id": this.widget.otpdata["phone_session_id"]
    };

    var body = json.encode(data);

    http.Response response = await http.post(
        "http://18.130.82.119:3013/api/v1/takeway/validate_otp",
        headers: {"Content-Type": "application/json"},
        body: body);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;
    return dataUser;

    //print("Active order list");
    //[name, order_type, delivery_charge, order_history_list, current_order, current_order, menu_items, status]
    // print(dataUser["current_order"]);
    // print("XXXXXXXXX");

    if (dataUser["status"] != 401) {
      //print(dataUser);

      if (dataUser["current_order"].length != 0) {}
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(dataUser["message"])));

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (route) => false);
    }
  }

  bool requiredAddress;
  bool menuitemselect;

  Future _fetchdata() {
    print("IN ACTIVE ORDER PAGE");

    List tempitems = [];
    tablerows = [];
    totalCurrentAmount =
        this.widget.orderdata["current_order"]["total"].toString();
    print(this.widget.orderdata["current_order"]["total"]);

    for (var item in this.widget.orderdata["current_order"]["items"]) {
      setState(() {
        tempitems.add({"id": ""});
        currentOrders = new CurrentOrders(currentorderitems: tempitems);
      });
    }

    validateOtp();
  }

  selectitemvalidateOtp() async {
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

    var body = json.encode(data);

    http.Response response = await http.post(
        "http://18.130.82.119:3013/api/v1/takeway/validate_otp",
        headers: {"Content-Type": "application/json"},
        body: body);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;

    print("Respose  got for validate_otp");
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    print(dataUser);

    if (dataUser["status"] != 401) {
      //print(dataUser);

      menuitems.removeWhere((element) => true);

      for (var item in dataUser["menu_items"]) {
        var menumodal = new MenuItems(
            name: item["name"],
            imageurl: item["image_url"],
            menuid: item["id"].toString());
        setState(() {
          menuitems.add(menumodal);
        });
      }

      //Scaffold.of(context).showSnackBar(SnackBar(content: Text("got otp")));
    } else {}

    /*Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => (OrderPage())));*/
  }

  void _selectitemfetchdata() {
    print("IN SELECT ITEM PAGE");
    menuitems = [];
    for (var item in this.widget.orderdata["menu_items"]) {
      menuitems.add(new MenuItems(name: "Loading", menuid: "1", imageurl: ""));
    }
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    print(this.widget.orderdata);

    print("AGAIN fetch data");
    selectitemvalidateOtp();
  }

  void removeItem(orderId, itemid) async {
    Map data = {
      "premise_id": this.widget.otpdata["premise_id"],
      "item_id": itemid,
      "order_id": orderId,
      "phone_session_id": this.widget.otpdata["phone_session_id"]
    };

    var body = json.encode(data);
    // print(data);

    http.Response response = await http.delete(
      "http://18.130.82.119:3013/api/v1/takeway/remove_item?premise_id=" +
          this.widget.otpdata["premise_id"].toString() +
          "&&item_id=" +
          itemid.toString() +
          "&&order_id=" +
          orderId.toString() +
          "&&phone_session_id=" +
          this.widget.otpdata["phone_session_id"].toString(),
      headers: {"Content-Type": "application/json"},
    );
    //print(response.body);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;

    if (mapData["status"] == 200) {
      _fetchdata();
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(mapData["message"])));
    }
    // print(mapData);
  }

  String totalCurrentAmount;

  List<DataRow> tablerows;

  void getsubItems(menuid) async {
    Map data = {
      "premise_id": this.widget.otpdata["premise_id"],
      "menu_category_id": menuid.toString(),
      "order_id": this.widget.orderdata["current_order"]["id"],
      "phone_session_id": this.widget.otpdata["phone_session_id"]
    };

    print(data);

    var body = json.encode(data);

    print("http://18.130.82.119:3013/api/v1/takeway/menu_items?premise_id=" +
        this.widget.otpdata["premise_id"] +
        "&&phone_session_id=" +
        this.widget.otpdata["phone_session_id"] +
        "&&menu_category_id=" +
        menuid.toString() +
        "&&order_id=" +
        this.widget.orderdata["current_order"]["id"].toString());

    http.Response response = await http.get(
      "http://18.130.82.119:3013/api/v1/takeway/menu_items?premise_id=" +
          this.widget.otpdata["premise_id"] +
          "&&phone_session_id=" +
          this.widget.otpdata["phone_session_id"] +
          "&&menu_category_id=" +
          menuid.toString() +
          "&&order_id=" +
          this.widget.orderdata["current_order"]["id"].toString(),
      headers: {"Content-Type": "application/json"},
    );
    print(response.body);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SubItemsPageContainer(
                  orderdata: this.widget.orderdata,
                  otpdata: this.widget.otpdata,
                  subitemdata: mapData,
                  menuid: menuid,
                )));
    // print(mapData);
  }

  Widget _buildItemsList() {
    Widget itemCards;
    List items = menuitems;
    if (items.length > 0) {
      itemCards = GridView.count(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        crossAxisCount: 3,
        children: List.generate(items.length, (index) {
          return GestureDetector(
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Image(
                        fit: BoxFit.cover,
                        image: items[index].imageurl == ""
                            ? AssetImage("images/loading.jpg")
                            : NetworkImage(items[index].imageurl),
                      ),
                    ),
                    Expanded(child: Text(items[index].name))
                  ],
                ),
              ),
            ),
            onTap: () {
              getsubItems(items[index].menuid.toString());
            },
          );
        }),
      );
    } else {
      itemCards = Container(
        child: Text('No items'),
      );
    }
    return itemCards;
  }

  @override
  void initState() {
    // TODO: implement initState

    //print("Length og ordr histro" + currentOrders.length.toString());

    _notes = new TextEditingController();
    menuitemselect = false;

    _address1 = new TextEditingController();
    _address2 = new TextEditingController();
    _name = new TextEditingController();
    _postalcode = new TextEditingController();

    setState(() {
      requiredAddress =
          this.widget.orderdata["order_type"] == "Collection" ? false : true;
      _postalcode.text = this.widget.orderdata["order_type"] == "Collection"
          ? ""
          : this.widget.orderdata["current_order"]["postcode"];
    });

    var urlwebapp =
        "http://18.130.82.119:3013/en/takeway/enter?utf8=%E2%9C%93&premise_id=114921&phone_session_id=" +
            this.widget.otpdata["phone_session_id"] +
            "&&o1=" +
            this.widget.otpdata["o1"] +
            "&&o2=" +
            this.widget.otpdata["o2"] +
            "&o3=" +
            this.widget.otpdata["o3"] +
            "&o4=" +
            this.widget.otpdata["o4"] +
            "&commit=Enter";
    print(urlwebapp);

    //

    _fetchdata();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Form(
      key: _formKey,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "Current Orders",
              style: TextStyle(color: textcolor, fontSize: 14),
            ),
            SizedBox(
              height: 10,
            ),
            this.widget.orderdata["order_type"] == "Delivery"
                ? Text(
                    this.widget.orderdata["currency"] +
                        " " +
                        this
                            .widget
                            .orderdata["delivery_charge"]
                            .toStringAsFixed(2) +
                        "  Delivery charge for all delivery orders ",
                    style: TextStyle(
                        color: textcolor,
                        backgroundColor:
                            this.widget.orderdata["delivery_charge"] >= 2
                                ? Colors.yellow
                                : Colors.transparent),
                  )
                : Container(),
            FutureBuilder(
                future: validateOtp(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  // print(snapshot.data);
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Column(
                      children: [
                        Container(
                          child: Icon(
                            Icons.wifi,
                            color: iconcolor,
                            size: 18,
                          ),
                        ),
                        Container(
                            child: Text(
                          "Loading",
                          style: TextStyle(color: textcolor, fontSize: 18),
                        ))
                      ],
                    );
                  } else {
                    // print(snapshot.data);
                    currentOrders = new CurrentOrders(
                        orderid:
                            snapshot.data["current_order"]["id"].toString(),
                        ordernumber: snapshot.data["current_order"]["order_no"]
                            .toString(),
                        totalamount:
                            snapshot.data["current_order"]["total"].toString(),
                        postcode: snapshot.data["current_order"]["postcode"]
                            .toString(),
                        phonesessionid: snapshot.data["current_order"]
                                ["phone_session_id"]
                            .toString(),
                        currentorderitems: snapshot.data["current_order"]
                            ["items"]);

                    //  print(mapData);
                    if (currentOrders.currentorderitems.length != 0) {
                      totalCurrentAmount =
                          double.parse(currentOrders.totalamount)
                              .toStringAsFixed(2);
                    } else {
                      totalCurrentAmount = currentOrders.totalamount;
                    }

                    print("HERE SNAPSHOT");
                    print(this.widget.orderdata["current_order"]["postcode"]);

                    // return Container();
                    menuitems = [];

                    for (var item in snapshot.data["menu_items"]) {
                      menuitems.add(new MenuItems(
                          menuid: item["id"].toString(),
                          imageurl: item["image_url"],
                          name: item["name"],
                          selected: false));
                    }

                    print(menuitems.length);
                    return Container(
                      height: this.widget.orderdata["order_type"] == "Delivery"
                          ? height - 250
                          : height - 200,
                      child: Column(
                        children: [
                          Text(
                            "Menu Items",
                            style: TextStyle(color: textcolor),
                          ),
                          Expanded(
                            child: GridView.count(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              crossAxisCount: 3,
                              children:
                                  List.generate(menuitems.length, (index) {
                                return GestureDetector(
                                  child: Card(
                                    color: menuitems[index].selected
                                        ? Colors.green
                                        : Colors.white,
                                    child: Container(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          menuitems[index].imageurl != null
                                              ? Expanded(
                                                  child: Container(
                                                      height: 150,
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: menuitems[
                                                                              index]
                                                                          .imageurl ==
                                                                      ""
                                                                  ? AssetImage(
                                                                      "images/loading.jpg")
                                                                  : NetworkImage(
                                                                      menuitems[
                                                                              index]
                                                                          .imageurl))),
                                                      child: Text("")),
                                                )
                                              : Container(),
                                          Expanded(
                                            child: Text(
                                              menuitems[index].name,
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  onLongPress: () {
                                    setState(() {
                                      menuitems[index].selected = true;
                                    });
                                  },
                                  onTap: () {
                                    setState(() {
                                      menuitems[index].selected = true;
                                    });
                                    print("SELECTED ");
                                    print(menuitems[index].selected);
                                    getsubItems(
                                        menuitems[index].menuid.toString());
                                  },
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),
          ]),
          SizedBox(
            height: 20,
          ),
          FutureBuilder(
              future: validateOtp(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                } else {
                  print(snapshot.data);
                  if (snapshot.data["current_order"]["items"].length == 0) {
                    return Container();
                  } else {
                    return Container(
                      width: width,
                      height: 50,
                      child: Card(
                        color: Colors.green[50],
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Text(
                                    "Total Item " +
                                        snapshot.data["current_order"]["items"]
                                            .length
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      "Total amount " +
                                          snapshot.data["currency"] +
                                          " " +
                                          snapshot.data["current_order"]
                                                  ["total"]
                                              .toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CartViewPageContainer(
                                              orderdata: this.widget.orderdata,
                                              otpdata: this.widget.otpdata,
                                            )));
                                //validateOtp();
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.shopping_cart),
                                  Text("View Cart",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                    );
                  }
                }
              }),
        ],
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  String text;
  double fontsize;
  FontWeight fontweight;
  Color color;
  CustomText({this.text, this.fontsize, this.fontweight, this.color});
  @override
  Widget build(BuildContext context) {
    return Text(this.text,
        style: TextStyle(
            color: this.color,
            fontSize: this.fontsize,
            fontWeight: this.fontweight));
  }
}
