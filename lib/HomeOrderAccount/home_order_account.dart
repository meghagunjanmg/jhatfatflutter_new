import 'dart:convert';

import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/account_page.dart';
import 'package:jhatfat/HomeOrderAccount/Order/UI/order_page.dart';
import 'package:jhatfat/HomeOrderAccount/offer/ui/offerui.dart';
import 'package:jhatfat/Pages/view_cart.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/restaturantui/ui/resturanthome.dart';

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

  @override
  void initState() {
    _navigationController =
        new CircularBottomNavigationController(_currentIndex);
    getCurrency();
    _getLocation(context);
    super.initState();
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
    new TabItem(Icons.home, "Home", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 12)),
     new TabItem(Icons.restaurant, "Resturant", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 12)),
     new TabItem(Icons.reorder, "Order", Colors.blue,labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 12)),
    // new TabItem(Icons.account_circle, "Account", Colors.blue,labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 12)),
     new TabItem(Icons.shopping_cart, "Cart", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
  ]);

  final List<Widget> _children = [
     HomePage2(),
     Restaurant("Urbanby Resturant"),
     OrderPage(),
     //AccountPage(),
     ViewCart(),

  ];

  void onTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: bottomNav(context),
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
        //double lat = 29.006057;
        double lng = position.longitude;
        //double lng = 77.027535;
        prefs.setString("lat", lat.toStringAsFixed(8));
        prefs.setString("lng", lng.toStringAsFixed(8));

        print("LATLONG"+lat.toString()+lng.toString());
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

        print("LATLONG"+placemarks.toString());

        placemarks.map((e) =>
        {
          prefs.setString("currentloc", (e.locality.toString())+(e.administrativeArea.toString()))
        });

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
