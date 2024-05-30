// ignore_for_file: camel_case_types, implementation_imports, prefer_const_constructors, must_be_immutable, unused_import

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/Customer_Profile.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:photo_view/photo_view.dart';

class customers_image extends StatelessWidget {
  AllCustomers customers;
  customers_image(this.customers);
  ThemeController _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.6, color: colorOfApp),
          borderRadius: BorderRadius.circular(15),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * .6,
          height: MediaQuery.of(context).size.height * .36,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          backgroundColor: Colors.transparent,
                          appBar: AppBar(
                            title: Text(
                              customers.cname,
                              style: TextStyle(
                                letterSpacing: 0.4,
                                fontSize: 17,
                              ),
                            ),
                            centerTitle: false,
                            elevation: 0.5,
                            backgroundColor: colorOfApp,
                          ),
                          body: Material(
                            color: Colors.transparent,
                            child: Container(
                              child: customers.cimage != ""
                                  ? PhotoView(
                                      maxScale: 4.0,
                                      minScale: 0.1,
                                      imageProvider: NetworkImage(
                                          Myurl.fullurl +
                                              Myurl.customers_imageUrl +
                                              customers.cimage),
                                    )
                                  : const Center(
                                      child: Text(
                                        "No image",
                                        // textAlign: TextAlign.center,
                                        style: TextStyle(
                                            letterSpacing: 0.5,
                                            color: Colors.white54,
                                            fontSize: 20),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: customers.cimage != ""
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height * .50),
                          child: CircleAvatar(
                            radius: 120,
                            backgroundImage: NetworkImage(Myurl.fullurl +
                                Myurl.customers_imageUrl +
                                customers.cimage),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(100)),
                          child: CircleAvatar(
                            // backgroundColor: Colors.black,
                            radius: 100, backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.person,
                              size: 150,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomerProfile(customers)),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 13.5,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground),
                        children: [
                          TextSpan(text: 'View '),
                          TextSpan(
                              text: "${customers.cname}'s ",
                              style: TextStyle(
                                  letterSpacing: 0.4,
                                  color: colorOfApp,
                                  fontWeight: FontWeight.w500)),
                          TextSpan(text: 'profile.')
                        ],
                      ),
                    )
                    //  Text(
                    //   "View ${customers.cname}'s Profile",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    // fontSize: 13.5,
                    // letterSpacing: 0.3,
                    // fontWeight: FontWeight.w600),
                    // ),
                    ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    customers.cname,
                    style: TextStyle(
                        // fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
