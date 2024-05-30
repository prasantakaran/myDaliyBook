// ignore_for_file: body_might_complete_normally_nullable, prefer_const_constructors, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/Colors_Palette.dart';
import 'package:mypay/screen/loading.dart';
import 'package:mypay/screen/verify_otp.dart';
import 'package:mypay/url/db_connection.dart';

class InputEmail extends StatefulWidget {
  const InputEmail({super.key});

  @override
  State<InputEmail> createState() => _InputEmailState();
}

class _InputEmailState extends State<InputEmail> {
  TextEditingController emailController = TextEditingController();
  final fk = GlobalKey<FormState>();
  EmailOTP myauth = EmailOTP();

  Future checkEmail(String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(),
    );
    try {
      Map data = {'uemail': email};
      var res = await http.post(Uri.parse(Myurl.fullurl + "check_email.php"),
          body: data);

      var jsondata = jsonDecode(res.body);
      if (jsondata['status'] == true) {
        // Navigator.pop(context);

        // StudentEmail.email = email;
        if (mounted)
          myauth.setConfig(
              appEmail: "me@rohitchouhan.com",
              appName: "myDailyBook",
              userEmail: emailController.text,
              otpLength: 6,
              otpType: OTPType.digitsOnly);
        if (await myauth.sendOTP() == true) {
          if (mounted)
            Get.snackbar(
              backgroundColor: colorOfApp,
              borderRadius: 10.0,
              'myDailyBook',
              'OTP has been sent in required email.',
            );
          Navigator.pop(context);
        } else {
          if (mounted)
            Get.snackbar(
              backgroundColor: Theme.of(context).colorScheme.onBackground,
              colorText: Theme.of(context).colorScheme.background,
              'myDailyBook',
              'Oops, OTP send failed',
            );
        }
      } else {
        if (mounted)
          Fluttertoast.showToast(
            gravity: ToastGravity.CENTER,
            msg: jsondata['msg'],
          );
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
        gravity: ToastGravity.CENTER,
        msg: e.toString(),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(30.0),
              child: Form(
                key: fk,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/otp.json',
                      alignment: Alignment.center,
                    ),
                    AutoSizeText(
                      'Please enter your registered email address to receive a One-Time Password (OTP) for secure password change.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13.5),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Email.';
                        }
                        bool regx = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.! #$%&'*+-/=? ^_'{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value);
                        if (!regx) {
                          return 'Enter Valid Email.';
                        }
                      },
                      controller: emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.red),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.blueGrey,
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.textColor1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.textColor1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.textColor1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Email",
                        hintStyle:
                            TextStyle(color: Palette.textColor1, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 50),
                    MaterialButton(
                      padding: EdgeInsets.all(15),
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      color: colorOfApp,
                      onPressed: () async {
                        print('click');
                        if (fk.currentState!.validate()) {
                          if (emailController.text.isNotEmpty) {
                            StoreEmail(emailController.text);
                            await checkEmail(emailController.text);
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OTP_Verification(
                                  myauth,
                                ),
                              ),
                            );
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Please enter requied email.');
                        }
                      },
                      child: AutoSizeText(
                        'Get OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
