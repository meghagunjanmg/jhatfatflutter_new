import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/Components/list_tile.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/saved_addresses_page.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/parcel/PickMap.dart';
import 'package:jhatfat/parcel/parcel_details.dart';

import 'checkoutparcel.dart';


class ParcelLocation extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SetLocation();
  }
}

class SetLocation extends StatefulWidget {

  SetLocation();

  @override
  SetLocationState createState() => SetLocationState();

}

class AddressTile1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(
            vertical: 2.0, horizontal: 20.0),
        leading: Image.asset(
          'images/ic_pickup pointact.png',
          height: 20.3,
        ),
        title: Text(
          'Sender Address',
          style: Theme
              .of(context)
              .textTheme
              .headline4!
              .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.07),
        ),
        onTap: () {
          Navigator.pushNamed(context, PageRoutes.pickmap);
        }
    );
  }
}

class AddressTile2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(
            vertical: 2.0, horizontal: 20.0),
        leading: Image.asset(
          'images/ic_pickup pointact.png',
          height: 20.3,
        ),
        title: Text(
          'Reciever Address',
          style: Theme
              .of(context)
              .textTheme
              .headline4!
              .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.07),
        ),
        onTap: () {
          Navigator.pushNamed(context, PageRoutes.dropmap);
        }
    );
  }
}


  class SetLocationState extends State<SetLocation> {
  bool value = false;
  String pickup = '';
  String pickuplat = '';
  String pickuplng = '';

  String drop = '';
  String droplat = '';
  String droplng = '';
  final parcelcontroler = TextEditingController();
  final instructioncontroler = TextEditingController();


  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pickupaddress = prefs.getString("pickupLocation");
    String? dropaddress = prefs.getString("dropLocation");

    String? dropaddresslat = prefs.getString("dlt");
    String? dropaddresslng = prefs.getString("dln");

    String? pickaddresslat = prefs.getString("plt");
    String? pickaddresslng = prefs.getString("pln");

    // print(pickaddresslat);
    // print(pickaddresslng);


    setState(() {
      if(pickupaddress==null){
        pickup = "";
        pickuplat = "";
        pickuplng = "";
      }
      else {
        pickup = pickupaddress;
        pickuplat = pickaddresslat!;
        pickuplng = pickaddresslng!;
      }

        if(dropaddress==null){
          drop = "";

          droplat = "";
          droplng = "";
        }
        else {
          drop = dropaddress;

          droplat = dropaddresslat!;
          droplng = dropaddresslng!;
        }

    });
  }


  SetLocationState();

  @override
  void initState() {
    super.initState();

    getData();
  }


  @override
  void dispose() {
    super.dispose();
    parcelcontroler.dispose();
    instructioncontroler.dispose();

  }

  @override
  Widget build(BuildContext context) {
    getData();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: CustomAppBar(
          titleWidget: Text(
            'Set Pick & Drop Location',
            style: TextStyle(fontSize: 16.7, color: black_color),
          ),
        ),
      ),
      body:
      SafeArea(
    child:
    SingleChildScrollView(
    child:
    Padding(
    padding: const EdgeInsets.only(left: 18.0,right: 18.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:  EdgeInsets.only(left: 18.0,right: 18.0),
          child: AddressTile1(),
        ),

        Padding(
          padding: EdgeInsets.only(left: 18.0,right: 18.0,bottom: 18.0),
          child: Text(          "Pickup Address: "+ '${pickup}',
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          style:
          TextStyle(color: Colors.black, fontSize: 14),
        ),
        ),

      Padding(
        padding:  EdgeInsets.only(left: 18.0,right: 18.0),
        child: AddressTile2(),
      ),

      Padding(
        padding: EdgeInsets.only(left: 18.0,right: 18.0,bottom: 18.0),
        child: Text(
          "Drop Address: "+ '${drop}',
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          style:
          TextStyle(color: Colors.black, fontSize: 14),
        ),
      ),
        Padding(
          padding: EdgeInsets.all(18.0),
          child: TextField(
            controller: parcelcontroler,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter Package Content',

            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.all(18.0),
          child: TextField(
            controller: instructioncontroler,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Image.asset(
                "images/custom/ic_instruction.png",
                height: 10.3,
              ),
              contentPadding:EdgeInsets.all(20.0),
              hintText: ' Any Instruction? (Do not ring bell)',
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 200,left: 50,right: 50),
        ),
        Container(
          alignment: Alignment.center,
          height: 50,
          child:
          Row(
            children:
          <Widget>[
                Checkbox(
                  value: this.value,
                  onChanged: (bool? value) {
                    setState(() {
                      this.value = value!;
                    });
                  },
                ),
          new GestureDetector(
              onTap: (){
                        Navigator.pushNamed(context, PageRoutes.tncPage);
              },
           child: RichText(
              text: TextSpan(
                text: "By confirming i accept this order does not contain illegal/restricted items.\nDelivery partner may ask to verify the contents of the package and could \nchoose to refuse the task if the items are not verified",
                style: TextStyle(color: Colors.black, fontSize: 12),
                children: <TextSpan>[
                  TextSpan(text: ' Terms & Condition', style: TextStyle( fontSize: 12,color: Colors.green)),
                ],
              ),
            ),
          ),

                  // new GestureDetector(
                  //   onTap: (){
                  //
                  //   },
                  //   child: Flexible(
                  //       child:
                  //       RichText(
                  //         overflow: TextOverflow.ellipsis,
                  //         text: TextSpan(
                  //           text: 'By confirming i accept this order does not contain illegal/restricted items.Delivery partner may ask to verify the contents of the package and could choose to refuse the task if the items are not verified',
                  //           style: TextStyle(fontSize: 12,color: Colors.black),
                  //           children: const <TextSpan>[
                  //             TextSpan(text: 'Terms ', style: TextStyle(fontSize: 12, color: Colors.black)),
                  //           ],
                  //         ),
                  //       )
                  //       // new Text(,
                  //       //   style: TextStyle(fontSize: 12),
                  //       // ),
                  //   ),
                  // )

              ],  //Text// Checkbox
            ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
        child: (value) ?
        Container(
          alignment: Alignment.center,
          height: 150,
          child:
          ElevatedButton(
            style:
            ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20,horizontal: 100)),
              backgroundColor:
              MaterialStateProperty.all<Color>(kMainColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ParcelDetails(
                          54,
                          "jhatfat",
                          22,
                          pickup,
                          pickuplat,
                          pickuplng,
                          drop,
                          droplat,
                          droplng,
                          "id",
                          20,
                          20.000000)));
            },
          child: Text(
            'Continue',
            style:
            TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400),
          ),
        )
        )
            :
        Container(
          alignment: Alignment.center,
            height: 150,
            child:
            ElevatedButton(
            style:
              ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20,horizontal: 100)),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
              ),),

    onPressed: () {

    },
    child: Text(
    'Continue',
    style:
    TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400),
    ),
    ),
        ),
        ),
    ],

    ),
      )
    )
      )
    );
  }


  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  }
