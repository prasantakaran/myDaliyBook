// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, use_build_context_synchronously, avoid_print, prefer_interpolation_to_compose_strings, await_only_futures, must_be_immutable, unnecessary_this

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/screen/Colors_Palette.dart';
import 'package:mypay/screen/Login.dart';
import 'package:mypay/screen/loading.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.usersInfo});
  UserDetails usersInfo;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SharedPreferences sp;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  String loginid = '';
  void getuser_id() async {
    sp = await SharedPreferences.getInstance();
    loginid = sp.getString('sp_id') ?? "";
    print(loginid);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: widget.usersInfo.m_name);
    emailController = TextEditingController(text: widget.usersInfo.m_email);
    phoneController = TextEditingController(text: widget.usersInfo.m_phone);
    getuser_id();
  }

  ThemeController themeController = Get.put(ThemeController());

  ImagePicker picker = ImagePicker();
  File? file;
  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final imageTemp = File(pickedFile.path);
    setState(() => this.file = imageTemp);
    print("gallery.......=>${file}");
  }

  Future pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    final imageTemp = File(pickedFile.path);
    setState(() => this.file = imageTemp);
    print("camera.......=>${file}");
  }

  Future imageUpdate(String uid, File? uimage) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(),
    );
    try {
      var request = await http.MultipartRequest(
          "POST", Uri.parse(Myurl.fullurl + "user_image_update.php"));
      request.fields['id'] = uid;
      if (uimage != null)
        request.files.add(
          await http.MultipartFile.fromBytes("image", uimage.readAsBytesSync(),
              filename: uimage.path.split("/").last),
        );
      var response = await request.send();
      var responded = await http.Response.fromStream(response);
      var jsondata = jsonDecode(responded.body);
      print('outside');

      if (jsondata['status'] == true) {
        print('true');
        Navigator.pop(context);
        if (!mounted) return;
        sp = await SharedPreferences.getInstance();
        setState(() {
          widget.usersInfo.m_image = jsondata['imgtitle'];
          sp.setString("sp_image", widget.usersInfo.m_image);
        });
        Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeController themeCon = Get.put(ThemeController());

    return Scaffold(
      backgroundColor: themeCon.isDark.value
          ? Color.fromARGB(255, 6, 34, 92)
          : Color.fromARGB(255, 242, 243, 245),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 60),
              height: 400,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
                color: Color.fromARGB(255, 175, 135, 215),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            size: 27,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        // color: Colors.blueGrey,]
                        color: themeController.isDark.value
                            ? Colors.indigo[50]
                            : Colors.white,
                        boxShadow: [
                          // if (isShadow)
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 5,
                              color: themeController.isDark.value
                                  ? Colors.white54
                                  : Colors.black)
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: file != null
                            ? ClipOval(
                                child: Image.file(
                                  file!,
                                ),
                              )
                            : widget.usersInfo.m_image == "no_image"
                                ? CircleAvatar(
                                    backgroundColor: Colors.black45,
                                    child: Icon(
                                      Icons.person,
                                      size: 100,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    // width: 50,
                                    // height: 50,
                                    imageUrl: Myurl.fullurl +
                                        Myurl.user_imageurl +
                                        widget.usersInfo.m_image,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                        //  CircleAvatar(
                        //     backgroundImage: NetworkImage(
                        //         Myurl.fullurl +
                        //             Myurl.user_imageurl +
                        //             widget.usersInfo.m_image),
                        //   ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.5,
                      right: 120,
                      // left: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0.5,
                              blurRadius: 20,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) => BottonSheet(context));
                          },
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            // color: Colors.,
                            size: 33,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Text('data'),
          Positioned(
              left: 30,
              right: 30,
              top: 220,
              child: Column(
                children: [
                  Text(
                    widget.usersInfo.m_name.toUpperCase(),
                    style: TextStyle(
                        fontFamily: 'KaushanScript',
                        fontSize: 18,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.usersInfo.m_email,
                    style: TextStyle(
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  )
                ],
              )),
          Positioned(
            // bottom: 0,
            left: 30,
            right: 30,
            top: 300,
            child: Container(
              height: 330,
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
                // border: Border.all(color: Colors.black),
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        height: 30,
                        decoration: BoxDecoration(
                            color: themeCon.isDark.value
                                ? Colors.blueGrey[500]
                                : Colors.blueGrey[100],
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          widget.usersInfo.m_bookname,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value!.isEmpty)
                        return 'Enter Name';
                      else if (value.length < 3)
                        return 'Name must be more than 2 charater';
                    },
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      errorStyle: TextStyle(color: Colors.red),
                      prefixIcon: Icon(
                        Icons.person_2,
                        color: Colors.blueGrey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Palette.textColor1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Palette.textColor1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      // hintText: "User Name",
                      hintStyle:
                          TextStyle(color: Palette.textColor1, fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: emailController,
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
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      errorStyle: TextStyle(color: Colors.red),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.blueGrey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Palette.textColor1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Palette.textColor1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      // hintText: "Email",
                      hintStyle:
                          TextStyle(color: Palette.textColor1, fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: phoneController,

                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Phone Number';
                      } else if (value.length != 10)
                        return 'Mobile Number must be of 10 digit';
                    },
                    // controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      errorStyle: TextStyle(color: Colors.red),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.blueGrey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Palette.textColor1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Palette.textColor1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      // label: Text('Phone'),
                      // hintText: "phone",
                      hintStyle:
                          TextStyle(color: Palette.textColor1, fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.person),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.usersInfo.m_gender,
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Spacer(),
          Positioned(
            // bottom: 0,
            left: 30,
            right: 30,
            top: 640,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () {
                imageUpdate(loginid, file).whenComplete(() {
                  setState(() {});
                });
                // Fluttertoast.showToast(msg: "prasant");
              },
              icon: Icon(
                Icons.save_alt_rounded,
                color: themeCon.isDark.value ? Colors.white : Colors.black,
                size: 30,
              ),
              label: Text(
                'Update',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: themeCon.isDark.value ? Colors.white : Colors.black),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () async {
          // showDialog(context: context, builder: );
          sp = await SharedPreferences.getInstance();
          sp.clear();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginUser()),
              (route) => false);
        },
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(Icons.logout),
      ),
    );
  }

  Widget BottonSheet(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      width: double.infinity,
      height: size.height * 0.2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Choose Profile Image!",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 28,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  pickImageFromGallery();

                  Navigator.pop(context);
                },
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        color: themeController.isDark.value
                            ? Colors.white
                            : Colors.purple,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(
                            letterSpacing: 0.4,
                            color: themeController.isDark.value
                                ? Colors.white
                                : Colors.purple,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 80.0,
              ),
              InkWell(
                onTap: () {
                  pickImageFromCamera();
                  Navigator.pop(context);
                },
                child: Container(
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera,
                        color: themeController.isDark.value
                            ? Colors.white
                            : Colors.purple,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(
                            letterSpacing: 0.4,
                            color: themeController.isDark.value
                                ? Colors.white
                                : Colors.purple,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
