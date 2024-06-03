// ignore_for_file: prefer_const_constructors, must_be_immutable, unnecessary_import, no_logic_in_create_state, prefer_final_fields, await_only_futures, curly_braces_in_flow_control_structures, unnecessary_new, prefer_interpolation_to_compose_strings, deprecated_member_use, prefer_const_declarations, unnecessary_brace_in_string_interps, unnecessary_this, non_constant_identifier_names, avoid_print, use_key_in_widget_constructors

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
import 'package:image_picker/image_picker.dart';
import 'package:mypay/GetxController/Customers_controller.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/loading.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProfile extends StatefulWidget {
  AllCustomers customerInfo;
  CustomerProfile(this.customerInfo);

  @override
  State<CustomerProfile> createState() => _CustomerProfileState(customerInfo);
}

class _CustomerProfileState extends State<CustomerProfile> {
  AllCustomers customerInfo;

  _CustomerProfileState(this.customerInfo);
  ThemeController _themeController = Get.put(ThemeController());
  var customerName = TextEditingController();
  var customerPhone = TextEditingController();
  var customerAddress = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isActiveField = false;
  late SharedPreferences sp;
  String userid = '';
  ImagePicker picker = ImagePicker();
  File? file;
  final CustomersController _customersController =
      Get.put(CustomersController());
  final TransferCustomers transferCustomers = Get.put(TransferCustomers());

