import 'dart:convert';

import 'package:eccola_cafe/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart' as http;
import 'customdialog.dart';
import 'paymentpage.dart';

class PreviewPageContainer extends StatefulWidget {
  Map otpdata;
  Map orderdata;
  String orderid;
  String address1, address2, name, notes;

  PreviewPageContainer(
      {Key key,
      this.orderdata,
      this.otpdata,
      this.orderid,
      this.address1,
      this.notes,
      this.address2,
      this.name})
      : super(key: key);
  @override
  _PreviewPageContainerState createState() => _PreviewPageContainerState();
}

Map previewData;
var subTotal = 0.0;
var total = 0.0;
var deliverycharge = 0;

class _PreviewPageContainerState extends State<PreviewPageContainer> {
  completePayment() async {
    Map data = {
      "order_id": this.widget.orderid,
      "premise_id": this.widget.otpdata["premise_id"],
      //x  "phone_session_id": this.widget.otpdata["phone_session_id"]
    };
    print(data);

    var body = json.encode(data);

    http.Response response = await http.post(
      "http://18.130.82.119:3013/api/v1/takeway/complete_order",
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    print(response.body);
    var dataUser = json.decode(response.body);
    Map mapData = dataUser;
    // ackAlert(context, "Payment", "Successful");

    /* Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()),
                    (route) => false);*/

    // print("Respose  got for validate_otp");
    print("Payment complete?");
    if (mapData["message"] != null) {
      showDialogSuccess(title: "SUCCESS", msg: mapData["message"]);
    }
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    print(response.body);
  }

  void showDialogSuccess({title = '', msg = ''}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: "" + msg,
        buttonText: "Okay",
      ),
    );
  }

  submitOrder() async {
    Map data = {
      "order_id": this.widget.orderid,
      "premise_id": this.widget.otpdata["premise_id"],
      "name": this.widget.name,
      "address1": this.widget.address1,
      "address2": this.widget.address2,
      "postcode": this.widget.orderdata["current_order"]["postcode"]
    };

    var body = json.encode(data);

    http.Response response = await http.post(
        "http://18.130.82.119:3013/api/v1/takeway/confirm_order",
        headers: {"Content-Type": "application/json"},
        body: body);

    var dataUser = json.decode(response.body);
    // print(response.body);
    Map mapData = dataUser;
    if (dataUser["message"] == "move to payment page") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => PaymentPageContainer(
                    orderdata: this.widget.orderdata,
                    otpdata: this.widget.otpdata,
                    totalAmount: total.toString(),
                    orderid: this.widget.orderid,
                    cards: dataUser["cards"],
                    apikey: dataUser["api_key"],
                    mechentkey: dataUser["merchant_key"],
                    mode: dataUser["mode"],
                  )));
    }
  }

  Future getPreviewData() async {
    //print(o1);

    Map data = {
      "order_id": this.widget.orderid,
      "premise_id": this.widget.otpdata["premise_id"],
      "phone_session_id": this.widget.otpdata["phone_session_id"]
    };

    var body = json.encode(data);

    http.Response response = await http.get(
      "http://18.130.82.119:3013/api/v1/takeway/preview?order_id=" +
          this.widget.orderid.toString() +
          "&&premise_id=" +
          this.widget.otpdata["premise_id"] +
          "&&phone_session_id=" +
          this.widget.otpdata["phone_session_id"],
      headers: {"Content-Type": "application/json"},
    );

    var dataUser = json.decode(response.body);

    bool showpage = dataUser["current_order"]["show_payment_page"];

    if (!showpage) {
      setState(() {
        paymentbutton = "Complete Payment";
      });
    }

    return dataUser;

    // if (dataUser["status"] != 401) {
    //print(dataUser);

    //Scaffold.of(context).showSnackBar(SnackBar(content: Text("got otp")));
    //  } else {}

    /*Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => (OrderPage())));*/
  }

  List<DataRow> tablerows;
  TextEditingController _notes = new TextEditingController();
  TextEditingController _address1 = new TextEditingController();
  TextEditingController _address2 = new TextEditingController();
  TextEditingController _name = new TextEditingController();
  TextEditingController _postalcode = new TextEditingController();
  String paymentbutton;
  Future getpreviewdata;
  @override
  void initState() {
    // TODO: implement initState
    getpreviewdata = getPreviewData();

    paymentbutton = "Choose Payment Type";

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
    //print(this.widget.orderdata);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final _formKey = GlobalKey<FormState>();
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        extendBody: true,
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        backgroundColor: backgroundcolor,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: height,
              child: Form(
                key: _formKey,
                child: FutureBuilder(
                  future: getpreviewdata,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                        ),
                      );
                    } else {
                      previewData = snapshot.data;

                      subTotal =
                          previewData["current_order"]["delivery_charge"] > 0
                              ? (previewData["current_order"]["total"] -
                                  previewData["current_order"]
                                      ["delivery_charge"])
                              : previewData["current_order"]["total"];
                      //   print("SUBTOTAL AMOUNT refactores ");
                      print(previewData["current_order"]);
                      deliverycharge =
                          previewData["current_order"]["delivery_charge"];
                      total = previewData["current_order"]["total"];

                      //  print("TOTAL" + total.toString());
                      //  print("deliverycharge" + deliverycharge.toString());
                      List<dynamic> previewdata =
                          previewData["current_order"]["items"];

                      return Container(
                        margin: EdgeInsets.all(10),
                        height: 500,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(15),
                                padding: const EdgeInsets.all(8.0),
                                child: CustomText(
                                  text: "Order Confirmation",
                                  fontsize: 18,
                                  fontweight: FontWeight.bold,
                                  color: textcolor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        margin: EdgeInsets.all(15),
                                        child: CustomText(
                                          text: "Order Details " +
                                              this
                                                  .widget
                                                  .orderdata["currency"] +
                                              " " +
                                              total.toStringAsFixed(2),
                                          fontsize: 18,
                                          fontweight: FontWeight.bold,
                                          color: textcolor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: CustomText(
                                                text: "Name",
                                                fontsize: 16,
                                                fontweight: FontWeight.bold,
                                                color: textcolor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: CustomText(
                                                text: "Quantity",
                                                fontsize: 16,
                                                fontweight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: previewdata.map((e) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Html(
                                                  data: e["name"],
                                                  style: {
                                                    "body": Style(
                                                        color: textcolor,
                                                        fontSize: FontSize(16))
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                  child: CustomText(
                                                text: this
                                                        .widget
                                                        .orderdata["currency"] +
                                                    " " +
                                                    e["amount"]
                                                        .toStringAsFixed(2),
                                                fontsize: 16,
                                              ))
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: CustomText(
                                                fontsize: 16,
                                                fontweight: FontWeight.bold,
                                                textalign: TextAlign.center,
                                                text: "SubTotal",
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: CustomText(
                                                text: "" +
                                                    this
                                                        .widget
                                                        .orderdata["currency"] +
                                                    " " +
                                                    subTotal.toStringAsFixed(2),
                                                fontsize: 16,
                                                fontweight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    deliverycharge > 0
                                        ? Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    child: CustomText(
                                                      text: "Delivery Charges",
                                                      fontsize: 16,
                                                      fontweight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child: Expanded(
                                                    child: CustomText(
                                                      text: "" +
                                                          this.widget.orderdata[
                                                              "currency"] +
                                                          " " +
                                                          deliverycharge
                                                              .toStringAsFixed(
                                                                  2),
                                                      fontsize: 16,
                                                      fontweight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: CustomText(
                                                text: "Total",
                                                fontsize: 16,
                                                fontweight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: CustomText(
                                                text: "" +
                                                    this
                                                        .widget
                                                        .orderdata["currency"] +
                                                    " " +
                                                    total.toStringAsFixed(2),
                                                fontsize: 16,
                                                fontweight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    deliverycharge > 0
                                        ? CustomText(
                                            text: this.widget.name,
                                            fontsize: 16,
                                          )
                                        : Container(),
                                    deliverycharge > 0
                                        ? CustomText(
                                            text: this.widget.address1,
                                            fontsize: 16,
                                          )
                                        : Container(),
                                    deliverycharge > 0
                                        ? CustomText(
                                            text: this.widget.address2 +
                                                "," +
                                                this.widget.otpdata["postcode"],
                                            fontsize: 16,
                                          )
                                        : Container(),
                                    deliverycharge > 0
                                        ? CustomText(
                                            text: this
                                                .widget
                                                .orderdata["phone_number"],
                                            fontsize: 16,
                                          )
                                        : Container(),
                                    deliverycharge > 0
                                        ? Column(
                                            children: [
                                              CustomText(
                                                text: "",
                                                fontsize: 16,
                                              ),
                                              CustomText(
                                                text: "",
                                                fontsize: 16,
                                              ),
                                              CustomText(
                                                text: "",
                                                fontsize: 16,
                                              ),
                                              CustomText(
                                                text: "",
                                                fontsize: 16,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              width: width,
              margin: EdgeInsets.all(10),
              child: RaisedButton(
                color: buttoncolor,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (previewData["current_order"]["show_payment_page"]) {
                      submitOrder();
                      //show payment page

                    } else {
                      //Dont show payment page
                      //Success Page
                      completePayment();
                    }
                  }
                },
                child: Text(
                  "" + paymentbutton,
                  style: TextStyle(color: buttontextcolor, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  String text;
  double fontsize;
  FontWeight fontweight;
  Color color;
  TextAlign textalign;
  CustomText(
      {this.text,
      this.fontsize,
      this.fontweight,
      this.color = textcolor,
      this.textalign});

  @override
  Widget build(BuildContext context) {
    return Text(this.text,
        style: TextStyle(
            color: this.color,
            fontSize: this.fontsize,
            fontWeight: this.fontweight));
  }
}
