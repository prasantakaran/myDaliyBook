// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/Login.dart';
import 'package:mypay/screen/loading.dart';
import 'package:mypay/url/db_connection.dart';

class PasswordFields extends StatefulWidget {
  const PasswordFields({super.key});

  @override
  State<PasswordFields> createState() => _PasswordFieldsState();
}

class _PasswordFieldsState extends State<PasswordFields> {
  TextEditingController newController = TextEditingController();
  TextEditingController ReEnterController = TextEditingController();
  final fk = GlobalKey<FormState>();
  bool isPass = false;
  bool isReEnterController = false;
  final formkey = GlobalKey<FormState>();
  String email = '';
  String errorText = '';
  String newFieldError = '';
  @override
  void initState() {
    super.initState();
    email = StoreEmail.email;
  }

  @override
  void dispose() {
    newController.dispose();
    ReEnterController.dispose();
    super.dispose();
  }

  Future<void> updatPassword(String email, String npass) async {
    Map data = {'uemail': email, 'upassword': npass};
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(),
    );

    try {
      var res = await http
          .post(Uri.parse(Myurl.fullurl + "change_password.php"), body: data)
          .timeout(Duration(seconds: 10));

      var jsondata = jsonDecode(res.body);
      if (jsondata['status'] == true) {
        Navigator.pop(context);

        Fluttertoast.showToast(msg: jsondata['msg']);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Network request timed out or failed: ${e.toString()}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: colorOfApp,
            height: height * 0.95,
            width: width,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(),
                  height: height * 0.13,
                  child: const Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 35, left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Change Paswword.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: fk,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      height: height * 0.75,
                      width: width,
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: formkey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: newController,
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    isPass = false;
                                    newFieldError = 'Password required';
                                  });
                                } else if (value.length < 6) {
                                  setState(() {
                                    newFieldError =
                                        'Password must be 6 charecter.';
                                    isPass = false;
                                  });
                                } else {
                                  setState(() {
                                    isPass = true;
                                    newFieldError = '';
                                  });
                                }
                              },
                              showCursor: true,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                              decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onError),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: newFieldError.isEmpty
                                            ? colorOfApp
                                            : Colors.red)),
                                errorText:
                                    newFieldError.isEmpty ? '' : newFieldError,
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: newFieldError.isEmpty
                                            ? colorOfApp
                                            : Colors.red)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: newFieldError.isEmpty
                                            ? Colors.green
                                            : Colors.red)),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                suffixIcon: newController.text.isNotEmpty
                                    ? isPass == false
                                        ? IconButton(
                                            onPressed: () {
                                              ReEnterController.clear();
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                          )
                                        : Icon(
                                            Icons.done,
                                            color: Colors.green,
                                          )
                                    : Text(''),
                                labelText: 'New Password',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintText: 'Enter new password',
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: isReEnterController == false
                                            ? Colors.red
                                            : Colors.green,
                                        width: 1)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.greenAccent, width: 1),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              controller: ReEnterController,
                              onChanged: (value) {
                                if (ReEnterController.text !=
                                    newController.text) {
                                  setState(() {
                                    isReEnterController = false;
                                    errorText = 'Password not matched!';
                                  });
                                } else {
                                  setState(() {
                                    isReEnterController = true;
                                    errorText = '';
                                  });
                                }
                              },
                              showCursor: true,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                              decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onError),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red)),
                                errorText: errorText.isEmpty ? null : errorText,
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red)),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                suffixIcon: ReEnterController.text.isNotEmpty
                                    ? isReEnterController == false
                                        ? IconButton(
                                            onPressed: () {
                                              ReEnterController.clear();
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.done,
                                            color: Colors.green,
                                          )
                                    : Text(''),
                                labelText: 'Re-enter Password',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.4),
                                    fontSize: 13),
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintText: 'myDailyBook@123',
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: isReEnterController == false
                                            ? Colors.red
                                            : Colors.green,
                                        width: 1)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.greenAccent, width: 1),
                                ),
                              ),
                            ),
                            Spacer(),
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.all(15),
                              minWidth: double.infinity,
                              color: colorOfApp,
                              onPressed: () {
                                if (fk.currentState!.validate()) {
                                  if (ReEnterController.text.isNotEmpty &&
                                      newController.text.isNotEmpty) {
                                    if (newController.text ==
                                        ReEnterController.text) {
                                      updatPassword(email.toString(),
                                          ReEnterController.text);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'Password not matched.');
                                    }

                                    newController.clear();
                                    ReEnterController.clear();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Provide Password');
                                  }
                                }
                              },
                              child: AutoSizeText(
                                'Save password',
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
