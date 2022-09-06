import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/Components/list_tile.dart';
import 'package:jhatfat/Pages/order_placed.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/cartdetails.dart';
import 'package:jhatfat/bean/couponlist.dart';
import 'package:jhatfat/bean/paymentstatus.dart';
import 'package:jhatfat/bean/subscriptionlist.dart';

class Subscription extends StatefulWidget {

  Subscription();

  @override
  State<StatefulWidget> createState() {
    return SubscritionState();
  }
}

class SubscritionState extends State<Subscription> {
  PaystackPlugin p = new PaystackPlugin();
  Razorpay _razorpay = new Razorpay();
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  List<PaymentVia> paymentVia = [];
  dynamic currency = '';

  bool visiblity = false;
  String promocode = '';

  bool razor = false;
  bool paystack = false;

  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  String _cardNumber="";
  String _cvv="";
  int _expiryMonth = 0;
  int _expiryYear = 0;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  var _inProgress = false;

  double walletAmount = 0.0;
  double walletUsedAmount = 0.0;
  bool isFetch = false;

  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;


  List<CouponList> couponL = [];
  List<PaymentVia> tagObjs =[];
  List<subscriptionlist> planlist=[];

  @override
  void initState() {
    super.initState();
    getVendorPayment();
    getplanlist();
    newtotalAmount = double.parse('${totalAmount}');
  }
  void getplanlist() async {
    var url = subscriptionList;
    var client = http.Client();
    Uri myUri = Uri.parse(url);
    client.get(myUri).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<subscriptionlist> p = tagObjsJson
              .map((tagJson) => subscriptionlist.fromJson(tagJson))
              .toList();
          setState(() {
            planlist = p;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }
  void getVendorPayment() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency');
    });
    var url = paymentvia;
    var client = http.Client();
    Uri myUri = Uri.parse(url);

    client.post(myUri).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          tagObjs = tagObjsJson
              .map((tagJson) => PaymentVia.fromJson(tagJson))
              .toList();

        }
      }
    }).catchError((e) {
      print(e);
    });
  }


  void razorPay(keyRazorPay, amount) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': '${keyRazorPay}',
        'amount': amount,
        'name': '${prefs.getString('user_name')}',
        'description': 'Grocery Shopping',
        'prefill': {
          'contact': '${prefs.getString('user_phone')}',
          'email': '${prefs.getString('user_email')}'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void payStatck(String key) async {
    p.initialize(publicKey: key);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(64.0),
          child: AppBar(
            automaticallyImplyLeading: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Subscription',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: kMainTextColor),
                ),
              ],
            ),
          ),
        ),
        body:

        Container(
            child: Card(
                shadowColor: kMainColor,
                margin:EdgeInsets.all(20),
                child:Container(
                    height: 300,
                    color: Colors.white,
                    child: Row(
                        children: [
                          Expanded(
                              child:Container(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child:
                                          ListTile(
                                            contentPadding: EdgeInsets.all(8.0),
                                            title: Text(planlist[0].plans,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child:
                                          ListTile(
                                            contentPadding: EdgeInsets.all(8.0),
                                            title: Text("Days "+planlist[0].description,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),),
                                          ),
                                        ),

                                        Expanded(
                                          flex: 5,
                                          child:
                                          ListTile(
                                            title: Text("For "+planlist[0].days+" Days @ "+"${currency}"+planlist[0].amount.toString(),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),),
                                            contentPadding: EdgeInsets.all(8.0),
                                          ),
                                        ),

                                        Expanded(
                                          flex: 8,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(18.0),
                                                child:
                                                ElevatedButton(
                                                    onPressed: () {
                                                      openCheckout(tagObjs[0].payment_key, planlist[0].amount * 100);
                                                    },
                                                    child: Text("Payment")
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ]
                                  )
                              )
                          )
                        ]
                    ))
            )));
  }




  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  _startAfreshCharge() async {
    _formKey.currentState?.save();

    Charge charge = Charge()
      ..amount = 100 // In base currency
      ..email = 'customer@email.com'
      ..currency = 'NGN'
      ..card = _getCardFromUI()
      ..reference = _getReference();

    _chargeCard(charge);
  }

  _chargeCard(Charge charge) async {
    p.chargeCard(context, charge: charge).then((value) {
      print('${value.status}');
      print('${value.toString()}');
      print('${value.card}');
      if (value.status && value.message == "Success") {
        setState(() {
          showPaymentDialog = false;
          _inProgress = false;
          showDialogBox = true;
        });
      }
    });
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}
}