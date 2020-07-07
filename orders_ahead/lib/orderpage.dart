import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'constants.dart';
import 'activeorderpage.dart';
import 'homepage.dart';
import 'currentorderpage.dart';
import 'pastorderpage.dart';

class OrderPage extends StatefulWidget {
  Map otpdata, orderpagedata;
  OrderPage({Key key, this.otpdata, this.orderpagedata}) : super(key: key);
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: Colors.black),
        home: SafeArea(
            top: false,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              primary: false,
              appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.exit_to_app),
                    tooltip: "Home",
                    onPressed: () {
                      //Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) => HomePage()),
                          (route) => false);
                    }),
                title: Text(""),
                centerTitle: true,
              ),
              bottomNavigationBar: TabBar(
                labelColor: tablabelcolor,
                unselectedLabelColor: tabunselectedlabelcolor,
                isScrollable: true,
                tabs: [
                  new Tab(
                    text: "Current Orders",
                    icon: new Icon(Icons.event),
                  ),
                  new Tab(
                    iconMargin: EdgeInsets.all(1),
                    text: "Active Orders",
                    icon: new Icon(Icons.event),
                  ),
                  new Tab(
                    text: "Past Order",
                    icon: new Icon(Icons.history),
                  ),
                ],
                controller: _tabController,
              ),
              body: OrderContainer(
                tabController: _tabController,
                otpdata: this.widget.otpdata,
                orderpagedata: this.widget.orderpagedata,
              ),
            )),
      ),
    );
  }
}

class OrderContainer extends StatefulWidget {
  TabController tabController;
  Map otpdata, orderpagedata;
  OrderContainer(
      {Key key, this.tabController, this.otpdata, this.orderpagedata})
      : super(key: key);
  @override
  _OrderContainerState createState() => _OrderContainerState();
}

class _OrderContainerState extends State<OrderContainer> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<ErrorAnimationType> errorController;
  String currentText = "";
  bool hasError;
  _checkdataRecieved() {
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    print("OTP DATA \n");
    print(this.widget.otpdata);
    print("order data");
    print(this.widget.orderpagedata);
  }

  @override
  void initState() {
    // TODO: implement initState
    errorController = StreamController<ErrorAnimationType>();
    //_checkdataRecieved();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          CurrentOrderPageContainer(
            orderdata: this.widget.orderpagedata,
            otpdata: this.widget.otpdata,
          ),
          ActiveOrderPageContainer(
            orderdata: this.widget.orderpagedata,
            otpdata: this.widget.otpdata,
          ),
          PastOrderPageContainer(
            orderdata: this.widget.orderpagedata,
            otpdata: this.widget.otpdata,
          ),
        ],
        controller: this.widget.tabController);
  }
}
