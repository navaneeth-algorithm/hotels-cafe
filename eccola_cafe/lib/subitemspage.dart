import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'dart:convert';
import 'constants.dart';
import 'orderpage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class SubItemsPageContainer extends StatefulWidget {
  Map otpdata, orderdata, subitemdata;
  String menuid;
  SubItemsPageContainer(
      {Key key, this.orderdata, this.otpdata, this.subitemdata, this.menuid})
      : super(key: key);
  @override
  _SubItemsPageContainerState createState() => _SubItemsPageContainerState();
}

class SubItems {
  String id;
  String menuid;
  String type;
  String name;
  bool showcustomisablelink;
  String amount;
  bool comboitem;

  TextEditingController notes;

  bool isizeselected;
  bool isvariantselected;
  bool istypeselected;
  bool isextrasselected;

  List selectedvariants;
  List selectedtypes;
  List selectedsizes;
  List selectedextras;

  List variants;
  List sizes;
  List types;
  List extras;

  bool customisablelinkselected;
  List subitems;
  int quantity;
  bool subitemselected;

  Color sizeselectecolor;
  Color variantselectedcolor;
  Color extrasselectedcolor;
  Color typeselectedcolor;

  String dialogselecteddata;
  String outsidedata;

  String totaldialogamount;
  String totaloutsideamount;

  SubItems(
      {this.id,
      this.name,
      this.menuid,
      this.selectedextras,
      this.type,
      this.isextrasselected,
      this.isizeselected,
      this.istypeselected,
      this.notes,
      this.isvariantselected,
      this.selectedsizes,
      this.variants,
      this.extras,
      this.types,
      this.sizes,
      this.selectedtypes,
      this.selectedvariants,
      this.quantity,
      this.showcustomisablelink,
      this.amount,
      this.subitemselected,
      this.customisablelinkselected,
      this.comboitem,
      this.extrasselectedcolor,
      this.sizeselectecolor,
      this.typeselectedcolor,
      this.variantselectedcolor,
      this.dialogselecteddata,
      this.outsidedata,
      this.totaldialogamount,
      this.totaloutsideamount,
      this.subitems});
}

List<SubItems> menuitems;

class _SubItemsPageContainerState extends State<SubItemsPageContainer> {
  String totalprice, itemCount, quantity;
  var itemcount = 0;

  // final List<Map<String, dynamic>> items;

