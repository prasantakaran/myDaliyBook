// ignore_for_file: must_be_immutable, unnecessary_import, no_logic_in_create_state, use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:lottie/lottie.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/screen/you_get.dart';
import 'package:mypay/screen/you_give.dart';

class ChooseTransition extends StatefulWidget {
  // ChooseTransition({super.key});
  AllCustomers customers;
  ChooseTransition(this.customers);
  @override
  State<ChooseTransition> createState() => _ChooseTransitionState(customers);
}

class _ChooseTransitionState extends State<ChooseTransition> {
  AllCustomers customers;
  _ChooseTransitionState(this.customers);
  bool isGive = false;
  bool isGet = false;
  bool isConfirmButton = false;

  @override
  Widget build(BuildContext context) {
    ThemeController themeCon = Get.put(ThemeController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 175, 135, 215),
        title: Text('Select Tab.'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText(
                  'Choose and click what you want to do.',
                  textStyle: TextStyle(fontSize: 16),
                ),
              ],
              isRepeatingAnimation: true,
              repeatForever: true,
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Lottie.asset(
              'assets/lottie/note_book.json',
              // width: 200,
              height: 300,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            padding: EdgeInsets.all(6),
            // margin: EdgeInsets.all(6),
            child: RichText(
              // overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: themeCon.isDark.value ? Colors.white : Colors.black,
                ),
                children: [
                  TextSpan(text: 'If You get money from '),
                  TextSpan(
                    text: customers.cname,
                    style: const TextStyle(
                        fontSize: 17.5,
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' then click on '),
                  TextSpan(
                    text: 'YouGet',
                    style: const TextStyle(
                        // fontSize: 17,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '.Otherwise click on '),
                  TextSpan(
                    text: 'YouGive ',
                    style: const TextStyle(
                        // fontSize: 17,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: 'if '),
                  TextSpan(
                    text: customers.cname,
                    style: const TextStyle(
                        fontSize: 17.5,
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' get money from You.')
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isGet ? Colors.green : Colors.transparent),
                      onPressed: () {
                        setState(() {
                          isConfirmButton = true;
                          isGet = true;
                          isGive = false;
                        });
                      },
                      icon: Icon(
                        Icons.download,
                        color:
                            themeCon.isDark.value ? Colors.white : Colors.black,
                      ),
                      label: Text(
                        'You Get',
                        style: TextStyle(
                          fontSize: 17,
                          color: themeCon.isDark.value
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    isGet
                        ? Container(
                            width: 100,
                            height: 3,
                            decoration:
                                BoxDecoration(color: Colors.orangeAccent),
                          )
                        : Center()
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isGive ? Colors.redAccent : Colors.transparent),
                      onPressed: () {
                        setState(() {
                          isConfirmButton = true;
                          isGive = true;
                          isGet = false;
                        });
                      },
                      icon: Icon(
                        Icons.upload,
                        color:
                            themeCon.isDark.value ? Colors.white : Colors.black,
                      ),
                      label: Text(
                        'You Give',
                        style: TextStyle(
                          fontSize: 17,
                          color: themeCon.isDark.value
                              ? Colors.white
                              : Colors.black,
                          // fontSize: 18,
                        ),
                      ),
                    ),
                    isGive
                        ? Container(
                            width: 100,
                            height: 3,
                            decoration:
                                BoxDecoration(color: Colors.orangeAccent),
                          )
                        : Center()
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          isGet
              ? Padding(
                  padding: const EdgeInsets.all(35),
                  child: isConfirmButton
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                            ),
                            onPressed: () {
                              print('get');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => YouGet(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.done,
                              color: themeCon.isDark.value
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            label: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: themeCon.isDark.value
                                      ? Colors.white
                                      : Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Confirm to ',
                                  ),
                                  TextSpan(
                                    text: 'Get',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 135, 205, 137),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Text(
                            //   'Confirm to Get',
                            //   overflow: TextOverflow.ellipsis,
                            //   style: TextStyle(
                            //       fontSize: 16,
                            //       color: themeCon.isDark.value
                            //           ? Colors.white
                            //           : Colors.black),
                            // ),
                          ),
                        )
                      : Center(),
                )
              : Padding(
                  padding: const EdgeInsets.all(35),
                  child: isConfirmButton
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                            ),
                            onPressed: () {
                              print('give');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => YouGive(),
                                ),
                              );
                            },
                            icon: Icon(Icons.done,
                                color: themeCon.isDark.value
                                    ? Colors.white
                                    : Colors.black),
                            label: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: themeCon.isDark.value
                                      ? Colors.white
                                      : Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Confirm to ',
                                  ),
                                  TextSpan(
                                    text: 'Give',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 185, 46, 36),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Text(
                            //   'Confirm to Give',
                            //   overflow: TextOverflow.ellipsis,
                            //   style: TextStyle(
                            //       fontSize: 16,
                            //       color: themeCon.isDark.value
                            //           ? Colors.white
                            //           : Colors.black),
                            // ),
                          ),
                        )
                      : Center(),
                )
        ],
      ),
    );
  }
}
