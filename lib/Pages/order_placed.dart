
import 'package:flutter/material.dart';
import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/HomeOrderAccount/home_order_account.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';

class OrderPlaced extends StatelessWidget {
  final dynamic payment_method;
  final dynamic payment_status;
  final dynamic order_id;
  final dynamic rem_price;
  final dynamic currency;
  final dynamic uiType;

  OrderPlaced(this.payment_method, this.payment_status, this.order_id,
      this.rem_price, this.currency, this.uiType) {
    deleteProducts(uiType);
  }

  void deleteProducts(uiType) async {
    DatabaseHelper db = DatabaseHelper.instance;
    if (uiType == "1") {
      db.deleteAll();
    } else if (uiType == "2") {
      db.deleteAllRestProdcut();
      db.deleteAllAddOns();
    } else if (uiType == "5") {
      clearCart(db);
    }
  }

  void clearCart(db) async {
    db.deleteAllPharma().then((value) {
      db.deleteAllAddonPharma();
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
              return HomeOrderAccount();
            }), (Route<dynamic> route) => false);
        return true; //
      },

      child: Scaffold(
          body: Column(
            children: <Widget>[
              Spacer(
                flex: 1,
              ),
              Padding(
                padding: EdgeInsets.all(60.0),
                child: Image.asset(
                  'images/order_placed.png',
                  height: 265.7,
                  width: 260.7,
                ),
              ),
              Text(
                'Order id - $order_id has been Placed \n Please keep $currency $rem_price!!',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 23.3, color: kMainTextColor),
              ),
              Text(
                '\n\nThanks for choosing us for\ndelivering your needs.\n\nYou can check your order status\nin my order section.',
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(color: kDisabledColor),
              ),
              Spacer(
                flex: 2,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) {
                          return HomeOrderAccount();
                        }), (Route<dynamic> route) => false);                  },
                  child: Text("Go To Home")
              ),
            ],
          ),
        ),
      );
  }
}

