// ignore_for_file: prefer_const_constructors, await_only_futures, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/calculator/custom_textfield.dart';
import 'package:mypay/main.dart';
import 'package:http/http.dart' as http;
import 'package:mypay/screen/loading.dart';
import 'package:mypay/screen/transaction_history.dart';
import 'package:mypay/url/db_connection.dart';

class AmountInput extends StatefulWidget {
  AllCustomers customer;
  String page, pageVal;
  AmountInput(this.customer, this.page, this.pageVal);

  @override
  State<AmountInput> createState() =>
      _AmountInputState(customer, page, pageVal);
}

class _AmountInputState extends State<AmountInput> {
  AllCustomers customer;
  String page, pageVal, value = '';
  _AmountInputState(this.customer, this.page, this.pageVal);
  DateTime current_DateTime = DateTime.now();

  TextEditingController _timeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final amountKey = GlobalKey<FormState>();

  ImagePicker picker = ImagePicker();
  File? file;
  bool isActiveField = false;
  ThemeController themeCon = Get.put(ThemeController());

  Future getCurrentDateTime() async {
    _dateController.text =
        DateFormat('dd-MM-yyyy').format(current_DateTime).toString().trim();
    _timeController.text =
        DateFormat.jm().format(current_DateTime).toString().trim();
  }

  String _formatTime(TimeOfDay time) {
    return DateFormat('hh:mm:a')
        .format(DateTime(0, 0, 0, time.hour, time.minute));
  }

