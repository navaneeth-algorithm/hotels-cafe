import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'dart:convert';
import 'dart:async';
import 'customdialog.dart';
import 'package:http/http.dart' as http;
import 'payment_card_validation/input_formatters.dart';
import 'payment_card_validation/payment_card.dart';
import 'payment_card_validation/my_strings.dart';
import 'package:email_validator/email_validator.dart';

class PaymentPageContainer extends StatefulWidget {
  Map otpdata;
  Map orderdata;
  String orderid;
  List cards;
  String totalAmount;
  String apikey;
  String mechentkey;
  String mode;
  PaymentPageContainer({
    Key key,
    this.title,
    this.orderdata,
    this.apikey,
    this.mechentkey,
    this.mode,
    this.otpdata,
    this.orderid,
    this.cards,
    this.totalAmount,
  }) : super(key: key);

  final String title;

  @override
  _PaymentPageContainerState createState() => _PaymentPageContainerState();
}

class _PaymentPageContainerState extends State<PaymentPageContainer> {
  List cards = [
    {
      'cardNo': 'xxxx xxxx xxxx 3875',
      'cardType': 'master',
      'expiryDate': '12/24',
      'paymentMethodId': 'pm_visa',
    },
    {
      'cardNo': 'xxxx xxxx xxxx 7275',
      'cardType': 'visa',
      'expiryDate': '1/28',
      'paymentMethodId': 'pm_master',
    }
  ];

  String _error;
  void setError(dynamic error) {
    /*_scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(error.toString())));*/
    setState(() {
      _error = error.toString();
    });
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

  void removecard(id) async {
    Map data = {
      "phone_session": this.widget.otpdata["phone_session_id"],
      "premise_id": this.widget.otpdata["premise_id"],
      "card_id": id.toString()
    };
    print(data);
    var body = json.encode(data);

    http.Response response = await http.delete(
      "https://test.eccolacafedelivery.com/api/v1/takeway/remove_card?phone_session=" +
          this.widget.otpdata["phone_session_id"] +
          "&&premise_id=" +
          this.widget.otpdata["premise_id"] +
          "&&card_id=" +
          id.toString(),
      headers: {"Content-Type": "application/json"},
    );

    print(response.body);
    setState(() {
      cards.removeWhere((element) => element["id"] == id);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true; // Start validating on every change.
      });
      _showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway
      //  _showInSnackBar('Payment card is valid');
      connectToStripe(null);
    }
  }

  bool paystatusprogress;

  Widget _getPayButton() {
    if (Platform.isIOS) {
      return new CupertinoButton(
        onPressed: _validateInputs,
        color: CupertinoColors.activeBlue,
        child: const Text(
          Strings.pay,
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    } else {
      return new RaisedButton(
        onPressed: _validateInputs,
        color: Colors.deepOrangeAccent,
        splashColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(100.0)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
        textColor: Colors.white,
        child: new Text(
          Strings.pay.toUpperCase(),
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: new Duration(seconds: 3),
    ));
  }

  bool remembercard;

  @override
  void initState() {
    remembercard = false;
    paystatusprogress = false;
    print(this.widget.apikey);
    print(this.widget.mechentkey);
    print(this.widget.mode);
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: '' + this.widget.apikey,
        merchantId: '' + this.widget.mechentkey,
        androidPayMode: '' + this.widget.mode,
      ),
    );
    setState(() {
      cards = this.widget.cards;
    });

    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);

    requiredemail = false;
    emailid = new TextEditingController();
    super.initState();
  }

  completePayment() async {
    Map data = {
      "order_id": this.widget.orderid,
      "premise_id": this.widget.otpdata["premise_id"],
      //x  "phone_session_id": this.widget.otpdata["phone_session_id"]
    };
    print(data);

    var body = json.encode(data);

    http.Response response = await http.post(
      "https://test.eccolacafedelivery.com/api/v1/takeway/complete_order",
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
      /* Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => SuccessPageContainer(
                    msg: mapData["message"],
                  )),
          (route) => false);*/
      showDialogSuccess(title: "SUCCESS", msg: mapData["message"]);
    }
    //[name, order_type, delivery_charge, order_history_list, active_order_list, current_order, menu_items, status]
    print(response.body);
  }

