// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/Model_Class/transaction.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:http/http.dart' as http;

class IndividualTransaction extends StatefulWidget {
  IndividualTransaction(
      {super.key, required this.transaction, required this.customer});
  AllTransaction transaction;
  AllCustomers customer;

  @override
  State<IndividualTransaction> createState() => _IndividualTransactionState();
}

class _IndividualTransactionState extends State<IndividualTransaction> {
  ThemeController _themeController = Get.put(ThemeController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.transaction.attach.toString());
  }

  Future transactionDelete(String transactionId, customerId) async {
    try {
      Map data = {
        'customer_id': customerId,
        'transfer_id': transactionId,
      };
      var response = await http.post(
          Uri.parse(Myurl.fullurl + "transactions_delete.php"),
          body: data);

      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == true) {
        Fluttertoast.showToast(msg: jsondata['msg']);
      } else {
        Fluttertoast.showToast(msg: 'error');
        print(jsondata['msg']);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final variableStyle = TextStyle(
      fontSize: 15.7,
      fontWeight: FontWeight.bold,
      color: colorOfApp,
      overflow: TextOverflow.ellipsis,
    );
    final valueStyle = TextStyle(
        fontWeight: FontWeight.w500, fontSize: 13.5, color: Colors.black);
    return Scaffold(
      backgroundColor: _themeController.isDark.value
          ? Color.fromARGB(255, 7, 16, 34)
          : Colors.white,
      appBar: AppBar(
        backgroundColor: colorOfApp,
        title: AutoSizeText('Transaction.'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Card(
                shadowColor: colorOfApp,
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.5,
                      color: colorOfApp,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: widget.customer.cimage == ""
                            ? CircleAvatar(
                                radius: 27,
                                backgroundImage:
                                    AssetImage('assets/images/my.jpg'),
                              )
                            : CachedNetworkImage(
                                width: 50,
                                height: 50,
                                imageUrl: Myurl.fullurl +
                                    Myurl.customers_imageUrl +
                                    widget.customer.cimage,
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
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AutoSizeText(
                        widget.customer.cname,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          AutoSizeText(
                            'Balance',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          widget.transaction.availableBalance.isNegative
                              ? AutoSizeText(
                                  widget.transaction.availableBalance
                                      .abs()
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : AutoSizeText(
                                  widget.transaction.availableBalance
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                shadowColor: colorOfApp,
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.5,
                      color: colorOfApp,
                    ),
                  ),
                  child: Column(
                    children: [
                      AutoSizeText(
                        'Balance entries details.',
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              AutoSizeText(
                                'Date',
                                style: variableStyle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              AutoSizeText(
                                widget.transaction.date,
                                style: valueStyle,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              AutoSizeText(
                                'Time',
                                style: variableStyle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              AutoSizeText(
                                widget.transaction.time,
                                style: valueStyle,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              AutoSizeText(
                                'Paid',
                                style: variableStyle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              AutoSizeText(
                                widget.transaction.give == 0.toString()
                                    ? '-'
                                    : widget.transaction.give,
                                style: valueStyle,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              AutoSizeText(
                                'Received',
                                style: variableStyle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              AutoSizeText(
                                widget.transaction.get == 0.toString()
                                    ? '-'
                                    : widget.transaction.get,
                                style: valueStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                shadowColor: colorOfApp,
                elevation: 2.5,
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.5,
                      color: colorOfApp,
                    ),
                  ),
                  child: Column(
                    children: [
                      AutoSizeText(
                        'Balance entries proof.',
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            AutoSizeText(
                              'Description: ',
                              style: variableStyle,
                            ),
                            AutoSizeText(
                              widget.transaction.description,
                              style: valueStyle,
                            ),
                          ],
                        ),
                      ),
                      AutoSizeText(
                        'Receipt: ',
                        style: variableStyle,
                      ),
                      widget.transaction.attach == ""
                          ? SizedBox()
                          : Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                // color: Colors.red,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    Myurl.fullurl +
                                        Myurl.amountProof_imageUrl +
                                        widget.transaction.attach,
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red,
                      ),
                    ]),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    transactionDelete(
                            widget.transaction.transfer_id, widget.customer.cid)
                        .whenComplete(() {
                      setState(() {
                        widget.transaction.removeWhere((item) =>
                            item.transfer_id == widget.transaction.transfer_id);
                      });
                      Navigator.pop(context);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: colorOfApp,
                        content: Text(
                          'Transaction deleted successfully.',
                          style: TextStyle(color: Colors.lightGreenAccent),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.delete_outline_outlined,
                    color: Colors.red,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.red,
                    ),
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
