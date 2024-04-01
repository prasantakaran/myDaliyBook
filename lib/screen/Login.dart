// ignore_for_file: unused_local_variable, non_constant_identifier_names, prefer_interpolation_to_compose_strings, prefer_const_constructors, use_build_context_synchronously, curly_braces_in_flow_control_structures, body_might_complete_normally_nullable, unrelated_type_equality_checks, avoid_print, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/screen/Colors_Palette.dart';
import 'package:mypay/screen/dashboard.dart';
import 'package:mypay/screen/loading.dart';
import 'package:mypay/screen/splash.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginUser extends StatefulWidget {
  const LoginUser({super.key});

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  bool isSignupscreen = true;
  bool isMale = false;
  bool isFemale = false;

  // bool isRememberMe = false;
  String getGenderValue = '';

  final signupFormkey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passTogol = true;

  final loginFormkey = GlobalKey<FormState>();

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  final bookNameFormkey = GlobalKey<FormState>();
  TextEditingController bookNameController = TextEditingController();

  late SharedPreferences sp;

  Future<void> getLogin(String email, String password) async {
    Map data = {'uemail': email, 'upassword': password};
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(),
    );

    try {
      var res =
          await http.post(Uri.parse(Myurl.fullurl + "login.php"), body: data);
      var jsondata = jsonDecode(res.body.toString());
      if (jsondata['status'] == true) {
        Navigator.pop(context);
        if (!mounted) return;
        UserDetails loginUserData = UserDetails(
          m_id: jsondata['log_id'].toString(),
          m_name: jsondata['log_name'].toString(),
          m_email: jsondata['log_email'].toString(),
          m_phone: jsondata['log_phone'].toString(),
          m_password: jsondata['log_password'].toString(),
          m_image: jsondata['log_image'].toString(),
          m_gender: jsondata['log_gender'].toString(),
          m_bookname: jsondata['log_bookname'].toString(),
        );

        sp = await SharedPreferences.getInstance();
        sp.setString('sp_id', jsondata['log_id'].toString());
        sp.setString('sp_name', jsondata['log_name'].toString());
        sp.setString('sp_email', jsondata['log_email'].toString());
        sp.setString('sp_phone', jsondata['log_phone'].toString());
        sp.setString('sp_password', jsondata['log_password'].toString());
        sp.setString('sp_image', jsondata['log_image'].toString());
        sp.setString('sp_gender', jsondata['log_gender'].toString());
        sp.setString('sp_bookname', jsondata['log_bookname'].toString());
        sp.setBool(myDealyBookSplashState.keySP, true);

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ShowCaseWidget(
        //       builder: Builder(
        //         builder: (context) => Dashboard(),
        //       ),
        //     ),
        //   ),
        // );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
        Fluttertoast.showToast(msg: jsondata['msg']);
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: jsondata['msg']);
        // Navigator.of(context).pop();
      }
    } catch (e) {
      Navigator.of(context).pop();

      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> getRegistration(String name, String email, String phone,
      String password, String gender, String book_name) async {
    Map data = {
      'uname': name,
      'ugender': gender,
      'uemail': email,
      'uphone': phone,
      'upassword': password,
      'ubook_name': book_name
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(),
    );
    try {
      var res = await http.post(Uri.parse(Myurl.fullurl + "registration.php"),
          body: data);
      var jsondata = jsonDecode(res.body);
      if (jsondata['status'] == true) {
        Navigator.pop(context);
        if (!mounted) return;

        UserDetails userData = UserDetails(
          m_id: jsondata['reg_id'].toString(),
          m_name: jsondata['reg_name'].toString(),
          m_email: jsondata['reg_email'].toString(),
          m_phone: jsondata['reg_phone'].toString(),
          m_password: jsondata['reg_password'].toString(),
          m_image: jsondata['reg_image'].toString(),
          m_gender: jsondata['reg_gender'].toString(),
          m_bookname: jsondata['reg_bookname'].toString(),
        );

        sp = await SharedPreferences.getInstance();
        sp.setString('sp_id', jsondata['reg_id'].toString());
        sp.setString('sp_name', jsondata['reg_name'].toString());
        sp.setString('sp_email', jsondata['reg_email'].toString());
        sp.setString('sp_phone', jsondata['reg_phone'].toString());
        sp.setString('sp_password', jsondata['reg_password'].toString());
        sp.setString('sp_image', jsondata['reg_image'].toString());
        sp.setString('sp_gender', jsondata['reg_gender'].toString());
        sp.setString('sp_bookname', jsondata['reg_bookname'].toString());

        sp.setBool(myDealyBookSplashState.keySP, true);
        Navigator.pop(context);

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ShowCaseWidget(
        //       builder: Builder(
        //         builder: (context) => Dashboard(),
        //       ),
        //     ),
        //   ),
        // );

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Dashboard()));

        Fluttertoast.showToast(msg: jsondata['msg']);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      Navigator.of(context).pop();

      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Palette.bgColor,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 400,
                decoration: const BoxDecoration(
                  // color: Colors.teal.,
                  image: DecorationImage(
                      image: AssetImage('assets/images/my.jpg'),
                      // opacity: 10,
                      fit: BoxFit.cover),
                ),
                child: Container(
                  padding: const EdgeInsets.only(top: 50, left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Here to Get\nWelcome !\n',
                          style: TextStyle(fontSize: 20),
                          children: [
                            TextSpan(
                              text: 'myDailyBook',
                              style: TextStyle(
                                  fontFamily: 'KaushanScript',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //LOGIN $ SIGNUP

            submitButton(true),

            Positioned(
              bottom: 35,
              child: Container(
                // margin: EdgeInsets.all(3),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: isSignupscreen ? 'SignUp\n' : 'LogIn\n',
                      style: const TextStyle(
                          letterSpacing: 0.3,
                          color: Colors.green,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                      children: const [
                        TextSpan(
                          text: 'to continue',
                          style: TextStyle(
                              letterSpacing: 0.5,
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        )
                      ]),
                ),
              ),
            ),

            AnimatedPositioned(
              duration: Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              top: 300,
              //main Container of LOGIN $ SIGNUP  page ----
              child: AnimatedContainer(
                duration: Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(10),
                height: isSignupscreen ? 400 : 280,
                width: MediaQuery.of(context).size.width - 40,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //LOGIN text section ----

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupscreen = false;
                                  // print('login');
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    'LOGIN',
                                    style: TextStyle(
                                        letterSpacing: 0.5,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSignupscreen
                                            ? Palette.textColor1
                                            : Palette.activeColor),
                                  ),
                                  if (isSignupscreen == false)
                                    Container(
                                      color: Colors.orange,
                                      height: 2,
                                      width: 55,
                                      margin: EdgeInsets.only(top: 3),
                                    ),
                                ],
                              ),
                            ),
                            // SIGNUP text section ----

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupscreen = true;
                                  // print('signup');
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    'SIGNUP',
                                    style: TextStyle(
                                        letterSpacing: 0.5,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSignupscreen
                                            ? Palette.activeColor
                                            : Palette.textColor1),
                                  ),
                                  if (isSignupscreen == true)
                                    Container(
                                      color: Colors.orange,
                                      height: 2,
                                      width: 58,
                                      margin: EdgeInsets.only(top: 3),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      //Text field --
                      if (isSignupscreen)
                        Form(
                          key: signupFormkey,
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                //User_Name Field ----

                                TextFormField(
                                  // autovalidateMode: AutovalidateMode.always,
                                  validator: (value) {
                                    if (value!.isEmpty)
                                      return 'Enter Name';
                                    else if (value.length < 3)
                                      return 'Name must be more than 2 charater';
                                  },
                                  controller: nameController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    errorStyle: TextStyle(color: Colors.red),
                                    prefixIcon: Icon(
                                      Icons.person_2,
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "User Name",
                                    hintStyle: TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),

                                //Email Field ----

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
                                  decoration: const InputDecoration(
                                    errorStyle: TextStyle(color: Colors.red),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "Email",
                                    hintStyle: TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),

                                //Phone Field ----

                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter Phone Number';
                                    } else if (value.length != 10 &&
                                        phoneController.text.toString() != 10)
                                      return 'Mobile Number must be of 10 digit';
                                  },
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    errorStyle: TextStyle(color: Colors.red),
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "Phone",
                                    hintStyle: TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),

                                //Password Field ----

                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter Password';
                                    } else if (passwordController.text.length <
                                        6) {
                                      return 'Password Length Should be more than 6 characters';
                                    }
                                  },
                                  controller: passwordController,
                                  obscureText: passTogol,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(color: Colors.red),
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        setState(() {
                                          passTogol = !passTogol;
                                        });
                                      },
                                      child: Icon(
                                        passTogol
                                            ? Icons.visibility
                                            : Icons.visibility_off_outlined,
                                        color: Palette.iconColor,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                    hintText: "Password",
                                    hintStyle: const TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),

                                //Gender ----
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isMale = true;
                                            isFemale = false;
                                            print('m');
                                            // getSelectedGender('Male');
                                            getGenderValue = 'Male';
                                            // print(getGenderValue);
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  right: 10, top: 10),
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                color: isMale
                                                    ? Palette.textColor2
                                                    : Colors.transparent,
                                                border: Border.all(
                                                    color: isMale
                                                        ? Colors.black
                                                        : Palette.textColor1),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: isMale
                                                    ? Colors.white
                                                    : Palette.iconColor,
                                              ),
                                            ),
                                            Text(
                                              'Male',
                                              style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: isMale
                                                      ? Colors.green
                                                      : Palette.textColor1,
                                                  fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {});
                                          isFemale = true;
                                          isMale = false;
                                          print('F');
                                          // getSelectedGender('Female');
                                          getGenderValue = 'Female';
                                          // print(getGenderValue);
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  right: 10, top: 10),
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                color: !isFemale
                                                    ? Colors.transparent
                                                    : Palette.textColor2,
                                                border: Border.all(
                                                    color: !isFemale
                                                        ? Palette.textColor1
                                                        : Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: !isFemale
                                                    ? Palette.iconColor
                                                    : Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Female',
                                              style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: !isFemale
                                                      ? Palette.textColor1
                                                      : Colors.green,
                                                  fontSize: 16),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                      //Login Section ----

                      //login email ----

                      if (!isSignupscreen)
                        Form(
                          key: loginFormkey,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter Email.';
                                    }
                                    bool regx = RegExp(
                                            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                        .hasMatch(value);
                                    if (!regx) {
                                      return 'Enter valid Email';
                                    }
                                  },
                                  controller: loginEmailController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    errorStyle: TextStyle(color: Colors.red),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "Email",
                                    hintStyle: TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                //login password ----

                                TextFormField(
                                  controller: loginPasswordController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter Password.';
                                    } else if (value.length < 6) {
                                      return 'Password Length Should be more than 6 characters';
                                    }
                                  },
                                  style: TextStyle(color: Colors.black),
                                  obscureText: passTogol,
                                  decoration: InputDecoration(
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        setState(() {
                                          passTogol = !passTogol;
                                        });
                                      },
                                      child: Icon(
                                        passTogol
                                            ? Icons.visibility
                                            : Icons.visibility_off_outlined,
                                        color: Palette.iconColor,
                                      ),
                                    ),
                                    errorStyle: TextStyle(color: Colors.red),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: Text('Forgot Password?'),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),

            //submit button ----

            submitButton(false),
          ],
        ),
      ),
    );
  }

  Widget submitButton(bool isShowShadow) {
    return isSignupscreen
        ? AnimatedPositioned(
            duration: Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            top: isSignupscreen ? 650 : 535,
            right: 0,
            left: 0,
            child: Center(
              child: InkWell(
                onTap: () async {
                  if (signupFormkey.currentState!.validate() &&
                      getGenderValue.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          // elevation: 100,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Color.fromARGB(255, 91, 35, 47),
                          // backgroundColor: Colors.white,
                          titleTextStyle:
                              TextStyle(fontSize: 18, color: Colors.black),
                          title: const Text(
                            'Give your book name !',
                            textAlign: TextAlign.center,
                          ),
                          content: Form(
                            key: bookNameFormkey,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Enter Book Name';
                                else if (value.length < 4)
                                  return 'Name must be more than 3 charater';
                              },
                              controller: bookNameController,
                              decoration: InputDecoration(
                                  errorBorder: InputBorder.none,
                                  errorStyle: TextStyle(color: Colors.red)),
                              autofocus: true,
                            ),
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    getRegistration(
                                        nameController.text.toString().trim(),
                                        emailController.text.toString().trim(),
                                        phoneController.text.toString().trim(),
                                        passwordController.text
                                            .toString()
                                            .trim(),
                                        getGenderValue.toString().trim(),
                                        'myDailyBook'.toString().trim());
                                  },
                                  child: const Text(
                                    'Later',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (bookNameFormkey.currentState!
                                        .validate()) {
                                      getRegistration(
                                          nameController.text.toString().trim(),
                                          emailController.text
                                              .toString()
                                              .trim(),
                                          phoneController.text
                                              .toString()
                                              .trim(),
                                          passwordController.text
                                              .toString()
                                              .trim(),
                                          getGenderValue.toString().trim(),
                                          bookNameController.text
                                              .toString()
                                              .trim());
                                    }
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Please Provide required Details.');
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    // border: Border.all(),
                    boxShadow: [
                      if (isShowShadow)
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 1.5,
                          color: Colors.black.withOpacity(.3),
                          offset: Offset(0, 2),
                        )
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: !isShowShadow
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.pinkAccent,
                                  Colors.red.shade100,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(180),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                spreadRadius: 1,
                                color: Colors.black.withOpacity(.3),
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 30,
                          ),
                        )
                      : Center(),
                ),
              ),
            ),
          )
        : AnimatedPositioned(
            duration: Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            top: isSignupscreen ? 650 : 535,
            right: 0,
            left: 0,
            child: Center(
              child: InkWell(
                onTap: () async {
                  if (loginFormkey.currentState!.validate()) {
                    print('login');
                    getLogin(loginEmailController.text.toString(),
                        loginPasswordController.text.toString());
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Please Enter your valid Identity');
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    // border: Border.all(),
                    boxShadow: [
                      if (isShowShadow)
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 1.5,
                          color: Colors.black.withOpacity(.3),
                          offset: Offset(0, 2),
                        )
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: !isShowShadow
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.pinkAccent,
                                  Colors.red.shade100,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(180),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                spreadRadius: 1,
                                color: Colors.black.withOpacity(.3),
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 30,
                          ),
                        )
                      : Center(),
                ),
              ),
            ),
          );
  }

  void getSelectedGender(String gender) {
    // Use the selected gender value as needed
    print('Selected gender: $gender');
  }
}