  Future<void> connectToStripe(var paymentMethodId) async {
    print(paymentMethodId);

    var paymentmethodid;

    const String url = 'YOUR_SERVER_URL';

    setState(() {
      paystatusprogress = true;
    });

    //PaymentMethod paymentMethod = PaymentMethod();
    var token;
    var tokenid;
    if (paymentMethodId == null) {
      try {
        CreditCard card = CreditCard(
          number: _paymentCard.number,
          expMonth: _paymentCard.month,
          expYear: _paymentCard.year,
        );

        token = await StripePayment.createTokenWithCard(card);

        tokenid = token.tokenId;
        print("TOKEN ID ");
        print(tokenid);
        // tikenid = token.

        /*   paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest(),
        ).then((PaymentMethod paymentMethod) {
          print(paymentMethod.card.number);
          print(paymentMethod.card.last4);
          print(paymentMethod.card.cvc);
          print(paymentMethod.type);
          print(paymentMethod.card.brand);
          //paymentmethodid = paymentMethod.id;
          print(paymentMethod.card.expMonth);
          print(paymentMethod.card.expYear);
          testCard = CreditCard(
            number: '4000002760003184',
            expMonth: 12,
            expYear: 21,
          );
          return paymentMethod;
        }).catchError(setError);*/
      } on PlatformException catch (err) {
        // Handle err
      } catch (err) {
        // other types of Exceptions
      }
    }

    Map data = {
      "order_id": this.widget.orderid,
      "premise_id": this.widget.otpdata["premise_id"],
      "email": emailid.text,
      "save_card": remembercard,
      "previous_card": paymentMethodId.toString(),
      "stripeToken": paymentMethodId == null ? tokenid : "",
      "user": {
        "card_last4": paymentMethodId == null
            ? _paymentCard.number.substring(_paymentCard.number.length - 4)
            : "",
      },
    };

    print(data);
    //print(this.widget.otpdata);
    var body = json.encode(data);

    http.Response response = await http.post(
        "https://test.eccolacafedelivery.com/api/v1/takeway/pay_amount",
        headers: {"Content-Type": "application/json"},
        body: body);

    print(response.body);
    try {
      var dataUser = json.decode(response.body);
      Map mapData = dataUser;

      if (mapData["message"] != null) {
        /* Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => SuccessPageContainer(
                      msg: mapData["message"],
                    )),
            (route) => false);*/
        showDialogSuccess(title: "SUCCESS", msg: mapData["message"]);
      }
    } catch (err) {
      showDialogSuccess(
          title: "ERROR",
          msg: "Retry again later.Some Error occured " + err.toString());
      print(err);
    }
  }