  List<SubItems> items = [
    new SubItems(name: "Loading", id: "1", amount: "0.0"),
    new SubItems(name: "Loading", id: "1", amount: "0.0"),
    new SubItems(name: "Loading", id: "1", amount: "0.0"),
    /*{
      'title': 'Appam',
      'imageUrl': 'images/linked_in.png',
      'itemprice': 50,
      'itemcount': 0,
    },
    {
      'title': 'Bonda',
      'imageUrl': 'images/twitter.png',
      'itemprice': 25,
      'itemcount': 0,
    },
    {
      'title': 'Dosa',
      'imageUrl': 'images/fb.png',
      'itemprice': 40,
      'itemcount': 0,
    },
    {
      'title': 'Idly',
      'imageUrl': 'images/linked_in.png',
      'itemprice': 30,
      'itemcount': 0,
    },
    {
      'title': 'Onion Dosa',
      'imageUrl': 'images/fb.png',
      'itemprice': 50,
      'itemcount': 0,
    },
    {
      'title': 'Parotta',
      'imageUrl': 'images/linked_in.png',
      'itemprice': 50,
      'itemcount': 0,
    },
    {
      'title': 'Puri',
      'imageUrl': 'images/twitter.png',
      'itemprice': 40,
      'itemcount': 0,
    },
    {
      'title': 'Upma',
      'imageUrl': 'images/twitter.png',
      'itemprice': 30,
      'itemcount': 0,
    },
    {
      'title': 'Uttapam',
      'imageUrl': 'images/linked_in.png',
      'itemprice': 40,
      'itemcount': 0,
    },
    {
      'title': 'Vada',
      'imageUrl': 'images/fb.png',
      'itemprice': 30,
      'itemcount': 0,
    },*/
  ];

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
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: items[index].name == ""
                          ? Image(
                              image: AssetImage("images/loading.jpg"),
                              height: 80.0,
                              width: 100.0,
                            )
                          : Text(""),
                    ),
                    Expanded(child: Text(items[index].name))
                  ],
                ),
              ),
            ),
            onTap: () {
              // getsubItems(items[index].menuid.toString());
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

  Widget _buildOrderListBar() {
    return Container(
      color: Color.fromRGBO(37, 134, 16, 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            itemcount > 0 ? itemcount.toString() : '',
            style: TextStyle(color: Colors.white),
          ),
          FlatButton(
            child: Text(
              'Checkout',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            onPressed: () {},
          ),
          Text(
            'Rs. $totalprice',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      margin: const EdgeInsets.all(10.0),
      child: TextFormField(
        decoration: InputDecoration(
            hintText: 'Search for Item', icon: Icon(Icons.search)),
      ),
    );
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

    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/validate_otp",
        headers: {"Content-Type": "application/json"},
        body: body);

    var dataUser = json.decode(response.body);
    Map mapData = dataUser;

    //  print("Respose  got for validate_otp");
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    //  print(this.widget.subitemdata["menu_items"]);

    if (mapData["status"] != 401) {
      //print(dataUser);

      //Scaffold.of(context).showSnackBar(SnackBar(content: Text("got otp")));
    } else {}

    /*Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => (OrderPage())));*/
  }

  void _fetchdata() {
    // print("IN SELECT ITEM PAGE");
    menuitems = [];
    for (var item in this.widget.orderdata["menu_items"]) {
      menuitems.add(new SubItems(
          name: "Loading",
          menuid: this.widget.menuid,
          isextrasselected: false,
          isizeselected: false,
          istypeselected: false,
          isvariantselected: false,
          type: "",
          selectedextras: [],
          selectedsizes: [],
          totaldialogamount: "0.0",
          totaloutsideamount: "0.0",
          dialogselecteddata: "",
          outsidedata: "",
          selectedtypes: [],
          extrasselectedcolor: Colors.red,
          sizeselectecolor: Colors.red,
          variantselectedcolor: Colors.red,
          typeselectedcolor: Colors.red,
          notes: new TextEditingController(),
          variants: [],
          sizes: [],
          extras: [],
          types: [],
          selectedvariants: [],
          quantity: 0,
          id: "1",
          amount: "0.0",
          subitemselected: false,
          comboitem: false,
          customisablelinkselected: true));
    }
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    //  print(this.widget.orderdata);

    //print("AGAIN fetch data");

    menuitems.removeWhere((element) => true);

    for (var item in this.widget.subitemdata["menu_items"]) {
      var menumodal = new SubItems(
          name: item["name"],
          menuid: this.widget.menuid,
          quantity: 1,
          id: item["id"].toString(),
          isextrasselected: false,
          isizeselected: false,
          selectedextras: [],
          selectedsizes: [],
          selectedtypes: [],
          selectedvariants: [],
          notes: new TextEditingController(),
          variants: [],
          type: item["type"].toString(),
          sizes: [],
          extras: [],
          types: [],
          istypeselected: false,
          extrasselectedcolor: Colors.red,
          sizeselectecolor: Colors.red,
          variantselectedcolor: Colors.red,
          typeselectedcolor: Colors.red,
          isvariantselected: false,
          showcustomisablelink: item["show_customize_link"],
          dialogselecteddata: "",
          outsidedata: "",
          totaldialogamount: item["amount"],
          totaloutsideamount: item["amount"],
          amount: item["amount"],
          comboitem: item["combo_item"],
          customisablelinkselected: true,
          subitemselected: false,
          subitems: []);

      menuitems.add(menumodal);
    }
    //validateOtp();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Map<dynamic, SubItems> orderList;
  @override
  void initState() {
    // TODO: implement initState
    var urlwebapp =
        "https://test.eccolacafedelivery.com/en/takeway/enter?utf8=%E2%9C%93&premise_id=114921&phone_session_id=" +
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
    orderList = {};
    _fetchdata();

    super.initState();
  }

  orderProduct(Map<dynamic, SubItems> orderproductdata,
      {bool mainpage = false}) async {
    Map data;
    /*"selected_list"=>"911:1", 
    "items"=>[{"item_id"=>"911", 
    "selected_variants"=>"[1534, 1535]", "selected_types"=>"[826, 825]",
     "selected_sizes"=>"[260, 259]", 
    "selected_extras"=>"[1425, 1424]", "notes"=>"test notes", "qty"=>"1"}]
    */
    String selectedlist = "";
    List itemlist = [];
    Map<String, dynamic> itemdetails = {};

    orderproductdata.forEach((key, value) {
      print(value.id);
      print(value.quantity);
      selectedlist +=
          "" + value.id.toString() + ":" + value.quantity.toString() + ",";

      //variants
      print(value.subitems);
      List variants = [];

      List types = [];
      List sizes = [];
      List extras = [];
      String notes = "";
      String quantity = "";
      print(value.subitems);

      for (var variant in value.selectedvariants) {
        variants.add(variant["id"]);
      }
      for (var size in value.selectedsizes) {
        sizes.add(size["id"].toString());
      }
      for (var extra in value.selectedextras) {
        extras.add(extra["id"].toString());
      }
      for (var type in value.selectedtypes) {
        types.add(type["id"].toString());
      }
      notes = value.notes.text;
      quantity = value.quantity.toString();
      itemdetails = {
        "item_id": value.subitems[0]["item_id"],
        "selected_variants": variants,
        "selected_sizes": sizes,
        "selected_types": types,
        "selected_extras": extras,
        "notes": notes,
        "quantity": quantity
      };
      itemlist.add(itemdetails);
    });
    print("OTP DATA");
    print(this.widget.otpdata);

    data = {
      "selected_list": selectedlist,
      "items": itemlist,
      "order_id": this.widget.orderdata["current_order"]["id"],
      "phone_session_id": this.widget.otpdata["phone_session_id"],
      "premise_id": this.widget.otpdata["premise_id"],
    };
    print("ORDER DATA");
    print(data);
    print("RESPONSE");
    var body = json.encode(data);
    http.Response response = await http.post(
      "https://test.eccolacafedelivery.com/api/v1/takeway/add_item",
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    print(response.body);
    var dataUser = json.decode(response.body);
    // Map mapData = dataUser;
    print(dataUser);
    if (dataUser["current_order"] != null) {
      var count = 0;
      if (mainpage) {
        //Navigator.of(context).pop();
        /*Navigator.popUntil(context, (route) {
          return count++ == 1;
        });*/

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => OrderPage(
                      orderpagedata: this.widget.orderdata,
                      otpdata: this.widget.otpdata,
                    )),
            (route) => false);
      } else {
        //Navigator.pop(context);
      }
    }
  }

  Future getsubItems(SubItems menudata, index) async {
    Map data = {
      "premise_id": this.widget.otpdata["premise_id"],
      "menu_category_id": menudata.menuid,
      "order_id": this.widget.orderdata["current_order"]["id"],
      "phone_session_id": this.widget.otpdata["phone_session_id"],
      "item_id": menudata.id
    };

    //print(data);

    var body = json.encode(data);

    print(
        "https://test.eccolacafedelivery.com/api/v1/takeway/sub_items?premise_id=" +
            this.widget.otpdata["premise_id"] +
            "&&phone_session_id=" +
            this.widget.otpdata["phone_session_id"] +
            "&&menu_category_id=" +
            menudata.menuid +
            "&&order_id=" +
            this.widget.orderdata["current_order"]["id"].toString() +
            "&&item_id=" +
            menudata.id);

    http.Response response = await http.get(
      "https://test.eccolacafedelivery.com/api/v1/takeway/sub_items?premise_id=" +
          this.widget.otpdata["premise_id"] +
          "&&phone_session_id=" +
          this.widget.otpdata["phone_session_id"] +
          "&&menu_category_id=" +
          menudata.menuid +
          "&&order_id=" +
          this.widget.orderdata["current_order"]["id"].toString() +
          "&&item_id=" +
          menudata.id,
      headers: {"Content-Type": "application/json"},
    );
    // print(response.body);
    var dataUser = json.decode(response.body);
    // Map mapData = dataUser;
    print(dataUser["sub_items"]);

    setState(() {
      menuitems[index].subitems = dataUser["sub_items"];
      // print(menuitems[index].subitems[0]);
      menuitems[index].variants = menuitems[index].subitems[0]["variants"];
      menuitems[index].sizes = menuitems[index].subitems[0]["sizes"];
      menuitems[index].types = menuitems[index].subitems[0]["types"];
      menuitems[index].extras = menuitems[index].subitems[0]["extras"];
    });

    //var dataUser = json.decode(response.body);
    // Map mapData = dataUser;
    // print(mapData);
    return menuitems;
  }

  var getsubitemFuture;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: backgroundcolor,
        body: Column(
          children: <Widget>[
            //_buildOrderListBar(),
            //_buildSearchItem(),

            //Expanded(child: _buildItemsList()),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => Center(
                      child: RaisedButton(
                        onPressed: () {
                          if (orderList.length > 0) {
                            orderProduct(orderList, mainpage: true);
                          } else {
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text("Please select items")));
                          }
                        },
                        child: Text(
                          "Add to Order",
                          style: TextStyle(color: buttontextcolor),
                        ),
                        color: buttoncolor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30.0)),
                    child: IconButton(
                      color: Colors.white,
                      tooltip: "Close",
                      onPressed: () {
                        print(this.widget.otpdata);

                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                      iconSize: 19,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: menuitems.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
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
                        color: menuitems[index].subitemselected
                            ? Color(0xffffa73f)
                            : boxbackgroundcolor,
                      ),
                      width: width,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      "" + menuitems[index].name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    this.widget.orderdata["currency"] +
                                        " " +
                                        (double.parse(menuitems[index]
                                                .totaloutsideamount)
                                            .toStringAsFixed(2)),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 150,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    "" + menuitems[index].outsidedata,
                                    style: TextStyle(color: Colors.black),
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [],
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  menuitems[index].subitemselected
                                      ? Expanded(
                                          flex: 1,
                                          child: IconButton(
                                              color: Color(0xff1278fa),
                                              icon: Icon(Icons.check_box),
                                              onPressed: () {
                                                getsubItems(
                                                    menuitems[index], index);
                                                setState(() {
                                                  menuitems[index]
                                                          .subitemselected =
                                                      menuitems[index]
                                                              .subitemselected
                                                          ? false
                                                          : true;
                                                  orderList.remove(index);
                                                  print(
                                                      "After removing order list " +
                                                          orderList.toString());
                                                });
                                              }),
                                        )
                                      : Expanded(
                                          flex: 1,
                                          child: IconButton(
                                              icon: Icon(Icons
                                                  .check_box_outline_blank),
                                              onPressed: () {
                                                getsubItems(
                                                    menuitems[index], index);
                                                setState(() {
                                                  //  menuitems[index].quantity =
                                                  //    menuitems[index].quantity +
                                                  getsubItems(
                                                      menuitems[index], index);

                                                  orderList[index] =
                                                      menuitems[index];
                                                  print(
                                                      "After adding order list " +
                                                          orderList.toString());
                                                  menuitems[index]
                                                          .subitemselected =
                                                      menuitems[index]
                                                              .subitemselected
                                                          ? false
                                                          : true;
                                                });
                                              }),
                                        ),
                                  menuitems[index].customisablelinkselected
                                      ? Container(
                                          child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      /*  menuitems[index]
                                                              .quantity =
                                                          menuitems[index]
                                                                  .quantity +
                                                              1;*/
                                                      menuitems[index]
                                                              .subitemselected =
                                                          true;
                                                      orderList[index] =
                                                          menuitems[index];
                                                      //  print("After adding order list " +
                                                      //   orderList.toString());
                                                    });
                                                    getsubitemFuture =
                                                        getsubItems(
                                                            menuitems[index],
                                                            index);
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                              return AlertDialog(
                                                                content: Stack(
                                                                  overflow:
                                                                      Overflow
                                                                          .visible,
                                                                  children: <
                                                                      Widget>[
                                                                    Positioned(
                                                                      right:
                                                                          -40.0,
                                                                      top:
                                                                          -40.0,
                                                                      child:
                                                                          InkResponse(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child:
                                                                            CircleAvatar(
                                                                          child:
                                                                              Icon(Icons.close),
                                                                          backgroundColor:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          300,
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(padding: EdgeInsets.all(10)),
                                                                            RaisedButton(
                                                                              color: buttoncolor,
                                                                              onPressed: () {
                                                                                //  print("Orders are " +
                                                                                //      orderList
                                                                                //     .length
                                                                                //         .toString());
                                                                                //Navigator.of(context).pop();

                                                                                //orderProduct(orderList);
                                                                                //_fetchdata();
                                                                                List temp = [];
                                                                                // menuitems[index].dialogselecteddata = "";
                                                                                temp.add(menuitems[index].dialogselecteddata);
                                                                                temp.add(menuitems[index].totaldialogamount);
                                                                                print("TOTAL DATA DIALOG");
                                                                                print(temp);

                                                                                Navigator.of(context).pop(temp);
                                                                              },
                                                                              child: Text(
                                                                                "Select",
                                                                                style: TextStyle(color: buttontextcolor),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                                child: Text(
                                                                              "" + menuitems[index].name,
                                                                              style: TextStyle(color: Colors.black),
                                                                            )),
                                                                            FutureBuilder(
                                                                                future: getsubitemFuture,
                                                                                builder: (context, snapshot) {
                                                                                  if (snapshot.connectionState != ConnectionState.done) {
                                                                                    return Text("Loading");
                                                                                  } else {
                                                                                    return Container(
                                                                                      child: Text("" + (snapshot.data[index].subitems[0]["description"] != null ? snapshot.data[index].subitems[0]["description"] : "")),
                                                                                    );
                                                                                  }
                                                                                }),
                                                                            Container(
                                                                              margin: EdgeInsets.all(6),
                                                                              width: width - 40,
                                                                              child: TextFormField(
                                                                                validator: (val) {
                                                                                  if (val.isEmpty) {
                                                                                    return null;
                                                                                  } else {
                                                                                    return null;
                                                                                  }
                                                                                },
                                                                                controller: menuitems[index].notes,
                                                                                style: TextStyle(color: Colors.black),
                                                                                maxLines: 5,
                                                                                decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Enter Notes", hintStyle: TextStyle(color: Color(0xff3C5069))),
                                                                              ),
                                                                            ),
                                                                            FutureBuilder(
                                                                                future: getsubitemFuture,
                                                                                builder: (context, snapshot) {
                                                                                  if (snapshot.connectionState != ConnectionState.done) {
                                                                                    return Text("Loading");
                                                                                  } else {
                                                                                    List<dynamic> sizes = snapshot.data[index].sizes;
                                                                                    //  var sizemap = new Map.fromIterable(snapshot.data[index].sizes,key: ()=>)
                                                                                    return Column(
                                                                                      children: [
                                                                                        menuitems[index].sizes.length != 0
                                                                                            ? Container(
                                                                                                child: Text(
                                                                                                "Sizes ",
                                                                                                style: TextStyle(color: textcolor),
                                                                                              ))
                                                                                            : Container(),
                                                                                        Column(
                                                                                          children: sizes.map((size) {
                                                                                            return Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                    child: Checkbox(
                                                                                                        value: menuitems[index].selectedsizes.any((element) => element["id"] == size["id"]) || size["is_default"] ? true : false,
                                                                                                        onChanged: (val) {
                                                                                                          setState(() {
                                                                                                            bool alreadypresent = menuitems[index].selectedsizes.any((element) => element["id"] == size["id"]);
                                                                                                            if (!alreadypresent) {
                                                                                                              menuitems[index].selectedsizes.add(size);
                                                                                                              //menuitems[index].sizeselectecolor = Colors.green;
                                                                                                            } else {
                                                                                                              menuitems[index].selectedsizes.removeWhere((element) => element["id"] == size["id"]);
                                                                                                              //menuitems[index].sizeselectecolor = Colors.red;
                                                                                                            }

                                                                                                            print(menuitems[index].selectedsizes);
                                                                                                            // menuitems[index].dialogselecteddata = "";
                                                                                                            // var temp = menuitems[index].amount;

                                                                                                            menuitems[index].totaldialogamount = menuitems[index].amount;
                                                                                                            print(menuitems[index].amount);
                                                                                                            double initialamount = double.parse(menuitems[index].amount);
                                                                                                            double totalamount = initialamount;
                                                                                                            menuitems[index].dialogselecteddata = "";

                                                                                                            for (var item in menuitems[index].selectedsizes) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            for (var item in menuitems[index].selectedextras) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            for (var item in menuitems[index].selectedvariants) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }

                                                                                                            for (var item in menuitems[index].selectedtypes) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            menuitems[index].totaldialogamount = totalamount.toString();
                                                                                                            print(menuitems[index].dialogselecteddata);
                                                                                                            print(menuitems[index].totaldialogamount);
                                                                                                          });
                                                                                                        })),
                                                                                                Expanded(
                                                                                                  child: RaisedButton(
                                                                                                    child: Text(
                                                                                                      size["name"] + "-" + this.widget.orderdata["currency"] + " " + size["amount"].toStringAsFixed(2),
                                                                                                      style: TextStyle(color: textcolor),
                                                                                                    ),
                                                                                                    color: menuitems[index].selectedsizes.any((element) => element["id"] == size["id"]) || size["is_default"] ? Color(0xff218efa) : Colors.grey,
                                                                                                    onPressed: () {
                                                                                                      setState(() {
                                                                                                        bool alreadypresent = menuitems[index].selectedsizes.any((element) => element["id"] == size["id"]);
                                                                                                        if (!alreadypresent) {
                                                                                                          menuitems[index].selectedsizes.add(size);
                                                                                                          //menuitems[index].sizeselectecolor = Colors.green;
                                                                                                        } else {
                                                                                                          menuitems[index].selectedsizes.removeWhere((element) => element["id"] == size["id"]);
                                                                                                          //menuitems[index].sizeselectecolor = Colors.red;
                                                                                                        }

                                                                                                        print(menuitems[index].selectedsizes);
                                                                                                        // menuitems[index].dialogselecteddata = "";
                                                                                                        // var temp = menuitems[index].amount;

                                                                                                        menuitems[index].totaldialogamount = menuitems[index].amount;
                                                                                                        print(menuitems[index].amount);
                                                                                                        double initialamount = double.parse(menuitems[index].amount);
                                                                                                        double totalamount = initialamount;
                                                                                                        menuitems[index].dialogselecteddata = "";

                                                                                                        for (var item in menuitems[index].selectedsizes) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        for (var item in menuitems[index].selectedextras) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        for (var item in menuitems[index].selectedvariants) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }

                                                                                                        for (var item in menuitems[index].selectedtypes) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        menuitems[index].totaldialogamount = totalamount.toString();
                                                                                                        print(menuitems[index].dialogselecteddata);
                                                                                                        print(menuitems[index].totaldialogamount);
                                                                                                      });
                                                                                                    },
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            );
                                                                                          }).toList(),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  }
                                                                                }),
                                                                            FutureBuilder(
                                                                                future: getsubitemFuture,
                                                                                builder: (context, snapshot) {
                                                                                  if (snapshot.connectionState != ConnectionState.done) {
                                                                                    return Text("Loading");
                                                                                  } else {
                                                                                    List<dynamic> variants = menuitems[index].variants;
                                                                                    return Column(
                                                                                      children: [
                                                                                        menuitems[index].variants.length != 0
                                                                                            ? Container(
                                                                                                child: Text(
                                                                                                "Variants ",
                                                                                                style: TextStyle(color: textcolor),
                                                                                              ))
                                                                                            : Container(),
                                                                                        Column(
                                                                                          children: variants.map((variant) {
                                                                                            return Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                    child: Checkbox(
                                                                                                        value: menuitems[index].selectedvariants.any((element) => element["id"] == variant["id"]) || variant["is_default"] ? true : false,
                                                                                                        onChanged: (val) {
                                                                                                          setState(() {
                                                                                                            bool alreadypresent = menuitems[index].selectedvariants.any((element) => element["id"] == variant["id"]);
                                                                                                            if (!alreadypresent) {
                                                                                                              menuitems[index].selectedvariants.add(variant);
                                                                                                              //menuitems[index].sizeselectecolor = Colors.green;
                                                                                                              //menuitems[index].amount = menuitems[index].variants[variantindex]["amount"] + menuitems[index].amount;
                                                                                                            } else {
                                                                                                              // menuitems[index].amount = menuitems[index].variants[variantindex]["amount"] - menuitems[index].amount;
                                                                                                              menuitems[index].selectedvariants.removeWhere((element) => element["id"] == variant["id"]);
                                                                                                              //menuitems[index].sizeselectecolor = Colors.red;
                                                                                                            }

                                                                                                            menuitems[index].totaldialogamount = menuitems[index].amount;
                                                                                                            print(menuitems[index].amount);
                                                                                                            double initialamount = double.parse(menuitems[index].amount);
                                                                                                            double totalamount = initialamount;
                                                                                                            menuitems[index].dialogselecteddata = "";

                                                                                                            for (var item in menuitems[index].selectedsizes) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            for (var item in menuitems[index].selectedextras) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            for (var item in menuitems[index].selectedvariants) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }

                                                                                                            for (var item in menuitems[index].selectedtypes) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            menuitems[index].totaldialogamount = totalamount.toString();
                                                                                                            print(menuitems[index].dialogselecteddata);
                                                                                                            print(menuitems[index].totaldialogamount);
                                                                                                          });
                                                                                                        })),
                                                                                                Expanded(
                                                                                                  child: RaisedButton(
                                                                                                    child: Text(
                                                                                                      variant["name"] + "-" + this.widget.orderdata["currency"] + " " + variant["amount"].toStringAsFixed(2),
                                                                                                      style: TextStyle(color: textcolor),
                                                                                                    ),
                                                                                                    color: menuitems[index].selectedvariants.any((element) => element["id"] == variant["id"]) || variant["is_default"] ? Color(0xff218efa) : Colors.grey,
                                                                                                    onPressed: () {
                                                                                                      setState(() {
                                                                                                        bool alreadypresent = menuitems[index].selectedvariants.any((element) => element["id"] == variant["id"]);
                                                                                                        if (!alreadypresent) {
                                                                                                          menuitems[index].selectedvariants.add(variant);
                                                                                                          //menuitems[index].sizeselectecolor = Colors.green;
                                                                                                          //menuitems[index].amount = menuitems[index].variants[variantindex]["amount"] + menuitems[index].amount;
                                                                                                        } else {
                                                                                                          // menuitems[index].amount = menuitems[index].variants[variantindex]["amount"] - menuitems[index].amount;
                                                                                                          menuitems[index].selectedvariants.removeWhere((element) => element["id"] == variant["id"]);
                                                                                                          //menuitems[index].sizeselectecolor = Colors.red;
                                                                                                        }

                                                                                                        menuitems[index].totaldialogamount = menuitems[index].amount;
                                                                                                        print(menuitems[index].amount);
                                                                                                        double initialamount = double.parse(menuitems[index].amount);
                                                                                                        double totalamount = initialamount;
                                                                                                        menuitems[index].dialogselecteddata = "";

                                                                                                        for (var item in menuitems[index].selectedsizes) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        for (var item in menuitems[index].selectedextras) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        for (var item in menuitems[index].selectedvariants) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }

                                                                                                        for (var item in menuitems[index].selectedtypes) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        menuitems[index].totaldialogamount = totalamount.toString();
                                                                                                        print(menuitems[index].dialogselecteddata);
                                                                                                        print(menuitems[index].totaldialogamount);
                                                                                                      });
                                                                                                    },
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            );
                                                                                          }).toList(),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  }
                                                                                }),
                                                                            FutureBuilder(
                                                                                future: getsubitemFuture,
                                                                                builder: (context, snapshot) {
                                                                                  if (snapshot.connectionState != ConnectionState.done) {
                                                                                    return Text("Loading");
                                                                                  } else {
                                                                                    List<dynamic> types = menuitems[index].types;

                                                                                    return Column(
                                                                                      children: [
                                                                                        menuitems[index].types.length != 0
                                                                                            ? Container(
                                                                                                child: Text(
                                                                                                "Types ",
                                                                                                style: TextStyle(color: textcolor),
                                                                                              ))
                                                                                            : Container(),
                                                                                        Column(
                                                                                          children: types.map((type) {
                                                                                            return Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                    child: Checkbox(
                                                                                                        value: menuitems[index].selectedtypes.any((element) => element["id"] == type["id"]) || type["is_default"] ? true : false,
                                                                                                        onChanged: (val) {
                                                                                                          setState(() {
                                                                                                            bool alreadypresent = menuitems[index].selectedtypes.any((element) => element["id"] == type["id"]);
                                                                                                            if (!alreadypresent) {
                                                                                                              menuitems[index].selectedtypes.add(type);
                                                                                                              //menuitems[index].sizeselectecolor = Colors.green;
                                                                                                            } else {
                                                                                                              menuitems[index].selectedtypes.removeWhere((element) => element["id"] == type["id"]);
                                                                                                              //menuitems[index].sizeselectecolor = Colors.red;
                                                                                                            }

                                                                                                            menuitems[index].totaldialogamount = menuitems[index].amount;
                                                                                                            print(menuitems[index].amount);
                                                                                                            double initialamount = double.parse(menuitems[index].amount);
                                                                                                            double totalamount = initialamount;
                                                                                                            menuitems[index].dialogselecteddata = "";

                                                                                                            for (var item in menuitems[index].selectedsizes) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            for (var item in menuitems[index].selectedextras) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            for (var item in menuitems[index].selectedvariants) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }

                                                                                                            for (var item in menuitems[index].selectedtypes) {
                                                                                                              String amountstr = item["amount"].toString();
                                                                                                              menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                              totalamount += item["amount"];
                                                                                                            }
                                                                                                            menuitems[index].totaldialogamount = totalamount.toString();
                                                                                                            print(menuitems[index].dialogselecteddata);
                                                                                                            print(menuitems[index].totaldialogamount);
                                                                                                          });
                                                                                                        })),
                                                                                                Expanded(
                                                                                                  child: RaisedButton(
                                                                                                    child: Text(
                                                                                                      type["name"] + "-" + this.widget.orderdata["currency"] + " " + type["amount"].toStringAsFixed(2),
                                                                                                      style: TextStyle(color: textcolor),
                                                                                                    ),
                                                                                                    color: menuitems[index].selectedtypes.any((element) => element["id"] == type["id"]) || type["is_default"] ? Color(0xff218efa) : Colors.grey,
                                                                                                    onPressed: () {
                                                                                                      setState(() {
                                                                                                        bool alreadypresent = menuitems[index].selectedtypes.any((element) => element["id"] == type["id"]);
                                                                                                        if (!alreadypresent) {
                                                                                                          menuitems[index].selectedtypes.add(type);
                                                                                                          //menuitems[index].sizeselectecolor = Colors.green;
                                                                                                        } else {
                                                                                                          menuitems[index].selectedtypes.removeWhere((element) => element["id"] == type["id"]);
                                                                                                          //menuitems[index].sizeselectecolor = Colors.red;
                                                                                                        }

                                                                                                        menuitems[index].totaldialogamount = menuitems[index].amount;
                                                                                                        print(menuitems[index].amount);
                                                                                                        double initialamount = double.parse(menuitems[index].amount);
                                                                                                        double totalamount = initialamount;
                                                                                                        menuitems[index].dialogselecteddata = "";

                                                                                                        for (var item in menuitems[index].selectedsizes) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        for (var item in menuitems[index].selectedextras) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        for (var item in menuitems[index].selectedvariants) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }

                                                                                                        for (var item in menuitems[index].selectedtypes) {
                                                                                                          String amountstr = item["amount"].toString();
                                                                                                          menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                          totalamount += item["amount"];
                                                                                                        }
                                                                                                        menuitems[index].totaldialogamount = totalamount.toString();
                                                                                                        print(menuitems[index].dialogselecteddata);
                                                                                                        print(menuitems[index].totaldialogamount);
                                                                                                      });
                                                                                                    },
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            );
                                                                                          }).toList(),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  }
                                                                                }),
                                                                            FutureBuilder(
                                                                                future: getsubitemFuture,
                                                                                builder: (context, snapshot) {
                                                                                  if (snapshot.connectionState != ConnectionState.done) {
                                                                                    return Text("Loading");
                                                                                  } else {
                                                                                    List<dynamic> extras = menuitems[index].extras;
                                                                                    return Column(
                                                                                      children: [
                                                                                        menuitems[index].extras.length != 0
                                                                                            ? Container(
                                                                                                child: Text(
                                                                                                "Extras ",
                                                                                                style: TextStyle(color: textcolor),
                                                                                              ))
                                                                                            : Container(),
                                                                                        Column(
                                                                                            children: extras.map((extra) {
                                                                                          return Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                  child: Checkbox(
                                                                                                      value: menuitems[index].selectedextras.any((element) => element["id"] == extra["id"]) || extra["is_default"] ? true : false,
                                                                                                      onChanged: (val) {
                                                                                                        setState(() {
                                                                                                          bool alreadypresent = menuitems[index].selectedextras.any((element) => element["id"] == extra["id"]);
                                                                                                          if (!alreadypresent) {
                                                                                                            menuitems[index].selectedextras.add(extra);
                                                                                                            //menuitems[index].sizeselectecolor = Colors.green;
                                                                                                          } else {
                                                                                                            menuitems[index].selectedextras.removeWhere((element) => element["id"] == extra["id"]);
                                                                                                            //menuitems[index].sizeselectecolor = Colors.red;
                                                                                                          }

                                                                                                          menuitems[index].totaldialogamount = menuitems[index].amount;
                                                                                                          print(menuitems[index].amount);
                                                                                                          double initialamount = double.parse(menuitems[index].amount);
                                                                                                          double totalamount = initialamount;
                                                                                                          menuitems[index].dialogselecteddata = "";

                                                                                                          for (var item in menuitems[index].selectedsizes) {
                                                                                                            String amountstr = item["amount"].toString();
                                                                                                            menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                            totalamount += item["amount"];
                                                                                                          }
                                                                                                          for (var item in menuitems[index].selectedextras) {
                                                                                                            String amountstr = item["amount"].toString();
                                                                                                            menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                            totalamount += item["amount"];
                                                                                                          }
                                                                                                          for (var item in menuitems[index].selectedvariants) {
                                                                                                            String amountstr = item["amount"].toString();
                                                                                                            menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                            totalamount += item["amount"];
                                                                                                          }

                                                                                                          for (var item in menuitems[index].selectedtypes) {
                                                                                                            String amountstr = item["amount"].toString();
                                                                                                            menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                            totalamount += item["amount"];
                                                                                                          }
                                                                                                          menuitems[index].totaldialogamount = totalamount.toString();
                                                                                                          print(menuitems[index].dialogselecteddata);
                                                                                                          print(menuitems[index].totaldialogamount);
                                                                                                        });
                                                                                                      })),
                                                                                              Expanded(
                                                                                                child: RaisedButton(
                                                                                                  child: Text(
                                                                                                    extra["name"] + "-" + this.widget.orderdata["currency"] + " " + extra["amount"].toStringAsFixed(2),
                                                                                                    style: TextStyle(color: textcolor),
                                                                                                  ),
                                                                                                  color: menuitems[index].selectedextras.any((element) => element["id"] == extra["id"]) || extra["is_default"] ? Color(0xff218efa) : Colors.grey,
                                                                                                  onPressed: () {
                                                                                                    setState(() {
                                                                                                      bool alreadypresent = menuitems[index].selectedextras.any((element) => element["id"] == extra["id"]);
                                                                                                      if (!alreadypresent) {
                                                                                                        menuitems[index].selectedextras.add(extra);
                                                                                                        //menuitems[index].sizeselectecolor = Colors.green;
                                                                                                      } else {
                                                                                                        menuitems[index].selectedextras.removeWhere((element) => element["id"] == extra["id"]);
                                                                                                        //menuitems[index].sizeselectecolor = Colors.red;
                                                                                                      }

                                                                                                      menuitems[index].totaldialogamount = menuitems[index].amount;
                                                                                                      print(menuitems[index].amount);
                                                                                                      double initialamount = double.parse(menuitems[index].amount);
                                                                                                      double totalamount = initialamount;
                                                                                                      menuitems[index].dialogselecteddata = "";

                                                                                                      for (var item in menuitems[index].selectedsizes) {
                                                                                                        String amountstr = item["amount"].toString();
                                                                                                        menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                        totalamount += item["amount"];
                                                                                                      }
                                                                                                      for (var item in menuitems[index].selectedextras) {
                                                                                                        String amountstr = item["amount"].toString();
                                                                                                        menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                        totalamount += item["amount"];
                                                                                                      }
                                                                                                      for (var item in menuitems[index].selectedvariants) {
                                                                                                        String amountstr = item["amount"].toString();
                                                                                                        menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                        totalamount += item["amount"];
                                                                                                      }

                                                                                                      for (var item in menuitems[index].selectedtypes) {
                                                                                                        String amountstr = item["amount"].toString();
                                                                                                        menuitems[index].dialogselecteddata += item["name"] + "-" + this.widget.orderdata["currency"] + " " + amountstr + ",";
                                                                                                        totalamount += item["amount"];
                                                                                                      }
                                                                                                      menuitems[index].totaldialogamount = totalamount.toString();
                                                                                                      print(menuitems[index].dialogselecteddata);
                                                                                                      print(menuitems[index].totaldialogamount);
                                                                                                    });
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          );
                                                                                        }).toList()),
                                                                                      ],
                                                                                    );
                                                                                  }
                                                                                }),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        }).then((value) {
                                                      setState(() {
                                                        print("OUTSIDe DATA ");
                                                        print(value);
                                                        if (value != null) {
                                                          menuitems[index]
                                                                  .outsidedata =
                                                              value[0];
                                                          menuitems[index]
                                                                  .totaloutsideamount =
                                                              value[1];
                                                        }
                                                      });
                                                    });
                                                  },
                                                  child: Text(
                                                    "customise",
                                                    style: TextStyle(
                                                      color: Color(0xff1278fa),
                                                      fontSize: 20,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ))
                                      : Container(),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(0),
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffefefef),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                        icon: Icon(Icons.remove),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          setState(() {
                                            menuitems[index].quantity =
                                                menuitems[index].quantity - 1;
                                            menuitems[index].quantity =
                                                menuitems[index].quantity <= 1
                                                    ? 1
                                                    : menuitems[index].quantity;
                                          });
                                        }),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                      child: Text(
                                    "" + menuitems[index].quantity.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(0),
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffefefef),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                        icon: Icon(Icons.add),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          setState(() {
                                            menuitems[index].quantity =
                                                menuitems[index].quantity + 1;
                                          });
                                        }),
                                  ),
                                ],
                              ),
                            ),

                            /*   menuitems[index].showcustomisablelink
                                ? RaisedButton(
                                    onPressed: () {
                                      setState(() {
                                        menuitems[index]
                                                .customisablelinkselected =
                                            menuitems[index]
                                                    .customisablelinkselected
                                                ? false
                                                : true;
                                        getsubItems(menuitems[index], index);
                                      });
                                    },
                                    child: Text("Customisable link"),
                                  )
                                : Container(),*/
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),

            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
