import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/nearstorebean.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/restaturantui/pages/restaurant.dart';

class ResturantPageList extends StatefulWidget {
  final dynamic currencySymbol;

  ResturantPageList(this.currencySymbol);

  @override
  State<StatefulWidget> createState() {
    return ResturantPageState();
  }

}

class ResturantPageState extends State<ResturantPageList> {
  bool isCartCount = false;

  var cartCount = 0;
  double userLat = 0.0;
  double userLng = 0.0;
  bool isFetchStore = false;
  List<NearStores> nearStores = [];
  List<NearStores> nearStoresSearch = [];

  initState() {
    getShareValue();
    super.initState();
    hitService();
    getCartCount();
  }

  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowCountRest().then((value) {
      setState(() {
        if (value != null && value > 0) {
          cartCount = value;
          isCartCount = true;
        } else {
          cartCount = 0;
          isCartCount = false;
        }
      });
    });
  }

  void hitService() async {
    setState(() {
      isFetchStore = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
        'data - ${prefs.getString('lat')} - ${prefs.getString('lng')} - ${prefs
            .getString('vendor_cat_id')} - ${prefs.getString('ui_type')}');
    var url = nearByStore;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'lat': '${prefs.getString('lat')}',
      'lng': '${prefs.getString('lng')}',
      'vendor_category_id': '${prefs.getString('vendor_cat_id')}',
      'ui_type': '${prefs.getString('ui_type')}'
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        print('Response Body: - ${value.body}');
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<NearStores> tagObjs = tagObjsJson
              .map((tagJson) => NearStores.fromJson(tagJson))
              .toList();
          setState(() {
            isFetchStore = false;
            nearStores.clear();
            nearStoresSearch.clear();
            nearStores = tagObjs;
            nearStoresSearch = List.from(nearStores);
          });
        } else {
          setState(() {
            isFetchStore = false;
          });
        }
      } else {
        setState(() {
          isFetchStore = false;
        });
      }
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
      Timer(Duration(seconds: 5), () {
        hitService();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: CustomAppBar(
          titleWidget: Text(
            "Restaurant",
            style: Theme
                .of(context)
                .textTheme
                .bodyText1,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Stack(
                children: [
                  IconButton(
                      icon: ImageIcon(
                        AssetImage('images/icons/ic_cart blk.png'),
                      ),
                      onPressed: () {
                        if (isCartCount) {
                          Navigator.pushNamed(context, PageRoutes.restviewCart)
                              .then((value) {
                            // getCartCount();
                          });
                        } else {
                          Toast.show('No Value in the cart!', duration: Toast.lengthShort, gravity:  Toast.bottom);
                        }
                      }),
                  Positioned(
                      right: 5,
                      top: 2,
                      child: Visibility(
                        visible: isCartCount,
                        child: CircleAvatar(
                          minRadius: 4,
                          maxRadius: 8,
                          backgroundColor: kMainColor,
                          child: Text(
                            '$cartCount',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 7,
                                color: kWhiteColor,
                                fontWeight: FontWeight.w200),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.85,
                height: 52,
                padding: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                    color: scaffoldBgColor,
                    borderRadius: BorderRadius.circular(50)),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: kHintColor,
                    ),
                    hintText: 'Search restaurant...',
                  ),
                  cursorColor: kMainColor,
                  autofocus: false,
                  onChanged: (value) {
                    nearStores = nearStoresSearch
                        .where((element) =>
                        element.vendor_name
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  },
                ),
              ),
              preferredSize:
              Size(MediaQuery
                  .of(context)
                  .size
                  .width * 0.85, 52)),
        ),
      ),
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height - 110,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child:

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20.0),
                child: Text(
                  '${nearStores.length} Restaurant found',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: kHintColor, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              (nearStores != null && nearStores.length > 0)
                  ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    scrollDirection: Axis.vertical,
                    itemCount: nearStores.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // hitNavigator(context, nearStores[index]);
                          if((nearStores[index].online_status == "on" || nearStores[index].online_status == "On" || nearStores[index].online_status == "ON")){
                            hitNavigator(context, nearStores[index]);
                          }else{
                            Toast.show('Restaurant are closed now!', duration: Toast.lengthShort, gravity:  Toast.bottom);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Material(
                          elevation: 2,
                          shadowColor: white_color,
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                color: white_color,
                                padding: EdgeInsets.only(
                                    left: 20.0, top: 15, bottom: 15),
                                child: Row(
                                  children: <Widget>[
                                    Image.network(
                                      imageBaseUrl +
                                          nearStores[index].vendor_logo,
                                      width: 93.3,
                                      height: 93.3,
                                    ),
                                    SizedBox(width: 13.3),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(nearStores[index].vendor_name,
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(
                                                color: kMainTextColor,
                                                fontSize: 18)),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.location_on,
                                              color: kIconColor,
                                              size: 15,
                                            ),
                                            SizedBox(width: 10.0),
                                            Text(
                                                '${double.parse(
                                                    '${nearStores[index].distance}')
                                                    .toStringAsFixed(2)} km ',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    color:
                                                    kLightTextColor,
                                                    fontSize: 13.0)),
                                            Text('|',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    color: kMainColor,
                                                    fontSize: 13.0)),
                                            Text(
                                                '${nearStores[index].vendor_loc}',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    color:
                                                    kLightTextColor,
                                                    fontSize: 13.0)),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.access_time,
                                              color: kIconColor,
                                              size: 15,
                                            ),
                                            SizedBox(width: 10.0),
                                            Text('${calculateTime(double.parse('${nearStores[index].lat}'), double.parse('${nearStores[index].lng}'), userLat, userLng)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    color:
                                                    kLightTextColor,
                                                    fontSize: 13.0)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                child: Visibility(
                                  visible: (nearStores[index].online_status == "off" || nearStores[index].online_status == "Off" || nearStores[index].online_status == "OFF")?true:false,
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width-10,
                                    alignment: Alignment.center,
                                    color: kCardBackgroundColor,
                                    child: Text('Store Closed Now',style: TextStyle(
                                        color: red_color
                                    ),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 10,
                      );
                    }),
              )
                  : Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isFetchStore ? CircularProgressIndicator() : Container(
                      width: 0.5,),
                    isFetchStore ? SizedBox(
                      width: 10,
                    ) : Container(width: 0.5,),
                    Text(
                      (!isFetchStore)
                          ? 'No Store Found at your location'
                          : 'Fetching Stores',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kMainTextColor),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  hitNavigator(BuildContext context, NearStores item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isCartCount && prefs.getString("res_vendor_id") != null &&
        prefs.getString("res_vendor_id") != "" &&
        prefs.getString("res_vendor_id") != '${item.vendor_id}') {
      //showAlertDialog(context, item, widget.currencySymbol);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Restaurant_Sub(item, widget.currencySymbol))).then((value){
        getCartCount();
      });

    } else {
      prefs.setString("res_vendor_id", '${item.vendor_id}');
      prefs.setString("store_resturant_name", '${item.vendor_name}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Restaurant_Sub(item, widget.currencySymbol))).then((value){
                    getCartCount();
      });
    }
  }

  showAlertDialog(BuildContext context, NearStores item, currencySymbol) {
    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        deleteAllRestProduct(context, item, currencySymbol);
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
          padding: EdgeInsets.only(left:20, right:20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: red_color,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text(
            'Clear', style: TextStyle(fontSize: 13, color: kWhiteColor),),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
          padding: EdgeInsets.only(left:20, right:20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: kGreenColor,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text(
            'No', style: TextStyle(fontSize: 13, color: kWhiteColor),),
        ),
      ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Inconvenience Notice"),
      content: Text(
          "Order from different store in single order is not allowed. Sorry for inconvenience"),
      actions: [
        clear,
        no
      ],
    );


    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deleteAllRestProduct(BuildContext context, NearStores item,
      currencySymbol) async {
    DatabaseHelper database = DatabaseHelper.instance;
    database.deleteAllRestProdcut();
    database.deleteAllAddOns();
    getCartCount();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("res_vendor_id", '${item.vendor_id}');
    prefs.setString("store_resturant_name", '${item.vendor_name}');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Restaurant_Sub(item, currencySymbol))).then((value){
              getCartCount();
    });
  }

  getShareValue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userLat = double.parse('${prefs.getString('lat')}');
      userLng = double.parse('${prefs.getString('lng')}');
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  String calculateTime(lat1, lon1, lat2, lon2){
    double kms = calculateDistance(lat1, lon1, lat2, lon2);
    double kms_per_min = 0.5;
    double mins_taken = kms / kms_per_min;
    double min = mins_taken;
    if (min<60) {
      return ""+'${min.toInt()}'+" mins";
    }else {
      double tt = min % 60;
      String minutes = '${tt.toInt()}';
      minutes = minutes.length == 1 ? "0" + minutes : minutes;
      return '${(min.toInt() / 60)}' + " hour " + minutes +"mins";
    }
  }

}