  bool requiredemail;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _card = new PaymentCard();
  var _autoValidate = false;
  TextEditingController emailid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Pay and Submit',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'ProximaNovaSemiBold',
              ),
            ),
          ),
          backgroundColor: Colors.black),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                top: 24.0,
                right: 24.0,
              ),
              child: paystatusprogress
                  ? Center(
                      child: Container(
                        child: Text(
                          "In Progress",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  : ListView(
                      children: <Widget>[
                        RaisedButton(
                            onPressed: () {
                              completePayment();
                            },
                            child: Text("Pay on " +
                                this.widget.orderdata["order_type"])),
                        Container(
                          child: Text("OR"),
                          alignment: Alignment.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'CARD DETAILS',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                            /* InkWell(
                        splashColor: Colors.blueAccent,
                        onTap: () {
                          connectToStripe(null);
                        },
                        child: const Text(
                          'pay by new card',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),*/
                          ],
                        ),
                        SizedBox(height: 30),
                        ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 20);
                          },
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: cards.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.5))),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        RaisedButton(
                                          onPressed: () {
                                            connectToStripe(cards[index]['id']);
                                          },
                                          child: Text("Pay using this card"),
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              removecard(cards[index]['id']);
                                            },
                                            color: Colors.red)
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          cards[index]['number'],
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'ProximaNova',
                                            color: Colors.black,
                                          ),
                                        ),
                                        //  checkCardType(cards[index]['cardType']),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 19,
                        ),
                        Text("Using Card"),
                        SizedBox(
                          height: 10,
                        ),
                        new TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(19),
                            new CardNumberInputFormatter()
                          ],
                          controller: numberController,
                          decoration: new InputDecoration(
                            border: const UnderlineInputBorder(),
                            filled: true,
                            icon: CardUtils.getCardIcon(_paymentCard.type),
                            hintText: 'What number is written on card?',
                            labelText: 'Number',
                          ),
                          onSaved: (String value) {
                            //
                            // print('onSaved = $value');
                            //  print('Num controller has = ${numberController.text}');
                            _paymentCard.number =
                                CardUtils.getCleanedNumber(value);
                          },
                          validator: CardUtils.validateCardNum,
                        ),
                        new SizedBox(
                          height: 30.0,
                        ),
                        new TextFormField(
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: new InputDecoration(
                            border: const UnderlineInputBorder(),
                            filled: true,
                            icon: new Image.asset(
                              'images/card_cvv.png',
                              width: 40.0,
                              color: Colors.grey[600],
                            ),
                            hintText: 'Number behind the card',
                            labelText: 'CVV',
                          ),
                          validator: CardUtils.validateCVV,
                          keyboardType: TextInputType.number,
                          onSaved: (value) {
                            _paymentCard.cvv = int.parse(value);
                          },
                        ),
                        new SizedBox(
                          height: 30.0,
                        ),
                        new TextFormField(
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(4),
                            new CardMonthInputFormatter()
                          ],
                          decoration: new InputDecoration(
                            border: const UnderlineInputBorder(),
                            filled: true,
                            icon: new Image.asset(
                              'images/calender.png',
                              width: 40.0,
                              color: Colors.grey[600],
                            ),
                            hintText: 'MM/YY',
                            labelText: 'Expiry Date',
                          ),
                          validator: CardUtils.validateDate,
                          keyboardType: TextInputType.number,
                          onSaved: (value) {
                            List<int> expiryDate =
                                CardUtils.getExpiryDate(value);
                            _paymentCard.month = expiryDate[0];
                            _paymentCard.year = expiryDate[1];
                          },
                        ),
                        new SizedBox(
                          height: 50.0,
                        ),
                        Row(
                          children: [
                            Container(
                                child: Checkbox(
                                    value: remembercard,
                                    onChanged: (val) {
                                      setState(() {
                                        remembercard =
                                            remembercard ? false : true;
                                      });
                                    })),
                            Text("Remember card")
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "TOTAL AMOUNT " +
                                  this.widget.orderdata["currency"] +
                                  "" +
                                  (double.parse(widget.totalAmount)
                                      .toStringAsFixed(2)),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                                value: requiredemail,
                                onChanged: (val) {
                                  // print(this.widget.cards);
                                  setState(() {
                                    requiredemail =
                                        requiredemail ? false : true;
                                  });
                                }),
                            Text("Need Receipt")
                          ],
                        ),
                        requiredemail
                            ? Container(
                                child: TextFormField(
                                  controller: emailid,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Field is Empty";
                                    } else if (!EmailValidator.validate(
                                        value)) {
                                      return "Invalid Email";
                                    } else {
                                      return null;
                                    }
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xff7D8CA1))),
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Color(0xff7D8CA1),
                                    ),
                                    hintText: "Enter Email Address",
                                    hintStyle:
                                        TextStyle(color: Color(0xff7D8CA1)),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 20,
                        ),
                        new Container(
                          alignment: Alignment.center,
                          child: _getPayButton(),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Icon checkCardType(card) {
    switch (card) {
      case 'master':
        return Icon(
          Icons.map,
          size: 24,
        );
      case 'visa':
        return Icon(
          Icons.credit_card,
          size: 24,
        );
      default:
        return Icon(
          Icons.credit_card,
          size: 24,
        );
    }
  }
}
