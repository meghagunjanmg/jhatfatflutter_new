import 'dart:convert';

import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jhatfat/bean/adminsetting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/account_page.dart';
import 'package:jhatfat/HomeOrderAccount/Order/UI/order_page.dart';
import 'package:jhatfat/HomeOrderAccount/offer/ui/offerui.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/restaturantui/ui/resturanthome.dart';

import '../Pages/oneViewCart.dart';
import '../bean/bannerbean.dart';
import '../parcel/ParcelLocation.dart';
import 'Home/UI/home2.dart';

class HomeStateless extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeOrderAccount(),
    );
  }
}

class HomeOrderAccount extends StatefulWidget {
  @override
  _HomeOrderAccountState createState() => _HomeOrderAccountState();
}

class _HomeOrderAccountState extends State<HomeOrderAccount> {
  int _currentIndex = 0;
  double bottomNavBarHeight = 60.0;
  late CircularBottomNavigationController _navigationController;
  String ClosedImage = '';
  List<BannerDetails> ClosedBannerImage = [];
  Adminsetting? admins;
  @override
  void initState() {
    calladminsetting();
    _navigationController =
    new CircularBottomNavigationController(_currentIndex);
    getCurrency();
    _getLocation(context);
    ClosedBanner();

    super.initState();
  }


  Future<void> calladminsetting() async {
    var url = adminsettings;
    Uri myUri = Uri.parse(url);
    var value = await http.get(myUri);
    var jsonData = jsonDecode(value.body.toString());
    if (jsonData['status'] == "1") {
        admins = Adminsetting.fromJson(jsonData['data']);
        print("ADMIN RES: " + admins!.cityadminId.toString());

    }
  }

  Future<void> ClosedBanner() async {
    var url2 = closed_banner;
    Uri myUri2 = Uri.parse(url2);
    var response = await http.get(myUri2);
    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          setState(() {
            ClosedBannerImage.clear();
            ClosedBannerImage = tagObjs;
            ClosedImage = imageBaseUrl + tagObjs[0].bannerImage;
          });
        }
      }
    } on Exception catch (_) {

    }
  }


  void getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencyUrl = currencyuri;

    var client = http.Client();
    Uri myUri = Uri.parse(currencyUrl);
    client.get(myUri).then((value) {
      var jsonData = jsonDecode(value.body);
      if (value.statusCode == 200 && jsonData['status'] == "1") {
        preferences.setString(
            'curency', '${jsonData['data'][0]['currency_sign']}');
      }
    }).catchError((e) {
      print(e);
    });
  }

  List<TabItem> tabItems = List.of([
    new TabItem(Icons.home, "Home", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
     new TabItem(Icons.restaurant, "Resturant", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
   ///  new TabItem(Icons.reorder, "Order", Colors.blue,labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
     new TabItem(Icons.pin_drop, "Pick & Drop", Colors.blue,labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
     new TabItem(Icons.shopping_cart, "Cart", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 10)),
  ]);

  final List<Widget> _children = [
     HomePage2(),
     Restaurant("Urbanby Resturant"),
     ///OrderPage(),
     ParcelLocation(),

        oneViewCart(),
    // ViewCart(),

  ];

  void onTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      (admins!.status==1)?
     Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: bottomNav(context),
    )
        :

      Scaffold(
        body: Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: white_color,
          borderRadius:
          BorderRadius.circular(20.0),
        ),
        child: Image.network(
          ClosedImage,
          fit: BoxFit.fill,
        ),
      ),
        ),
    );
  }

  Widget bottomNav(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: kWhiteColor,
      child: CircularBottomNavigation(
        tabItems,
        controller: _navigationController,
        barHeight: 45,
        circleSize: 40,
        barBackgroundColor: kWhiteColor,
        iconsSize: 20,
        circleStrokeWidth: 5,
        animationDuration: const Duration(milliseconds: 300),
        selectedCallback: (int? selectedPos) {
          setState(() {
            _currentIndex = selectedPos!;
          });
        },
      ),
    );
  }

  void _getLocation(context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("vendor_cat_id", '12');
      prefs.setString("ui_type","2");



    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        double lat = position.latitude;
        double lng = position.longitude;
        prefs.setString("lat", lat.toStringAsFixed(8));
        prefs.setString("lng", lng.toStringAsFixed(8));

        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        prefs.setString("addr", placemarks.elementAt(0).locality.toString());


      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation(context);
          } else {
            // Toast.show('Location permission is required!', context,
            //     duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          // Toast.show('Location permission is required!', context,
          //     duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation(context);
      } else {
        // Toast.show('Location permission is required!', context,
        //     duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation(context);
      }).catchError((e) {
        // Toast.show('Location permission is required!', context,
        //     duration: Toast.LENGTH_SHORT);
      });
    }
  }


}
