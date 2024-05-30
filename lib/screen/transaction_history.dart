// ignore_for_file: must_be_immutable, unnecessary_string_interpolations, unused_import, prefer_const_constructors, unrelated_type_equality_checks

import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/state_manager.dart';
import 'package:mypay/GetxController/Transactions_controller.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/Model_Class/transaction.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/Choose_Transaction.dart';
import 'package:mypay/screen/Customer_Profile.dart';
import 'package:mypay/screen/Individual_Transaction_Details.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistory extends StatefulWidget {
  AllCustomers customers;
  TransactionHistory(this.customers);

  @override
  State<TransactionHistory> createState() =>
      _TransactionHistoryState(customers);
}

class _TransactionHistoryState extends State<TransactionHistory> {
  AllCustomers customers;
  _TransactionHistoryState(this.customers);
  List<AllTransaction> transaction_details = [];
  late SharedPreferences sp;
  ThemeController _themeController = Get.put(ThemeController());
  TotalTransactions controller = Get.put(TotalTransactions());
  double availableBalance = 0.0;
  List<AllTransaction> filterTransaction = [];

  Future getTransaction(String customerId) async {
    double newGot = 0.0, newGave = 0.0;
    try {
      Map data = {'c_id': customerId};
      var res = await http
          .post(Uri.parse(Myurl.fullurl + "all_transaction.php"), body: data);
      var jsondata = jsonDecode(res.body.toString());
      availableBalance = 0.0;
      if (jsondata['status'] == true) {
        if (mounted) transaction_details.clear();
        for (int i = 0; i < jsondata['data'].length; i++) {
          newGot += double.parse(jsondata['data'][i]['you_get']);
          newGave += double.parse(jsondata['data'][i]['you_give']);
          availableBalance = (newGot - newGave);

          AllTransaction _transaction = AllTransaction(
              transfer_id: jsondata['data'][i]['transfer_id'],
              customer_id: jsondata['data'][i]['customer_id'],
              give: jsondata['data'][i]['you_give'],
              get: jsondata['data'][i]['you_get'],
              time: jsondata['data'][i]['time'],
              date: jsondata['data'][i]['date'],
              description: jsondata['data'][i]['description'],
              attach: jsondata['data'][i]['attach'],
              availableBalance: availableBalance);
          transaction_details.insert(0, _transaction);
          // transfer.transactionItems.insert(0, _transaction);
        }
      }
      controller.totalTransactions.value = availableBalance;
    } catch (e) {
      print(e.toString());
    }
    return transaction_details;
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

  TextEditingController _searchController = TextEditingController();

  void _filterTransaction(String query) {
    query.toLowerCase();
    filterTransaction.clear();
    if (query.isEmpty) {
      transaction_details;
    } else {
      List<AllTransaction> selectedItems = [];
      selectedItems.addAll(
        transaction_details.where((transactions) =>
            transactions.date.toLowerCase().contains(query) ||
            transactions.description.toLowerCase().contains(query) ||
            transactions.get.contains(query) ||
            transactions.give.contains(query)),
      );
      setState(() {
        filterTransaction = selectedItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      letterSpacing: .5,
      // color: _themeController.isDark.value ? Colors.white54 : Colors.black45,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      backgroundColor: _themeController.isDark.value
          ? Color.fromARGB(255, 7, 16, 34)
          : Colors.white,
      appBar: AppBar(
        backgroundColor: colorOfApp,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerProfile(customers),
              ),
            ).then((value) {
              if (!mounted) return;
              setState(() {});
            });
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back)),
            customers.cimage != ""
                ? CachedNetworkImage(
                    width: 45,
                    height: 45,
                    imageUrl: Myurl.fullurl +
                        Myurl.customers_imageUrl +
                        customers.cimage,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                : const CircleAvatar(
                    radius: 23,
                    backgroundImage: AssetImage('assets/images/my.jpg'),
                  ),
            const SizedBox(
              width: 15,
            ),
            AutoSizeText(
              customers.cname,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ]),
        ),
      ),
      body: Container(
        // padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  controller.totalTransactions.value == 0
                      ? SizedBox()
                      : Expanded(
                          child: Card(
                            elevation: 4,
                            shadowColor: _themeController.isDark.value
                                ? Colors.white
                                : Colors.black,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.5,
                                  color: colorOfApp,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: controller.totalTransactions
                                                    .isNegative
                                                ? 'You will receive amount '
                                                : 'You have to pay amount ',
                                          ),
                                          TextSpan(
                                            text:
                                                '₹${controller.totalTransactions.value.abs()}',
                                            style: TextStyle(
                                              color: controller
                                                      .totalTransactions
                                                      .isNegative
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: controller.totalTransactions
                                                    .isNegative
                                                ? ' from ${customers.cname}.'
                                                : ' to ${customers.cname}.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    'Make transactions.',
                    style: TextStyle(
                      // color: colorOfApp,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: colorOfApp),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChooseTransition(customers, 'transaction'),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.deepPurple,
                    ),
                    label: AutoSizeText(
                      'New Transaction',
                      style: TextStyle(
                        // color: colorOfApp,
                        color: Colors.deepPurple,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  _filterTransaction(value.trim());
                  print(_searchController.text.toString());
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search transactions.',
                  labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _themeController.isDark.value
                          ? Colors.white38
                          : Colors.black45),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorOfApp),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            AutoSizeText(
              'Amount',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _themeController.isDark.value
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4),
            ),
            Expanded(
              child: FutureBuilder(
                  future: getTransaction(customers.cid),
                  builder: (context, data) {
                    if (data.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SpinKitCircle(
                          color: colorOfApp,
                        ),
                      );
                    } else if (transaction_details.isEmpty) {
                      return Center(
                        child: AutoSizeText(
                          'There is no Transactions found.',
                          style: TextStyle(
                              fontSize: 15.5,
                              letterSpacing: 0.3,
                              color: Colors.red),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchController.text.isEmpty
                            ? transaction_details.length
                            : filterTransaction.length,
                        itemBuilder: (context, index) {
                          final transactions = _searchController.text.isEmpty
                              ? transaction_details[index]
                              : filterTransaction[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IndividualTransaction(
                                      transaction: transactions,
                                      customer: customers,
                                    ),
                                  )).then((value) => setState(() {}));
                            },
                            child: Dismissible(
                              key: Key(transactions.transfer_id.toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                var delete_id = transactions.transfer_id;
                                print(delete_id);
                                transactionDelete(delete_id, customers.cid)
                                    .whenComplete(() {
                                  setState(() {
                                    transactions.removeWhere((item) =>
                                        item.transfer_id == delete_id);
                                  });
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: colorOfApp,
                                    content: Text(
                                      'Transaction deleted successfully.',
                                      style: TextStyle(
                                          color: Colors.lightGreenAccent),
                                    ),
                                  ),
                                );
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(),
                                elevation: 5,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: transactions.give != 0.toString()
                                            ? Colors.red[200]
                                            : Colors.green[200],
                                        child: ListTile(
                                          title: AutoSizeText(
                                            textAlign: TextAlign.center,
                                            transactions.get != 0.toString()
                                                ? 'Received'
                                                : 'Paid',
                                            style: TextStyle(
                                              fontSize: 14,
                                              letterSpacing: .5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          subtitle: AutoSizeText(
                                            transactions.date,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    transactions.get != 0.toString()
                                        ? Expanded(
                                            child: Container(
                                              // padding: EdgeInsets.all(4),
                                              // color: Colors.green[10],
                                              child: ListTile(
                                                title: AutoSizeText(
                                                  textAlign: TextAlign.center,
                                                  transactions.get ==
                                                          0.toString()
                                                      ? ''
                                                      : '₹${transactions.get}',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    // fontSize: 14.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: ListTile(
                                              title: AutoSizeText(
                                                textAlign: TextAlign.center,
                                                transactions.give ==
                                                        0.toString()
                                                    ? ''
                                                    : '₹${transactions.give}',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  // fontSize: 14.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                    Expanded(
                                      child: Container(
                                        // padding: EdgeInsets.all(4),
                                        color: colorOfApp.withOpacity(0.1),

                                        child: ListTile(
                                          title: AutoSizeText(
                                            'Balance',
                                            textAlign: TextAlign.end,
                                            style: textStyle,
                                          ),
                                          subtitle: transactions
                                                  .availableBalance.isNegative
                                              ? AutoSizeText(
                                                  '- ₹${transactions.availableBalance.abs()}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    color: _themeController
                                                            .isDark.value
                                                        ? Colors.red[200]
                                                        : Colors.red[300],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : AutoSizeText(
                                                  '+ ₹${transactions.availableBalance.abs()}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    color: _themeController
                                                            .isDark.value
                                                        ? Colors.green[300]
                                                        : Colors.green[400],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
