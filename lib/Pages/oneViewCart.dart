import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:horizontal_calendar_view_widget/date_helper.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/saved_addresses_page.dart';
import 'package:jhatfat/HomeOrderAccount/home_order_account.dart';
import 'package:jhatfat/Pages/payment_method.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/address.dart';
import 'package:jhatfat/bean/cartdetails.dart';
import 'package:jhatfat/bean/cartitem.dart';
import 'package:jhatfat/bean/orderarray.dart';
import 'package:jhatfat/bean/paymentstatus.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';

import '../bean/resturantbean/restaurantcartitem.dart';
import '../restaturantui/pages/payment_restaurant_page.dart';

class oneViewCart extends StatefulWidget {
  @override
  _oneViewCartState createState() => _oneViewCartState();
}

class _oneViewCartState extends State<oneViewCart> {
  String storeName = '';
  String vendorCatId = '';
  String uiType = '';
  dynamic vendorId = '';


  List<CartItem> cartListI = [];
  List<RestaurantCartItem> cartListII = [];

  var totalAmount = 0.0;
  dynamic deliveryCharge = 0.0;

  var showDialogBox = false;

  late DateTime firstDate;
  late DateTime lastDate;
  List<DateTime> dateList = [];
  String dateTimeSt = '';
  String currency = '';
  List<dynamic> radioList = [];
  bool isCartFetch = false;
  late ShowAddressNew? addressDelivery = null;
  bool isFetchingTime = false;
  int idd = 0;
  int idd1 = 0;