  Future customerImageChange(String u_id, c_id, File? cimage) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(),
    );
    try {
      var request = await http.MultipartRequest(
          'POST', Uri.parse(Myurl.fullurl + "customer_image_update.php"));
      request.fields['uid'] = u_id;
      request.fields['cid'] = c_id;

      if (cimage != null) {
        request.files.add(
          await http.MultipartFile.fromBytes(
              "uimage", cimage!.readAsBytesSync(),
              filename: cimage!.path.split("/").last),
        );
      }

      var response = await request.send();
      var responsed = await http.Response.fromStream(response);
      var jsondata = jsonDecode(responsed.body);
      if (jsondata['status'] == true) {
        Navigator.pop(context);
        if (!mounted) return;
        setState(() {
          customerInfo.cimage = jsondata['imgtitle'];
        });
        Fluttertoast.showToast(msg: jsondata['msg']);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);
    }
  }

  Future<void> customerNameUpdate(String u_Id, c_Id, c_Name, c_Address) async {
    showDialog(
        context: context,
        builder: (context) {
          return const LoadingDialog();
        });
    try {
      Map data = {
        'uid': u_Id,
        'cid': c_Id,
        'cname': c_Name,
        'caddress': c_Address,
      };
      var response = await http.post(
          Uri.parse(Myurl.fullurl + "customer_details_update.php"),
          body: data);
      var jsondata = jsonDecode(response.body.toString());

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
          btnOkColor: colorOfApp,
        ).show();
        setState(() {
          if (customerName.text != customerInfo.cname) {
            customerInfo.cname = jsondata['name'];
          }
          if (customerAddress.text != customerInfo.caddress) {
            customerInfo.caddress = jsondata['address'];
          }
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

  Future deleteCustomer(String uid, cid) async {
    Map data = {
      'user_id': uid,
      'customer_id': cid,
    };
    showDialog(
        context: context,
        builder: (context) {
          return const LoadingDialog();
        });
    try {
      var res = await http
          .post(Uri.parse(Myurl.fullurl + "customer_delete.php"), body: data);
      var jsondata = jsonDecode(res.body);
      if (jsondata['status'] == true) {
        Navigator.pop(context);
        Get.snackbar(
          backgroundColor: Color.fromARGB(173, 117, 210, 222),
          "",
          "",
          titleText: AutoSizeText(
            'Deleted!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          messageText: AutoSizeText(
            textAlign: TextAlign.center,
            'Customer Delete Successful.',
            style: TextStyle(
              letterSpacing: 0.3,
              // fontSize: 13,
              color: Colors.black,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      print('delete dashboard');
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void deleteItem(String id) {
    transferCustomers.transactionItems.removeWhere((item) => item.cid == id);
    _customersController.items.removeWhere((item) => item.cid == id);
    transferCustomers.transactionItems.refresh();
    _customersController.items.refresh();
  }

  void getuser_id() async {
    sp = await SharedPreferences.getInstance();
    userid = sp.getString('sp_id') ?? "";
  }

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

  @override
  void initState() {
    super.initState();
    customerName = TextEditingController(text: customerInfo.cname);
    customerPhone = TextEditingController(text: customerInfo.cphone);
    customerAddress = TextEditingController(text: customerInfo.caddress);
    getuser_id();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  void dispose() {
    DeleteFromWhere.value = '';
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeController.isDark.value
          ? Color.fromARGB(255, 7, 16, 34)
          : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorOfApp,
        title: AutoSizeText("${customerInfo.cname}'s profile"),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    // color: Colors.blue,
                    gradient: LinearGradient(
                        colors: [colorOfApp, colorOfApp],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 0.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                ),
                Positioned(
                  bottom: -50.0,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            backgroundColor: Colors.transparent,
                            appBar: AppBar(
                              title: Text(
                                //name
                                customerInfo.cname,
                                style: TextStyle(fontSize: 22),
                              ),
                              elevation: 0.5,
                              backgroundColor: Colors.transparent,
                            ),
                            body: SafeArea(
                              child: Material(
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 26,
                                      ),
                                    ),
                                    Container(
                                      child: customerInfo.cimage != ''
                                          ? Image.network(
                                              Myurl.fullurl +
                                                  Myurl.customers_imageUrl +
                                                  customerInfo.cimage,
                                              fit: BoxFit.cover,
                                            )
                                          : Center(
                                              child: Container(
                                                child: Text(
                                                  "No Image",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      letterSpacing: 0.5,
                                                      color: Colors.white54,
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: _themeController.isDark.value
                          ? Color.fromARGB(255, 7, 16, 34)
                          : Colors.white,
                      child: CircleAvatar(
                        radius: 77,
                        backgroundColor: colorOfApp,
                        child: customerInfo.cimage != ""
                            ? ClipRRect(
                                child: CachedNetworkImage(
                                  imageUrl: Myurl.fullurl +
                                      Myurl.customers_imageUrl +
                                      customerInfo.cimage,
                                  // fit: BoxFit.fill,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  imageBuilder: (context, imageProvider) {
                                    return Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          image: DecorationImage(
                                              image: imageProvider),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: colorOfApp,
                                radius: 77,
                                child: Icon(
                                  Icons.person,
                                  size: 100,
                                  color: Colors.blueGrey,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
            TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      context: context,
                      builder: (context) => bottomSheet(context));
                },
                icon: Icon(
                  Icons.add_a_photo_outlined,
                  color: colorOfApp,
                  size: 25,
                ),
                label: AutoSizeText(
                  'Add image.',
                  style: TextStyle(
                    color: colorOfApp,
                    fontSize: 15,
                  ),
                )),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  shadowColor: colorOfApp,
                  elevation: 15,
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 20, left: 25, right: 25, bottom: 65),
                    // margin: EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1.5,
                        color: colorOfApp,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2.5,
                          spreadRadius: 0.5,
                          color: _themeController.isDark.value
                              ? Colors.tealAccent
                              : colorOfApp,
                          offset: Offset(0.2, 0.2),
                        )
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: customerName,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Enter Name';
                              else if (value.length < 3)
                                return 'Name must be more than 2 charater';
                              return null;
                            },
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Name.',
                              labelStyle: TextStyle(color: Colors.black),
                              prefixIcon: Icon(
                                Icons.person,
                                size: 26,
                                color: colorOfApp,
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: customerPhone,
                                  enabled: false,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelStyle: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.phone_sharp,
                                      size: 26,
                                      color: colorOfApp,
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    try {
                                      await _makePhoneCall(
                                          customerPhone.text.toString());
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Could not launch phone call'),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.call,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            controller: customerAddress,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Enter Address.';
                              else if (value.length < 3)
                                return 'Address must be more than 2 charater';
                              return null;
                            },
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.black),
                              labelText: 'Address.',
                              prefixIcon: Icon(
                                Icons.add_location_alt_outlined,
                                size: 26,
                                color: colorOfApp,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      var del_id = customerInfo.cid;
                      print(del_id);
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.topSlide,
                        titleTextStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        descTextStyle: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w500),
                        title: 'Delete Customer!',
                        desc:
                            'Are you sure you want to delete ${customerInfo.cname}?',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          DeleteFromWhere.value == 'deleteData'
                              ? deleteCustomer(userid, del_id).whenComplete(
                                  () {
                                    deleteItem(del_id);
                                    // Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                )
                              : deleteCustomer(userid, del_id).whenComplete(
                                  () {
                                    deleteItem(del_id);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                );
                        },
                      ).show();
                    },
                    icon: const Icon(
                      color: Colors.red,
                      Icons.delete_outline_outlined,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                          color: Colors.red,
                          letterSpacing: 0.3,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: colorOfApp,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        customerNameUpdate(
                          userid,
                          customerInfo.cid,
                          customerName.text,
                          customerAddress.text,
                        );
                        print(customerName.text.toString());
                        print(customerAddress.text.toString());
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please enter required details.');
                      }
                    },
                    icon: Icon(
                      Icons.system_update_alt,
                      color: colorOfApp,
                    ),
                    label: Text(
                      'Update',
                      style: TextStyle(
                          color: colorOfApp,
                          letterSpacing: 0.3,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSheet(BuildContext context) {
    return Card(
      elevation: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
              Icons.image,
              color: _themeController.isDark.value
                  ? Colors.white
                  : Colors.deepPurple,
            ),
            title: new Text(
              'Gallery',
              style: TextStyle(
                color: _themeController.isDark.value
                    ? Colors.white
                    : Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              pickImageFromGallery().whenComplete(() {
                customerImageChange(userid, customerInfo.cid, file);
              });
            },
          ),
          ListTile(
            leading: new Icon(
              Icons.camera,
              color: _themeController.isDark.value
                  ? Colors.white
                  : Colors.deepPurple,
            ),
            title: new Text(
              'Camera',
              style: TextStyle(
                color: _themeController.isDark.value
                    ? Colors.white
                    : Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              pickImageFromCamera().whenComplete(
                  () => customerImageChange(userid, customerInfo.cid, file));
            },
          ),
        ],
      ),
    );
  }
}
