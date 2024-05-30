// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/loading.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookNameChnge extends StatefulWidget {
  UserDetails user;
  BookNameChnge(this.user);

  @override
  State<BookNameChnge> createState() => _BookNameChngeState(user);
}

class _BookNameChngeState extends State<BookNameChnge> {
  UserDetails user;
  _BookNameChngeState(this.user);
  var _nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late SharedPreferences sp;
  ThemeController _themeController = Get.put(ThemeController());

  Future<void> bookNameChange(String id, String name) async {
    showDialog(
      context: context,
      builder: (context) => const LoadingDialog(),
    );

    try {
      Map<String, dynamic> data = {
        'uid': id,
        'bookname': name,
      };
      var response = await http
          .post(Uri.parse(Myurl.fullurl + "BookName_Change.php"), body: data);
      var jsonData = jsonDecode(response.body.toString());
      if (jsonData['status'] == true) {
        Navigator.pop(context);
        // Fluttertoast.showToast(msg: jsonData['msg']);

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon: false,
          descTextStyle: TextStyle(fontSize: 13),
          title: 'Success!',
          desc: jsonData['msg'],
          titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
        sp = await SharedPreferences.getInstance();
        setState(() {
          user.m_bookname = jsonData['bookname'];
          sp.setString('sp_bookname', jsonData['bookname']);
        });
      } else {
        Fluttertoast.showToast(msg: jsonData['msg']);
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: user.m_bookname.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        // backgroundColor: Colors.black.withOpacity(.9),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              // width: 2.5,
              color: _themeController.isDark.value
                  ? Colors.white30
                  : Colors.black54),
          borderRadius: BorderRadius.circular(13),
        ),
        content: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * .6,
              height: MediaQuery.of(context).size.height * .36,
              child: Column(
                children: [
                  SizedBox(height: 100),
                  AutoSizeText(
                    'Change your book name.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 40),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty)
                          return 'Enter Book Name';
                        else if (value.length < 4)
                          return 'Name must be more than 3 characters';
                        return null;
                      },
                      style: TextStyle(
                          fontSize: 16.5, fontWeight: FontWeight.w500),
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter book name.',
                        labelText: 'Bookname',
                        hintStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                        labelStyle: TextStyle(
                            fontSize: 13.5,
                            color: colorOfApp,
                            fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                              color: _themeController.isDark.value
                                  ? Colors.white60
                                  : Colors.black54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                              color: _themeController.isDark.value
                                  ? Colors.white60
                                  : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.clear,
                          color: Colors.red,
                        ),
                        label: AutoSizeText(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          // if (formKey.currentState!.validate()) {
                          if (user.m_bookname != _nameController.text) {
                            await bookNameChange(
                                user.m_id, _nameController.text);
                          } else {
                            Fluttertoast.showToast(
                                msg: 'No changes in bookname.');
                          }
                          // }
                        },
                        icon: Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                        label: AutoSizeText(
                          'Done',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              left: 16,
              right: 16,
              child: Lottie.asset(
                'assets/lottie/mydailybook_loading1.json',
                width: 100,
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