  void getResStoreName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storename = prefs.getString('store_resturant_name');
    String? vendor_cat_id = prefs.getString('vendor_cat_id');
    String? ui_type = prefs.getString('ui_type');
    dynamic vendor_id = prefs.getString('res_vendor_id');
    setState(() {
      currency = prefs.getString('curency')!;
      if (storename != null && storename.length > 0) {
        storeName = storename;
      }
      if (vendorCatId != null && vendorCatId.length > 0) {
        vendorCatId = vendor_cat_id!;
      }
      if (uiType != null && uiType.length > 0) {
        uiType = ui_type!;
      }
      if (vendor_id != null && vendor_id.length > 0) {
        vendorId = vendor_id;
      }
    });
  }

  void getStoreName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storename = prefs.getString('store_name');
    setState(() {
      storeName = storename!;
    });
  }

  @override
  void initState() {
    super.initState();
    getAddress(context);

    getResStoreName();
    getResCartItem();
    getCatC();

    firstDate = toDateMonthYear(DateTime.now());
    prepareData(firstDate);
    dateTimeSt =
    '${firstDate.year}-${(firstDate.month
        .toString()
        .length == 1) ? '0' + firstDate.month.toString() : firstDate
        .month}-${firstDate.day}';
    lastDate = toDateMonthYear(firstDate.add(Duration(days: 9)));
    getStoreName();
    getCartItem();
    dynamic date =
        '${firstDate.day}-${(firstDate.month
        .toString()
        .length == 1) ? '0' + firstDate.month.toString() : firstDate
        .month}-${firstDate.year}';

    hitDateCounter(date);
  }

  void getResCartItem() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.getResturantOrderList().then((value) {
      List<RestaurantCartItem> tagObjs =
      value.map((tagJson) => RestaurantCartItem.fromJson(tagJson)).toList();
      setState(() {
        cartListII = List.from(tagObjs);
        isCartFetch = true;
      });
      print('cart value :- ${cartListII.toString()}');
      for (int i = 0; i < cartListII.length; i++) {
        print('${cartListII[i].varient_id}');
        db
            .getAddOnListWithPrice(int.parse('${cartListII[i].varient_id}'))
            .then((values) {
          print('${values}');
          List<AddonCartItem> tagObjsd =
          values.map((tagJson) => AddonCartItem.fromJson(tagJson)).toList();
          if (tagObjsd != null) {
            setState(() {
              cartListII[i].addon = tagObjsd;
            });
          }
        });
      }
      setState(() {
        isCartFetch = false;
      });
    });
  }

  void prepareData(firstDate) {
    lastDate = toDateMonthYear(firstDate.add(Duration(days: 9)));
    dateList = getDateList(firstDate, lastDate);
  }

  void dispose() {
    super.dispose();
  }

  List<DateTime> feedInitialSelectedDates(int target, int calendarDays) {
    List<DateTime> selectedDates = [];

    for (int i = 0; i < calendarDays; i++) {
      if (selectedDates.length == target) {
        break;
      }
      DateTime date = firstDate.add(Duration(days: i));
      if (date.weekday != DateTime.sunday) {
        selectedDates.add(date);
      }
    }

    return selectedDates;
  }

  void getCartItem() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryAllRows().then((value) {
      List<CartItem> tagObjs =
      value.map((tagJson) => CartItem.fromJson(tagJson)).toList();
      if (tagObjs.isEmpty) {
        setState(() {});
      }
      setState(() {
        isCartFetch = false;
        cartListI.clear();
        cartListI = tagObjs;
      });
    });
  }

  void getCatC() async {
    if (cartListI.isNotEmpty) {
      print("object*******");

      DatabaseHelper db = DatabaseHelper.instance;
      db.calculateTotal().then((value) {
        var tagObjsJson = value as List;
        setState(() {
          if (value != null) {
            dynamic totalAmount_1 = tagObjsJson[0]['Total'];
            if (totalAmount_1 == null) {} else {
              totalAmount = totalAmount_1 + deliveryCharge;
            }
          } else {}
        });
      });
    }

    if (cartListII.isNotEmpty) {
      print("object");
      DatabaseHelper db = DatabaseHelper.instance;
      db.calculateTotalRest().then((value) {
        db.calculateTotalRestAdon().then((valued) {
          var tagObjsJson = value as List;
          var tagObjsJsond = valued as List;
          setState(() {
            if (value != null) {
              dynamic totalAmount_1 = tagObjsJson[0]['Total'];
              print('T--${totalAmount_1}');
              if (valued != null) {
                dynamic totalAmount_2 = tagObjsJsond[0]['Total'];
                print('T--${totalAmount_2}');
                if (totalAmount_2 == null) {
                  if (totalAmount_1 == null) {} else {
                    totalAmount = totalAmount_1 + deliveryCharge;
                  }
                } else {}
              }
            }
          });
        });
      });
    }
  }

  void getAddress(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCartFetch = true;
      currency = prefs.getString('curency')!;
    });
    int? userId = prefs.getInt('user_id');
    String? vendorId = prefs.getString('vendor_id');
    var url = address_selection;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'user_id': '${userId}',
      'vendor_id': '${vendorId}'
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = json.decode(value.body);
        if (jsonData['status'] == "1" &&
            jsonData['data'] != null &&
            jsonData['data'] != 'null') {
          AddressSelected addressWelcome = AddressSelected.fromJson(jsonData);
          setState(() {
            isCartFetch = false;
            addressDelivery = addressWelcome.data!;
            deliveryCharge =
                double.parse('${addressDelivery?.delivery_charge}');
          });
        } else {
          setState(() {
            isCartFetch = false;
            //addressDelivery = null;
            deliveryCharge = 0.0;
          });
          // Toast.show("Address not found!", context,
          //     duration: Toast.LENGTH_SHORT);
        }
      } else {
        setState(() {
          isCartFetch = false;
          //addressDelivery = null;
          deliveryCharge = 0.0;
        });

        // Toast.show('No Address found!', context, duration: Toast.LENGTH_SHORT);
      }
    }).catchError((e) {
      setState(() {
        isCartFetch = false;
        //addressDelivery = null;
        deliveryCharge = 0.0;
      });
    });
  }

  void addOrMinusProduct2(store_name, product_id, product_name, unit, price,
      quantity, itemCount,
      varient_id, index, price_d) async {

    print("addminus "+itemCount+" "+product_id);

    DatabaseHelper db = DatabaseHelper.instance;
    Future<int?> existing = db.getRestProductcount(int.parse(varient_id));
    existing.then((value) {
      var vae = {
        DatabaseHelper.productId: product_id,
        DatabaseHelper.storeName: store_name,
        DatabaseHelper.productName: product_name,
        DatabaseHelper.price: (price_d * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.varientId: int.parse(varient_id)
      };

      print('value we - $value');

      if (value == 0) {
        db.insertRaturantOrder(vae);
      } else {
        if (itemCount == 0) {
          db.deleteResProduct(int.parse(varient_id)).then((value) {
            db.deleteAddOn(int.parse(varient_id));
          });
        } else {
          db.updateRestProductData(vae, int.parse(varient_id));
        }
      }
      getCatC();
      if (itemCount == 0) {
        getResCartItem();
      }
    });
  }

  Widget timewidget(BuildContext context, double itemHeight, double itemWidth) {
    return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(10.0),
            color: kCardBackgroundColor,
            child: Text('Time Slot',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6!
                    .copyWith(
                    color: Color(0xff616161),
                    letterSpacing: 0.67)),
          ),
          Divider(
            color: kCardBackgroundColor,
            thickness: 6.7,
          ),
          (!isFetchingTime && radioList.length > 0)
              ? Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.only(right: 5, left: 5),
            child: GridView.builder(
              itemCount: radioList.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio:
                (itemWidth / itemHeight),
              ),
              controller: ScrollController(
                  keepScrollOffset: false),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      idd1 = index;
                      print('${radioList[idd1]}');
                    });
                  },
                  child: SizedBox(
                    height: 100,
                    child: Container(
                      margin: EdgeInsets.only(
                          right: 5,
                          left: 5,
                          top: 5,
                          bottom: 5),
                      height: 30,
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: (idd1 == index)
                              ? kMainColor
                              : kWhiteColor,
                          shape: BoxShape.rectangle,
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                              color: (idd1 == index)
                                  ? kMainColor
                                  : kMainColor)),
                      child: Text(
                        '${radioList[index].toString()}',
                        style: TextStyle(
                            color: (idd1 == index)
                                ? kWhiteColor
                                : kMainTextColor,
                            fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              :
          Container(
            height: 120,
            width: MediaQuery
                .of(context)
                .size
                .width,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                isFetchingTime
                    ? CircularProgressIndicator()
                    : Container(
                  width: 0.5,
                ),
                isFetchingTime
                    ? SizedBox(
                  width: 10,
                )
                    : Container(
                  width: 0.5,
                ),
                Text(
                  (isFetchingTime)
                      ? 'Fetching time slot'
                      : 'No time slot present now check other date..',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kMainTextColor),
                )
              ],
            ),
          )
        ]
    );
  }





  void addOrMinusProduct1(product_name, unit, price, quantity, itemCount,
      varient_id, index, price_d) async {
    DatabaseHelper db = DatabaseHelper.instance;
    Future<int?> existing = db.getRestProductcount(int.parse(varient_id));
    existing.then((value) {
      var vae = {
        DatabaseHelper.productId: '1',
        DatabaseHelper.storeName: product_name,
        DatabaseHelper.productName: product_name,
        DatabaseHelper.price: (price_d * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.varientId: int.parse(varient_id)
      };

      print('value we - $value');

      if (value == 0) {
        db.insertRaturantOrder(vae);
      } else {
        if (itemCount == 0) {
          db.deleteResProduct(int.parse(varient_id)).then((value) {
            db.deleteAddOn(int.parse(varient_id));
          });
        } else {
          db.updateRestProductData(vae, int.parse(varient_id));
        }
      }
      getCatC();
      if (itemCount == 0) {
        getCartItem();
      }

    });
  }

  Widget cartOrderItemListTile(
      BuildContext context,
      String title,
      dynamic price,
      int itemCount,
      dynamic qnty,
      dynamic unit,
      dynamic index,
      List<AddonCartItem> addon,
      ) {
    String selected;
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 7.0, top: 10.3),
            child: ListTile(
              // contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              title:Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: kMainTextColor),
                  ),
                  // SizedBox(width: 30,),
                  Text(
                    '${currency} ${price}',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: kMainTextColor),
                  ),
                  Container(
                    height: 30.0,
                    //width: 76.7,
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: kMainColor),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: (){
                            int addQ = int.parse(
                                '${cartListII[index].add_qnty}');
                            var price_d = double.parse(
                                '${cartListII[index].price}') /
                                addQ;
                            addQ--;
                            cartListII[index].price =
                            (price_d * addQ);
                            cartListII[index].add_qnty = addQ;
                            addOrMinusProduct1(
                                cartListII[index].product_name,
                                cartListII[index].unit,
                                cartListII[index].price,
                                cartListII[index].qnty,
                                cartListII[index].add_qnty,
                                cartListII[index].varient_id,
                                index,
                                price_d);
                          }
                          ,
                          child: Icon(
                            Icons.remove,
                            color: kMainColor,
                            size: 20.0,
                            //size: 23.3,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text('$itemCount',
                            style: Theme.of(context).textTheme.caption),
                        SizedBox(width: 8.0),
                        InkWell(
                          onTap: (){
                            int addQ = int.parse(
                                '${cartListII[index].add_qnty}');
                            var price_d = double.parse(
                                '${cartListII[index].price}') /
                                addQ;
                            addQ++;
                            cartListII[index].price =
                            (price_d * addQ);
                            cartListII[index].add_qnty = addQ;
                            addOrMinusProduct1(
                                cartListII[index].product_name,
                                cartListII[index].unit,
                                cartListII[index].price,
                                cartListII[index].qnty,
                                cartListII[index].add_qnty,
                                cartListII[index].varient_id,
                                index,
                                price_d);
                          },
                          child: Icon(
                            Icons.add,
                            color: kMainColor,
                            size: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 14.2),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 30.0,
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kCardBackgroundColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          '${qnty} ${unit}',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      // Spacer(),

                    ]),
              ),
            )),
        Visibility(
            visible: (addon != null && addon.length > 0),
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemBuilder: (context, indexd) {
                return Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${addon[indexd].addonName} ($currency ${addon[indexd].price})',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(color: kMainTextColor),
                        ),
                        IconButton(
                            icon: Icon(Icons.close),
                            iconSize: 15,
                            onPressed: () async {
                              deleteAddOn(addon[indexd].addonid);
                            })
                      ],
                    ),
                  ),
                );
              },
              itemCount: addon.length,
            ))
      ],
    );
  }


  void deleteAddOn(addonid) async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAddOnId(int.parse(addonid)).then((value) {
      getResCartItem();
      getCatC();
    });
  }


  @override
  Widget build(BuildContext context) {
    getCartItem();
    getResCartItem();
    getCatC();

    var size = MediaQuery
        .of(context)
        .size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 7;
    final double itemWidth = size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title:
        Text('Confirm Order', style: Theme
            .of(context)
            .textTheme
            .bodyText1),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
            child: TextButton(
              onPressed: () {
                if (!showDialogBox) {
                  clearCart();
                }
              },
              child: Text(
                'Clear Cart',
                style:
                TextStyle(color: kMainColor, fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
      body: (!isCartFetch && cartListI.isNotEmpty || cartListII.isNotEmpty)

          ?
      Stack(
        children: <Widget>[
          Column(
            children: [
              Expanded(
                flex: 1,
                child: ListView(
                  shrinkWrap: true,
                  primary: true,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(20.0),
                      color: kCardBackgroundColor,
                    ),

                    (cartListI.length > 0)
                        ? ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return cartOrderItemListTile1(
                            context,
                            currency,
                            '${cartListI[index].product_name}',
                            (cartListI[index].price /
                                cartListI[index].add_qnty),
                            cartListI[index].add_qnty,
                            cartListI[index].qnty,
                            cartListI[index].unit,
                            cartListI[index].store_name,
                            cartListI[index].is_id,
                            cartListI[index].is_pres,
                            index,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: kCardBackgroundColor,
                            thickness: 1.0,
                          );
                        },
                        itemCount: cartListI.length)
                        : Container(),

                    (cartListII.isNotEmpty)
                        ?
                    ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return cartOrderItemListTile(
                            context,
                            '${cartListII[index].product_name}',
                            (double.parse(
                                '${cartListII[index].price}') /
                                int.parse(
                                    '${cartListII[index].add_qnty}')),
                            int.parse('${cartListII[index].add_qnty}'),
                            cartListII[index].qnty,
                            cartListII[index].unit,
                            index,
                            // plus(index),
                            cartListII[index].addon,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: kCardBackgroundColor,
                            thickness: 1.0,
                          );
                        },
                        itemCount: cartListII.length)
                        : Container(),

                    Divider(
                      color: kCardBackgroundColor,
                      thickness: 6.7,
                    ),

                    (cartListI.isNotEmpty)
                        ?
                    timewidget(context, itemHeight, itemWidth)
                        :
                    Container(),

                    Divider(
                      color: kCardBackgroundColor,
                      thickness: 6.7,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 20.0),
                      child: Text('PAYMENT INFO',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: kDisabledColor)),
                      color: Colors.white,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 20.0),
                      child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Sub Total',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption,
                            ),
                            Text(
                              '$currency ${totalAmount - deliveryCharge}',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption,
                            ),
                          ]),
                    ),
                    Divider(
                      color: kCardBackgroundColor,
                      thickness: 1.0,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 20.0),
                      child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Service Fee',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption,
                            ),
                            Text(
                              '$currency $deliveryCharge',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption,
                            ),
                          ]),
                    ),
                    Divider(
                      color: kCardBackgroundColor,
                      thickness: 1.0,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 20.0),
                      child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Amount to Pay',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$currency $totalAmount',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption,
                            ),
                          ]),
                    ),
                    Container(
                      height: 15.0,
                      color: kCardBackgroundColor,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                            top: 13.0,
                            bottom: 13.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  color: Color(0xffc4c8c1),
                                  size: 13.3,
                                ),
                                SizedBox(
                                  width: 11.0,
                                ),
                                Text('Deliver to',
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                        color: kDisabledColor,
                                        fontWeight: FontWeight.bold)),
                                Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    SharedPreferences prefs =
                                    await SharedPreferences
                                        .getInstance();
                                    String? vendorId =
                                    prefs.getString('vendor_id');
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) {
                                              return SavedAddressesPage(
                                                  vendorId);
                                            })).then((value) {
                                      getAddress(context);
                                    });
                                  },
                                  child: Text('CHANGE',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                          color: kMainColor,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 13.0,
                            ),
                            Text(
                                '${addressDelivery?.address != null
                                    ? '${addressDelivery?.address})'
                                    : ''} \n ${(addressDelivery
                                    ?.delivery_charge != null) ? addressDelivery
                                    ?.delivery_charge : ''}'
                                ,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                    fontSize: 11.7,
                                    color: Color(0xffb7b7b7)))
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            primary: kMainColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 150, vertical: 20),
                            textStyle: TextStyle(color: kWhiteColor,
                                fontWeight: FontWeight.w400)),

                        onPressed: () {
                          if (cartListI.isNotEmpty) {
                            createCart(context);
                          }

                          else if (cartListII.isNotEmpty) {
                            createResCart(context);
                          }
                        },
                        child: Text("Pay $currency "
                            "$totalAmount")
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(
              child: Visibility(
                visible: showDialogBox,
                child: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height - 100,
                    alignment: Alignment.center,
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              )),
        ],
      )
          : Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height - 64,
        alignment: Alignment.center,
        child: isCartFetch
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'No item in cart\nClick to shop now',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  primary: kMainColor,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(
                      color: kWhiteColor, fontWeight: FontWeight.w400)),

              onPressed: () {
                // clearCart();
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                      return HomeOrderAccount();
                    }), (Route<dynamic> route) => false);
              },
              child: Text(
                'Shop Now',
                style: TextStyle(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w400),
              ),
            )
          ],
        ),
      ),
    );
  }

  void createResCart(BuildContext context) async {
    if (cartListII != null && cartListII.length > 0) {
      if (totalAmount != null && totalAmount > 0.0 && addressDelivery != null) {
        var url = returant_order;
        SharedPreferences pref = await SharedPreferences.getInstance();
        int? userId = pref.getInt('user_id');
        String? vendorId = pref.getString('res_vendor_id');
        String? ui_type = pref.getString("ui_type");
        List<OrderArray> orderArray = [];
        List<OrderAdonArray> orderAddonArray = [];
        for (RestaurantCartItem item in cartListII) {
          orderArray.add(OrderArray(
              int.parse('${item.add_qnty}'), int.parse('${item.varient_id}')));
          if (item.addon.length > 0) {
            for (AddonCartItem addItem in item.addon) {
              orderAddonArray
                  .add(OrderAdonArray(int.parse('${addItem.addonid}')));
            }
          }
        }

        print(
            '$userId $vendorId ${orderArray.toString()} ${orderAddonArray
                .toString()}');

        Uri myUri = Uri.parse(url);
        http.post(myUri, body: {
          'user_id': '${userId}',
          'vendor_id': vendorId,
          'order_array': orderArray.toString(),
          'order_array1':
          (orderAddonArray.length > 0) ? orderAddonArray.toString() : '',
          'ui_type': ui_type
        }).then((value) {
          print('${value.statusCode} ${value.body}');
          if (value != null && value.statusCode == 200) {
            var jsonData = jsonDecode(value.body);
            if (jsonData['status'] == "1") {
              // Toast.show(jsonData['message'], context,
              //     duration: Toast.LENGTH_SHORT);
              CartDetail details = CartDetail.fromJson(jsonData['data']);
              getVendorPayment(vendorId!, details);
            } else {
              // Toast.show(jsonData['message'], context,
              //     duration: Toast.LENGTH_SHORT);
              setState(() {
                showDialogBox = false;
              });
            }
//        print('resp value - ${value.body}');

          } else {
            setState(() {
              showDialogBox = false;
            });
          }
        }).catchError((_) {
          setState(() {
            showDialogBox = false;
          });
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
        if (addressDelivery != null) {
          // Toast.show('Please add something in your cart to proceed!', context,
          //     duration: Toast.LENGTH_SHORT);
        } else {
          // Toast.show('Please add your delivery address to continue shopping..',
          //     context,
          //     duration: Toast.LENGTH_SHORT);
        }
      }
    } else {
      setState(() {
        showDialogBox = false;
      });
      // Toast.show('Please add some items into cart!', context,
      //     duration: Toast.LENGTH_SHORT);
    }
  }

  void getVendorPayment(String vendorId, CartDetail details) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency')!;
    });
    var url = paymentvia;
    var client = http.Client();
    Uri myUri = Uri.parse(url);

    client.post(myUri, body: {'vendor_id': '${vendorId}'}).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<PaymentVia> tagObjs = tagObjsJson
              .map((tagJson) => PaymentVia.fromJson(tagJson))
              .toList();

          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return PaymentRestPage(vendorId, details.order_id, details.cart_id,
                double.parse(details.total_price.toString()), tagObjs);
          }));
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void createCart(BuildContext context) async {
    if (cartListI.length > 0) {
      if (radioList.length > 0) {
        if (totalAmount > 0.0) {
          var url = addToCart;
          SharedPreferences pref = await SharedPreferences.getInstance();
          int? userId = pref.getInt('user_id');
          String? vendorId = pref.getString('vendor_id');
          String? ui_type = pref.getString("ui_type");
          List<OrderArrayGrocery> orderArray = [];
          for (CartItem item in cartListI) {
            orderArray.add(OrderArrayGrocery(int.parse('${item.add_qnty}'),
                int.parse('${item.varient_id}')));
          }

          Uri myUri = Uri.parse(url);
          http.post(myUri, body: {
            'user_id': userId.toString(),
            'vendor_id': vendorId,
            'order_array': orderArray.toString(),
            'delivery_date': dateTimeSt,
            'time_slot': '${radioList[idd1]}',
            'ui_type': ui_type
          }).then((value) {
            print('order' + value.body);
            if (value.statusCode == 200) {
              var jsonData = jsonDecode(value.body);
              if (jsonData['status'] == "1") {
                // Toast.show(jsonData['message'], context,
                //     duration: Toast.LENGTH_SHORT);
                CartDetail details = CartDetail.fromJson(jsonData['data']);
                getVendorPayment2(vendorId!, details, orderArray.toString());
              } else {
                // Toast.show(jsonData['message'], context,
                //     duration: Toast.LENGTH_SHORT);
                setState(() {
                  showDialogBox = false;
                });
              }
            } else {
              setState(() {
                showDialogBox = false;
              });
            }
          }).catchError((_) {
            setState(() {
              showDialogBox = false;
            });
          });
        } else {
          setState(() {
            showDialogBox = false;
          });
          if (addressDelivery != null) {
            // Toast.show('Please add something in your cart to proceed!', context,
            //     duration: Toast.LENGTH_SHORT);
          } else {
            // Toast.show(
            //     'Please add your delivery address to continue shopping..',
            //     context,
            //     duration: Toast.LENGTH_SHORT);
          }
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
        // Toast.show('Please select a delivery time to continue!', context,
        //     duration: Toast.LENGTH_SHORT);
      }
    } else {
      setState(() {
        showDialogBox = false;
      });
      // Toast.show('Please add some items into cart!', context,
      //     duration: Toast.LENGTH_SHORT);
    }
  }

  void getVendorPayment2(String vendorId, CartDetail details,
      String orderArray) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency')!;
    });
    var url = paymentvia;
    var client = http.Client();
    Uri myUri = Uri.parse(url);

    client.post(myUri, body: {'vendor_id': '${vendorId}'}).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<PaymentVia> tagObjs = tagObjsJson
              .map((tagJson) => PaymentVia.fromJson(tagJson))
              .toList();

          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return PaymentPage(
                vendorId,
                details.order_id,
                details.cart_id,
                double.parse(details.total_price.toString()),
                tagObjs,
                orderArray);
          }));
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void addOrMinusProduct(store_name, product_name, unit, price, quantity,
      itemCount,
      varient_image, varient_id, index, price_d) async {
    DatabaseHelper db = DatabaseHelper.instance;
    Future<int?> existing = db.getcount(int.parse(varient_id));
    existing.then((value) {
      var vae = {
        DatabaseHelper.productName: product_name,
        DatabaseHelper.storeName: store_name,
        DatabaseHelper.price: (price_d * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.productImage: varient_image,
        DatabaseHelper.varientId: int.parse(varient_id)
      };
      if (value == 0) {
        db.insert(vae);
      } else {
        if (itemCount == 0) {
          db.delete(int.parse(varient_id));
        } else {
          db.updateData(vae, int.parse(varient_id));
        }
      }
      getCatC();
      setState(() {
        if (itemCount == 0) {
          getCartItem();
        }
      });
    });
  }

  Widget cartOrderItemListTile1(BuildContext context,
      currency,
      String title,
      dynamic price,
      int itemCount,
      int qnty,
      dynamic unit,
      dynamic store_name,
      dynamic is_id,
      dynamic is_pres,
      dynamic index) {
    String selected;
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 7.0, top: 13.3),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    store_name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: kMainTextColor),
                  ),

                  Text(
                    title,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: kMainTextColor),
                  ),

                  Text(
                    '${currency} ${price}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: kMainTextColor),
                  ),

                  (is_id == 1) ?
                      new GestureDetector(
                        onTap: (){_settingModalBottomSheet(context);},

                  child: Container(
                    height: 30.0,
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kCardBackgroundColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      'Upload ID Proof',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),

                  )
                      )
                      :
                  Container(

                  ),
                  (is_pres == 1) ?
                  new GestureDetector(
                      onTap: (){_settingModalBottomSheet(context);},

                      child:
                      Container(
                    height: 30.0,
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kCardBackgroundColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      'Upload Prescription',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),

                  )
                  )
                      :
                  Container(
                  ),

                ],

              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 14.2),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      Container(
                        height: 30.0,
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kCardBackgroundColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          '${qnty} ${unit}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .caption,
                        ),

                      ),
                      Container(
                        height: 30.0,
                        //width: 76.7,
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: kMainColor),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  var price_d = cartListI[index].price /
                                      cartListI[index].add_qnty;
                                  cartListI[index].add_qnty--;
                                  cartListI[index].price = (price_d *
                                      cartListI[index].add_qnty);
                                  addOrMinusProduct(
                                      cartListI[index].store_name,
                                      cartListI[index].product_name,
                                      cartListI[index].unit,
                                      cartListI[index].price,
                                      cartListI[index].qnty,
                                      cartListI[index].add_qnty,
                                      cartListI[index].product_img,
                                      cartListI[index].varient_id,
                                      index,
                                      price_d);
                                });
                              },
                              child: Icon(
                                Icons.remove,
                                color: kMainColor,
                                size: 20.0,
                                //size: 23.3,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text('$itemCount',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption),
                            SizedBox(width: 8.0),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  var price_d = cartListI[index].price /
                                      cartListI[index].add_qnty;
                                  cartListI[index].add_qnty++;
                                  cartListI[index].price = (price_d *
                                      cartListI[index].add_qnty);
                                  addOrMinusProduct(
                                      cartListI[index].store_name,
                                      cartListI[index].product_name,
                                      cartListI[index].unit,
                                      cartListI[index].price,
                                      cartListI[index].qnty,
                                      cartListI[index].add_qnty,
                                      cartListI[index].product_img,
                                      cartListI[index].varient_id,
                                      index,
                                      price_d);
                                });
                              },
                              child: Icon(
                                Icons.add,
                                color: kMainColor,
                                size: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Spacer(),
                    ]),
              ),

            ))
      ],
    );
  }
  //********************** IMAGE PICKER
  Future imageSelector(BuildContext context, String pickerType) async {
    XFile? imageFile = null;
    ImagePicker picker = new ImagePicker();
    switch (pickerType) {
      case "gallery":

      /// GALLERY IMAGE PICKER
        imageFile = (await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 90));
        break;

      case "camera": // CAMERA CAPTURE CODE
        imageFile = (await picker.pickImage(
            source: ImageSource.camera, imageQuality: 90));
        break;
    }

    if (imageFile != null) {
      print("You selected  image : " + imageFile.path);
      setState(() {
        debugPrint("SELECTED IMAGE PICK   $imageFile");
      });
    } else {
      print("You have not taken image");
    }
  }

  // Image picker
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    title: new Text('Gallery'),
                    onTap: () => {
                      imageSelector(context, "gallery"),
                      Navigator.pop(context),
                    }),
                new ListTile(
                  title: new Text('Camera'),
                  onTap: () => {
                    imageSelector(context, "camera"),
                    Navigator.pop(context)
                  },
                ),
              ],
            ),
          );
        });
  }

  void hitDateCounter(date) async {
    setState(() {
      isFetchingTime = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? vendorId = pref.getString('vendor_id');
    var url = timeSlots;
    Uri myUri = Uri.parse(url);
    http.post(myUri,
        body: {'vendor_id': vendorId, 'selected_date': '$date'}).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var rdlist = jsonData['data'] as List;
          print('list $rdlist');
          setState(() {
            radioList.clear();
            radioList = rdlist;
          });
        } else {
          setState(() {
            radioList = [];
          });
          // Toast.show(jsonData['message'], context,
          //     duration: Toast.LENGTH_SHORT);
        }
      } else {
        setState(() {
          radioList = [];
          // radioList = rdlist;
        });
      }
      setState(() {
        isFetchingTime = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchingTime = false;
      });
      print(e);
    });
  }

  void clearCart() async {
    setState(() {
      isCartFetch = true;
    });
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAll().then((value) {
      cartListI.clear();
      getCartItem();
      getCatC();
    });

    db.deleteAllRestProdcut().then((value) {
      db.deleteAllAddOns().then((values) {
        cartListII.clear();
        getResCartItem();
        getCatC();
      });
    });
  }
}