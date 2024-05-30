// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, duplicate_ignore, unused_local_variable, must_be_immutable, await_only_futures, curly_braces_in_flow_control_structures, prefer_interpolation_to_compose_strings, prefer_final_fields, unnecessary_import, no_logic_in_create_state

import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/Model_Class/contacts_model.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:http/http.dart' as http;
import 'package:mypay/main.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../GetxController/Customers_controller.dart';

class AddCustomer extends StatefulWidget {
  // String contact_name, contact_phone;
  Contacts contactsobj;
  File? image;
  AddCustomer(this.contactsobj, this.image);

  @override
  State<AddCustomer> createState() => _AddCustomerState(contactsobj, image);
}

class _AddCustomerState extends State<AddCustomer> {
  Contacts contactsobj;
  File? image;
  _AddCustomerState(this.contactsobj, this.image);
  final formKEY = GlobalKey<FormState>();

  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool isScroll = false;
  bool isButtonActive = false;
  ImagePicker picker = ImagePicker();
  late SharedPreferences sp;

  CustomersController _controller = Get.put(CustomersController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: contactsobj.name);
    phoneController = TextEditingController(text: contactsobj.phone);
    getlogin_id();
  }

  File? file;

  String loginid = '';
  void getlogin_id() async {
    sp = await SharedPreferences.getInstance();
    loginid = sp.getString('sp_id') ?? "";
    print(loginid);
  }

  Future<void> addCustomers(String cname, String cphone, String caddress,
      String customer_id, File? cimage) async {
    try {
      // This line creates a multipart HTTP POST request.
      var request = await http.MultipartRequest(
        "POST",
        Uri.parse(Myurl.fullurl + "add_customer.php"),
        //  URI to which the request will be sent.
      );
      // These lines set the fields of the request.
      request.fields['uname'] = cname;
      request.fields['cid'] = customer_id;
      request.fields['uphone'] = cphone;
      request.fields['uaddress'] = caddress;
      if (cimage != null)
        request.files.add(
          await http.MultipartFile.fromBytes('uimage', cimage.readAsBytesSync(),
              filename: cimage.path.split("/").last),
        );

      var response = await request.send();

      // This line converts the streamed response into an http.Response object.
      var responded = await http.Response.fromStream(response);
      var jsondata = jsonDecode(responded.body);

      if (jsondata['status'] == true) {
        if (!mounted) return;
        AllCustomers customerInfo = AllCustomers(
          cid: jsondata['c_id'].toString(),
          cname: jsondata['c_name'].toString(),
          cphone: jsondata['c_phone'].toString(),
          caddress: jsondata['c_address'].toString(),
          cimage: jsondata['c_image'].toString(),
        );

        _controller.items.add(customerInfo);

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon: false,
          descTextStyle: TextStyle(fontSize: 15),
          title: 'Successfull.',
          desc:
              "Congratulations! Customer ${customerInfo.cname} has been successfully added.",
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          btnOkOnPress: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ).show();
        Get.snackbar(
          backgroundColor: Color.fromARGB(173, 117, 210, 222),
          "",
          "",
          titleText: AutoSizeText(
            "Added!",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          messageText: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 15),
              children: [
                TextSpan(text: "Congratulations! "),
                TextSpan(
                  text: customerInfo.cname,
                  style: TextStyle(
                      // fontFamily: 'KaushanScript',
                      color: Colors.greenAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3),
                ),
                TextSpan(text: " has been successfully added."),
              ],
            ),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        Fluttertoast.showToast(msg: jsondata['msg']);
        Navigator.pop(context);
      }
    } catch (e) {
      print('${e.toString()} error in code');
      Fluttertoast.showToast(msg: e.toString());
      Navigator.pop(context);
    }
  }

  ThemeController themeController = Get.put(ThemeController());
  double mqheight = 450.0;
  @override
  Widget build(BuildContext context) {
    var fieldStyle = TextStyle(
      color: Colors.black,
      fontSize: 15,
      letterSpacing: 0.3,
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.normal,
    );
    return Scaffold(
      backgroundColor: themeController.isDark.value
          ? Color.fromARGB(255, 7, 16, 34)
          : Colors.white,
      appBar: AppBar(
        backgroundColor: colorOfApp,
        title: Text("Add Customer"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                imageContainer(true),

                Container(
                  height: mqheight,
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 50),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: themeController.isDark.value
                        ? Colors.indigo[50]
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5, spreadRadius: 2, color: colorOfApp)
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKEY,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 70,
                          ),
                          TextFormField(
                            style: fieldStyle,
                            decoration: InputDecoration(
                              hintText: 'Name',
                              hintStyle: fieldStyle,
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                              errorStyle: TextStyle(color: Colors.red),
                              enabledBorder: UnderlineInputBorder(),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                            ),
                            controller: nameController,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Enter Name.';
                              else if (value.length < 3)
                                return 'Name must be more than 2 charater.';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            style: fieldStyle,
                            decoration: InputDecoration(
                              hintText: 'Phone',
                              hintStyle: fieldStyle,
                              enabledBorder: UnderlineInputBorder(),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              errorStyle: TextStyle(color: Colors.red),
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Colors.black,
                              ),
                            ),
                            controller: phoneController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Phone Number.';
                              } else if (value.length != 10)
                                return 'Mobile Number must be of 10 digit.';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            style: fieldStyle,
                            decoration: InputDecoration(
                              hintText: 'Address',
                              hintStyle: fieldStyle,
                              enabledBorder: UnderlineInputBorder(),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              errorStyle: TextStyle(color: Colors.red),
                              prefixIcon: Icon(
                                Icons.add_location_alt_outlined,
                                color: Colors.black,
                              ),
                            ),
                            controller: addressController,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Enter Address, Village, City.';
                              else if (value.length < 3)
                                return 'Name must be more than 2 charater.';
                              return null;
                            },
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorOfApp,
                              ),
                              onPressed: () {
                                if (formKEY.currentState!.validate()) {
                                  setState(() {
                                    isButtonActive = !isButtonActive;
                                  });
                                  print('Add person');
                                  addCustomers(
                                      nameController.text.trim(),
                                      phoneController.text.trim(),
                                      addressController.text.trim(),
                                      loginid.trim(),
                                      file ?? image);
                                } else {
                                  setState(() {
                                    isScroll = !isScroll;
                                  });
                                  Fluttertoast.showToast(
                                      msg: 'Please provides required details');
                                }
                              },
                              icon: isButtonActive
                                  ? Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                        color: Colors.blueGrey,
                                      ),
                                    )
                                  : Icon(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      Icons.person_add,
                                      size: 28,
                                    ),
                              label: isButtonActive
                                  ? Text(
                                      'Adding ..',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text(
                                      'Add',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // Positioned(child: Icon(Icons.add_a_photo_outlined)),
                imageContainer(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageContainer(bool isShadow) {
    return AnimatedPositioned(
      curve: Curves.easeInOut,
      duration: Duration(seconds: 3),
      // bottom: isScroll ? 480 : 490,
      bottom: 490,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(9.0),
            height: 170,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: themeController.isDark.value
                  ? Colors.indigo[50]
                  : Colors.white,
              boxShadow: [
                if (isShadow)
                  BoxShadow(spreadRadius: 2, blurRadius: 5, color: colorOfApp)
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
                  : image != null
                      ? CircleAvatar(
                          backgroundColor: Colors.black45,
                          backgroundImage: FileImage(image!),
                        )
                      : CircleAvatar(
                          backgroundColor: colorOfApp,
                          child: Icon(
                            Icons.person,
                            size: 80,
                          ),
                        ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                  // backgroundColor: Color(0xff003049),
                  context: context,
                  builder: (context) => BottonSheet(context));
            },
            icon: Icon(
              Icons.add_a_photo_outlined,
              color: colorOfApp,
              size: 20,
            ),
            label: Text(
              'Add Photo',
              style: TextStyle(fontSize: 13, color: colorOfApp),
            ),
          ),
        ],
      ),
    );
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

  // bool isBottomSheet=false;
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
