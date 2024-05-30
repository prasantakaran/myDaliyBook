// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, unnecessary_new, prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures, override_on_non_overriding_member

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/change_password.dart';

class OTP_Verification extends StatefulWidget {
  EmailOTP myauth;
  OTP_Verification(this.myauth);
  @override
  State<OTP_Verification> createState() => _OTP_VerificationState(myauth);
}

class _OTP_VerificationState extends State<OTP_Verification> {
  EmailOTP myauth;
  _OTP_VerificationState(this.myauth);
  @override
  bool _isResend = false;
  bool _isVerified = false;
  bool _isLoading = false;
  String _code = '';
  Timer? _timer;
  bool _onEditing = true;
  int _start = 30;
  ThemeController _controller = Get.put(ThemeController());
  void resend() {
    if (mounted)
      setState(() {
        _isResend = true;
      });
    const onSec = Duration(seconds: 1);
    _timer = new Timer.periodic(onSec, (timer) {
      if (mounted)
        setState(() {
          if (_start == 0) {
            _start = 30;
            _isResend = false;
            timer.cancel();
          } else {
            _start--;
          }
        });
    });
  }

  verify() {
    if (mounted)
      setState(() {
        _isLoading = true;
      });

    const onSec = Duration(milliseconds: 1000);
    _timer = new Timer.periodic(onSec, (timer) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _isVerified = true;
        });
    });
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.5,
                child: Image(
                  image: AssetImage('assets/images/mail_otp.png'),
                  width: 260,
                  height: 260,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              AutoSizeText(
                'Verification',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: TextStyle(
                        fontSize: 16,
                        color: _controller.isDark.value
                            ? Colors.white
                            : Colors.black),
                    children: [
                      TextSpan(
                          text: 'Please enter the 6 digit code sent to \n'),
                      TextSpan(
                        text: StoreEmail.email.toString(),
                        style: TextStyle(
                            fontSize: 14.5,
                            color: _controller.isDark.value
                                ? Colors.white
                                : Colors.black.withOpacity(0.5)),
                      ),
                    ]),
              ),
              SizedBox(
                height: 30,
              ),
              VerificationCode(
                digitsOnly: true,
                length: 6,
                cursorColor: Colors.black,
                // underlineUnfocusedColor: Colors.red,
                fillColor: colorOfApp.withOpacity(0.4),
                fullBorder: true,
                textStyle: TextStyle(fontSize: 20),
                underlineColor: Colors.blueAccent,
                keyboardType: TextInputType.number,
                onCompleted: (value) {
                  if (mounted)
                    setState(() {
                      _code = value;
                    });
                },
                onEditing: (bool value) {
                  if (mounted)
                    setState(() {
                      _onEditing = value;
                    });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: _onEditing
                      ? const Text('Please enter full code')
                      : Text('Your code: $_code'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  AutoSizeText(
                    "Dont't receive the OTP?",
                    style:
                        TextStyle(fontSize: 14, color: Colors.green.shade200),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_isResend) return;
                      resend();
                    },
                    child: AutoSizeText(
                      _isResend
                          ? "try again in ${_start.toString()}"
                          : 'Resend',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              MaterialButton(
                disabledColor: Colors.grey.shade300,
                onPressed: _code.length < 6
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please enter the verification code"),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PasswordFields()),
                        );
                      }
                    : () async {
                        if (_code.isNotEmpty) {
                          verify();
                          if (await widget.myauth.verifyOTP(otp: _code) ==
                              true) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: colorOfApp,
                              content: Text(
                                "OTP is verified",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PasswordFields()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.onBackground,
                              content: Text(
                                "Invalid OTP",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ));
                          }
                        }
                      },
                minWidth: double.infinity,
                height: 50,
                color: colorOfApp,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          backgroundColor: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : _isVerified
                        ? Icon(
                            Icons.check_circle,
                            size: 30,
                          )
                        : AutoSizeText(
                            'Verify',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
