// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, use_build_context_synchronously, avoid_print, prefer_interpolation_to_compose_strings, await_only_futures, must_be_immutable, unnecessary_this, prefer_const_literals_to_create_immutables, unnecessary_import, body_might_complete_normally_nullable, unnecessary_new, non_constant_identifier_names, prefer_final_fields

import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypay/GetxController/Customers_controller.dart';
import 'package:mypay/GetxController/Transactions_controller.dart';
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
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
  bool isFieldActive = false, isCheckError = false;
  ThemeController themeController = Get.put(ThemeController());
  final formKey = GlobalKey<FormState>();
  CustomersController _controller = Get.put(CustomersController());
  TransferCustomers _transferCustomers = Get.put(TransferCustomers());
  TotalTransactions _totalTransactions = Get.put(TotalTransactions());
  UserTransactionBalance _balance = Get.put(UserTransactionBalance());
  LastEntriesDate _entriesDate = Get.put(LastEntriesDate());

  String loginid = '';
  void getuser_id() async {
    sp = await SharedPreferences.getInstance();
    loginid = sp.getString('sp_id') ?? "";
    print(loginid);
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.usersInfo.m_name);
    emailController = TextEditingController(text: widget.usersInfo.m_email);
    phoneController = TextEditingController(text: widget.usersInfo.m_phone);
    getuser_id();
  }

  ImagePicker picker = ImagePicker();
  File? file;
  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final imageTemp = File(pickedFile.path);
    setState(() => this.file = imageTemp);
    print("gallery =>${file}");
  }

  Future pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    final imageTemp = File(pickedFile.path);
    setState(() => this.file = imageTemp);
    print("camera =>${file}");
  }

  Future<void> userImageUpdate(String uid, File? uimage) async {
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
      if (jsondata['status'] == true) {
        Navigator.pop(context);
        if (!mounted) return;
        sp = await SharedPreferences.getInstance();
        setState(() {
          widget.usersInfo.m_image = jsondata['imgtitle'];
          sp.setString("sp_image", widget.usersInfo.m_image);
        });
        Fluttertoast.showToast(msg: jsondata['msg']);
        print(jsondata['imgtitle']);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      Navigator.pop(context);
      print('profile screen');
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> userNameUpadate(String name, id) async {
    showDialog(
        context: context,
        builder: (context) {
          return const LoadingDialog();
        });
    try {
      Map data = {
        'uid': id,
        'uname': name,
      };
      var response = await http
          .post(Uri.parse(Myurl.fullurl + "username_Change.php"), body: data);

      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == true) {
        Navigator.pop(context);
        AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.topSlide,
                showCloseIcon: false,
                descTextStyle: TextStyle(fontSize: 13),
                title: 'Success!',
                desc: jsondata['msg'],
                titleTextStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                dismissOnTouchOutside: false,
                dismissOnBackKeyPress: false,
                btnOkOnPress: () {},
                btnOkColor: colorOfApp)
            .show();
        sp = await SharedPreferences.getInstance();
        setState(() {
          widget.usersInfo.m_name = jsondata['name'];
          sp.setString('sp_name', jsondata['name']);
        });
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeColor = Theme.of(context).colorScheme.onBackground;
    ThemeController themeCon = Get.put(ThemeController());

    return Scaffold(
      backgroundColor:
          themeCon.isDark.value ? Color.fromARGB(255, 7, 16, 34) : Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: 180,
              decoration: BoxDecoration(
                // color: Color.fromARGB(255, 23, 117, 194),
                color: colorOfApp,
              ),
            ),
            Positioned(
              // top: 0,
              // right: 0,
              // left: 0,
              child: Container(
                height: 80,
                padding: const EdgeInsets.only(
                  top: 40,
                  right: 10,
                  left: 10,
                ),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_outlined,
                        color: themeColor,
                      ),
                    ),
                    Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: themeColor,
                          fontSize: 20,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  margin: EdgeInsets.only(
                    top: 130,
                    right: 20,
                    left: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: titleColor.withOpacity(.1),
                          blurRadius: 20,
                          spreadRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5.0),
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: themeController.isDark.value
                                  ? Colors.indigo[50]
                                  : Colors.white,
                              boxShadow: [
                                // if (isShadow)
                                BoxShadow(
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                )
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
                                        // fit: BoxFit.cover,
                                      ),
                                    )
                                  : widget.usersInfo.m_image == "no_image.png"
                                      ? Container(
                                          // width: 50,
                                          // height: 50,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  Myurl.fullurl +
                                                      Myurl.user_imageurl +
                                                      widget.usersInfo.m_image,
                                                  scale: 5),
                                            ),
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          // width: 50,
                                          // height: 50,
                                          imageUrl: Myurl.fullurl +
                                              Myurl.user_imageurl +
                                              widget.usersInfo.m_image,
                                          imageBuilder:
                                              (context, imageProvider) =>
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
                                              child:
                                                  CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_a_photo,
                                    size: 30,
                                    color: Color.fromARGB(255, 46, 50, 184),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20))),
                                        context: context,
                                        builder: (context) =>
                                            BottomSheet(context));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        textAlign: TextAlign.center,
                        // overflow: TextOverflow.ellipsis,
                        widget.usersInfo.m_name.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        widget.usersInfo.m_email,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                        ),
                      ),
                      Form(
                        key: formKey,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          // width: 320,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              isFieldActive
                                  ? BoxShadow(
                                      blurRadius: 1.5,
                                      spreadRadius: 1.5,
                                      color: colorOfApp,
                                      offset: Offset(0.2, 0.2),
                                    )
                                  : BoxShadow(
                                      color: Colors.black.withOpacity(.1),
                                      blurRadius: 30,
                                      spreadRadius: 5),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextFormField(
                                  enabled: isFieldActive,
                                  controller: nameController,
                                  validator: (value) {
                                    if (value!.isEmpty)
                                      return 'Enter Name';
                                    else if (value.length < 3)
                                      return 'Name must be more than 2 charater';
                                    return null;
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(color: Colors.red),
                                    prefixIcon: Icon(
                                      Icons.person_2,
                                      color: Colors.blueGrey,
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: colorOfApp),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
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
                                    // hintText: "User Name",
                                    hintStyle: TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  enabled: false,
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
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
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
                                    // hintText: "Email",
                                    hintStyle: TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  enabled: false,
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
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
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
                                    // label: Text('Phone'),
                                    // hintText: "phone",
                                    hintStyle: TextStyle(
                                        color: Palette.textColor1,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: 300,
                            child: Divider(
                              height: 1,
                              color: titleColor.withOpacity(.3),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.bottomSlide,
                                    title: 'Confirmation',
                                    titleTextStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.4),
                                    desc: 'Are you sure you wanna to Logout?',
                                    btnCancelOnPress: () {},
                                    btnCancelText: 'Cancel',
                                    btnOkText: 'Logout',
                                    btnOkColor: colorOfApp,
                                    btnOkOnPress: () async {
                                      sp =
                                          await SharedPreferences.getInstance();
                                      sp.clear();
                                      _controller.items.clear();
                                      _transferCustomers.transactionItems
                                          .clear();
                                      _totalTransactions
                                          .totalTransactions.value = 0.0;
                                      _balance.totalGetBalance.value = 0.0;
                                      _entriesDate.lastDate.value = '';
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginUser()),
                                          (route) => false);
                                    },
                                  ).show();
                                },
                                icon: Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                  size: 26,
                                ),
                                label: Text(
                                  'Logout',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 17),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: colorOfApp,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Colors.white),
                                onPressed: () async {
                                  if (isFieldActive) {
                                    if (formKey.currentState!.validate()) {
                                      if (nameController.text !=
                                          widget.usersInfo.m_name) {
                                        await userNameUpadate(
                                                nameController.text, loginid)
                                            .whenComplete(() {
                                          Fluttertoast.showToast(
                                              msg: 'Name changed.');
                                        });
                                      } else if (phoneController.text !=
                                          widget.usersInfo.m_phone) {
                                        Fluttertoast.showToast(
                                            msg: 'Phone number changed.');
                                      } else if (phoneController.text !=
                                              widget.usersInfo.m_phone &&
                                          nameController.text !=
                                              widget.usersInfo.m_name) {
                                        Fluttertoast.showToast(
                                            msg: 'Email and name changed.');
                                      } else {
                                        Fluttertoast.showToast(
                                            textColor: colorOfApp,
                                            fontSize: 15.5,
                                            gravity: ToastGravity.CENTER,
                                            msg:
                                                'There is no changes in name.');
                                      }
                                    }
                                  } else {
                                    AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.warning,
                                            animType: AnimType.topSlide,
                                            titleTextStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                            descTextStyle: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500),
                                            title: 'Notice !',
                                            desc:
                                                'To activate the required field, please click on the edit icon button.',
                                            // btnCancelOnPress: () {},
                                            btnOkOnPress: () {},
                                            btnOkColor: colorOfApp)
                                        .show();
                                  }
                                },
                                icon: Icon(
                                  Icons.system_update_alt_outlined,
                                  size: 26,
                                  color: colorOfApp,
                                ),
                                label: Text(
                                  'Update',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorOfApp,
                                      fontSize: 17),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30, right: 5),
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: colorOfApp, width: 2)),
          elevation: 10,
          // backgroundColor: colorOfApp,
          onPressed: () {
            setState(() {
              isFieldActive = !isFieldActive;
            });
            if (isFieldActive) {
              Get.snackbar(
                backgroundColor: Color.fromARGB(255, 6, 190, 172),
                "",
                "",
                titleText: AutoSizeText(
                  'Activated!',
                  style: TextStyle(
                    fontSize: 15.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                messageText: AutoSizeText(
                  textAlign: TextAlign.center,
                  'Now! You can modify or update the active fields.',
                  style: TextStyle(
                    letterSpacing: 0.3,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              );
            }
          },
          child: Icon(
            Icons.edit,
            color: colorOfApp,
          ),
        ),
      ),
    );
  }

  Widget BottomSheet(BuildContext context) {
    return Card(
      elevation: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          AutoSizeText(
            "Choose profile image.",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15.5, fontWeight: FontWeight.w500, color: colorOfApp),
          ),
          ListTile(
            leading: new Icon(
              Icons.highlight_remove_sharp,
              color: Colors.red,
            ),
            title: new Text(
              'Cencel',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: new Icon(
              color: themeController.isDark.value
                  ? Colors.white
                  : Colors.deepPurple,
              Icons.image,
            ),
            title: new Text(
              'Gallery',
              style: TextStyle(
                color: themeController.isDark.value
                    ? Colors.white
                    : Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              pickImageFromGallery().whenComplete(() {
                userImageUpdate(widget.usersInfo.m_id, file);
              });
            },
          ),
          ListTile(
            leading: new Icon(
              Icons.camera,
              color: themeController.isDark.value
                  ? Colors.white
                  : Colors.deepPurple,
            ),
            title: new Text(
              'Camera',
              style: TextStyle(
                color: themeController.isDark.value
                    ? Colors.white
                    : Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);

              pickImageFromCamera().whenComplete(() {
                userImageUpdate(widget.usersInfo.m_id, file);
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