  void getTime() async {
    TimeOfDay? pickTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickTime != null && pickTime != current_DateTime) {
      _timeController.text = _formatTime(pickTime).trim();
    } else {
      _timeController.text = DateFormat.jm().format(current_DateTime).trim();
    }
  }

  void getDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime(2050),
    );
    if (pickDate != null && pickDate != current_DateTime) {
      _dateController.text =
          DateFormat('dd-MM-yyyy').format(pickDate).toString().trim();
    } else {
      _dateController.text =
          DateFormat('dd-MM-yyyy').format(current_DateTime).toString().trim();
    }
  }

  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final imageTemp = File(pickedFile.path);
    setState(() => this.file = imageTemp);
    // this.file = imageTemp;
    print("gallery.......=>${file}");
  }

  Future pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    final imageTemp = File(pickedFile.path);
    setState(() => this.file = imageTemp);
    // this.file = imageTemp;
    print("camera.......=>${file}");
  }

  Future insertAmount(
    String cus_id,
    String giveValue,
    String getValue,
    String time,
    String date,
    String description,
    File? attach,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(),
    );
    try {
      var request = await http.MultipartRequest(
          "POST", Uri.parse(Myurl.fullurl + "insert_payments.php"));
      request.fields['customer_id'] = cus_id;
      request.fields['give'] = giveValue;
      request.fields['get'] = getValue;
      request.fields['transfer_time'] = time;
      request.fields['transfer_date'] = date;
      request.fields['transfer_description'] = description;

      if (attach != null)
        request.files.add(
          await http.MultipartFile.fromBytes(
            'transfer_attach',
            attach.readAsBytesSync(),
            filename: attach.path.split("/").last,
          ),
        );

      var res = await request.send();
      var responded = await http.Response.fromStream(res);
      var jsondata = jsonDecode(responded.body.toString());
      if (jsondata['status'] == true) {
        if (mounted) Fluttertoast.showToast(msg: jsondata['msg']);

        value == 'transactionPage'
            ? AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.topSlide,
                showCloseIcon: false,
                title: 'Amount Added.',
                desc: "The amount has been added successfully.",
                titleTextStyle: TextStyle(fontSize: 15),
                dismissOnTouchOutside: false,
                dismissOnBackKeyPress: false,
                btnOkOnPress: () {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionHistory(customer),
                    ),
                  );
                },
              ).show()
            : AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.topSlide,
                showCloseIcon: false,
                title: 'Amount Added.',
                desc: "The amount has been added successfully.",
                titleTextStyle: TextStyle(fontSize: 15),
                dismissOnTouchOutside: false,
                dismissOnBackKeyPress: false,
                btnOkOnPress: () {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionHistory(customer),
                    ),
                  );
                },
              ).show();
      } else {
        Fluttertoast.showToast(msg: jsondata['msg']);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDateTime();
    value = pageVal;
    print(value);
    print(_timeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          themeCon.isDark.value ? Color.fromARGB(255, 7, 16, 34) : Colors.white,
      appBar: AppBar(
        backgroundColor: colorOfApp,
        title: AutoSizeText(page),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: amountKey,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5),
                    children: [
                      page == "You Got"
                          ? TextSpan(text: 'You will get ₹')
                          : TextSpan(text: 'You will have to give ₹'),
                      TextSpan(
                        text: amountController.text.toString(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      page == "You Got"
                          ? TextSpan(text: ' from ')
                          : TextSpan(text: ' to '),
                      TextSpan(
                        text: '${customer.cname}.',
                        style: TextStyle(
                          color: colorOfApp,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(
                  height: 70,
                ),
                //Enter amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      'Enter amount :',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null) {
                            return "Please enter value.";
                          }
                          final n = num.tryParse(value);
                          if (n == null) {
                            return "'$value' is not a valid number";
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            isActiveField = value.isNotEmpty;
                          });
                        },
                        controller: amountController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                        ],
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        cursorErrorColor:
                            Theme.of(context).colorScheme.onBackground,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          hintText: '₹ 0',
                          hintStyle: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                isActiveField
                    ? TextFormField(
                        controller: descriptionController,
                        maxLength: 1000,
                        decoration: InputDecoration(
                          labelText: 'Description',

                          labelStyle: TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w500),
                          disabledBorder: UnderlineInputBorder(),
                          // enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground)),
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 20,
                ),
                isActiveField
                    ? AutoSizeText(
                        'Enter receipt',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 5,
                ),
                isActiveField
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) => BottonSheet(context));
                            },
                            icon: Icon(
                              Icons.add_a_photo_sharp,
                              color: colorOfApp,
                            ),
                            label: AutoSizeText(
                              'Select image.',
                              style: TextStyle(color: colorOfApp),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                            child: VerticalDivider(
                              // width: 6,
                              color: themeCon.isDark.value
                                  ? Color.fromARGB(255, 103, 102, 102)
                                  : titleColor.withOpacity(.3),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: file != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(file!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : AutoSizeText(
                                    'No receipt.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                          ),
                        ],
                      )
                    : SizedBox(),
                isActiveField
                    ? SizedBox(
                        height: 15,
                        child: Divider(
                          height: 1,
                          color: themeCon.isDark.value
                              ? Color.fromARGB(255, 103, 102, 102)
                              : titleColor.withOpacity(.3),
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 20,
                ),

                //Enter Date & Time
                isActiveField
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  'Enter Date :',
                                  style: TextStyle(
                                      // fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      width: 1,
                                    ),
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AutoSizeText(
                                        _dateController.text.toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          getDate();
                                        },
                                        icon: Icon(
                                          Icons.calendar_month,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AutoSizeText(
                                'Enter Time :',
                                style: TextStyle(
                                  // fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      _timeController.text.toString(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        getTime();
                                      },
                                      icon: Icon(
                                        Icons.watch_later_outlined,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SizedBox(),
                // Spacer(),
                SizedBox(
                  height: 120,
                ),
                isActiveField
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: colorOfApp,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.white),
                          onPressed: () {
                            if (amountKey.currentState!.validate()) {
                              page == "You Got"
                                  ? insertAmount(
                                      customer.cid,
                                      '0',
                                      amountController.text.toString(),
                                      _timeController.text,
                                      _dateController.text.toString(),
                                      descriptionController.text.toString(),
                                      file)
                                  : insertAmount(
                                      customer.cid.toString(),
                                      amountController.text.toString(),
                                      "0",
                                      _timeController.text,
                                      _dateController.text.toString(),
                                      descriptionController.text.toString(),
                                      file);
                            } else {
                              Fluttertoast.showToast(msg: "Insert Failed");
                            }
                          },
                          icon: Icon(
                            Icons.save_alt_outlined,
                            size: 29,
                            color: colorOfApp,
                          ),
                          label: Padding(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: page == "You Got"
                                ? AutoSizeText(
                                    'Save to Got',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorOfApp,
                                        fontSize: 18,
                                        letterSpacing: 0.5),
                                  )
                                : AutoSizeText(
                                    'Save to Gave',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorOfApp,
                                        fontSize: 18,
                                        letterSpacing: 0.5),
                                  ),
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
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
                    "Select Image!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      // color: Colors.blue,
                    ),
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
                        color: themeCon.isDark.value
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
                            color: themeCon.isDark.value
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
                        color: themeCon.isDark.value
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
                            color: themeCon.isDark.value
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
