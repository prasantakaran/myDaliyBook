// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, non_constant_identifier_names, prefer_interpolation_to_compose_strings, unused_import, constant_pattern_never_matches_value_type, curly_braces_in_flow_control_structures, unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/state_manager.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mypay/GetxController/Customers_controller.dart';
import 'package:mypay/GetxController/Transactions_controller.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/Book_Name_Change.dart';
import 'package:mypay/screen/Choose_Transaction.dart';
import 'package:mypay/screen/Image_view.dart';
import 'package:mypay/screen/contact_access.dart';
import 'package:mypay/screen/loading.dart';
import 'package:mypay/screen/profile_screen.dart';
import 'package:mypay/screen/splash.dart';
import 'package:mypay/screen/transaction_history.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late TabController tabController;

  final GlobalKey add = GlobalKey();
  final GlobalKey profile_view = GlobalKey();
  final GlobalKey app_theme = GlobalKey();
  final CustomersController _customersController =
      Get.put(CustomersController());
  final TransferCustomers transferCustomers = Get.put(TransferCustomers());
  var width, height;
  late SharedPreferences sp;
  final LocalAuthentication auth = LocalAuthentication();
  ThemeController themeCon = Get.put(ThemeController());
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  UserTransactionBalance balance = Get.put(UserTransactionBalance());
  LastEntriesDate _entriesDate = Get.put(LastEntriesDate());

  String id = '',
      name = '',
      email = '',
      phone = '',
      password = '',
      image = '',
      gender = '',
      bookname = '';
  late UserDetails users = UserDetails(
    m_id: id,
    m_name: name,
    m_email: email,
    m_phone: phone,
    m_password: password,
    m_image: image,
    m_gender: gender,
    m_bookname: bookname,
  );

  Future getLastEntriesDate(String uid) async {
    try {
      Map data = {'u_id': uid};
      var response = await http.post(
          Uri.parse(Myurl.fullurl + "last_transaction_date.php"),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == true) {
        var lastDate = jsondata['lastDate'];
        _entriesDate.lastDate.value = lastDate;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future getTotalBalance(String id) async {
    try {
      Map data = {'u_id': id};
      double totalGet = 0.0, totalGive = 0.0;
      balance.totalGetBalance.value = 0.0;
      balance.totalGiveBalance.value = 0.0;

      var response = await http.post(
          Uri.parse(Myurl.fullurl + "users_total_transaction.php"),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == true) {
        for (int i = 0; i < jsondata['data'].length; i++) {
          var jsonResult = double.parse(jsondata['data'][i]['result']);
          if (jsonResult > 0) {
            totalGet += double.parse(jsondata['data'][i]['result']);
            balance.totalGetBalance.value = totalGet;
          } else {
            totalGive += double.parse(jsondata['data'][i]['result']);
            balance.totalGiveBalance.value = totalGive;
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getUserInformation() async {
    sp = await SharedPreferences.getInstance();
    id = sp.getString('sp_id') ?? '';
    name = sp.getString('sp_name') ?? '';
    email = sp.getString('sp_email') ?? '';
    phone = sp.getString('sp_phone') ?? '';
    password = sp.getString('sp_password') ?? '';
    image = sp.getString('sp_image') ?? '';
    gender = sp.getString('sp_gender') ?? '';
    bookname = sp.getString('sp_bookname') ?? '';
  }

  Future getAllCustomers(String uid) async {
    try {
      Map data = {'uid': uid};
      var res = await http.post(
          Uri.parse(Myurl.fullurl + "All_Customers_Details.php"),
          body: data);
      var jsondata = jsonDecode(res.body);
      if (jsondata['status'] == true) {
        _customersController.items.clear();
        for (var i = 0; i < jsondata['data'].length; i++) {
          AllCustomers allCustomers = AllCustomers(
            cid: jsondata['data'][i]['id'],
            cname: jsondata['data'][i]['name'],
            cphone: jsondata['data'][i]['phone'],
            cimage: jsondata['data'][i]['image'],
            caddress: jsondata['data'][i]['address'],
          );
          _customersController.items.add(allCustomers);
        }
      }
    } catch (e) {
      print('customers dashboard');
      print(e.toString());
    }
    return _customersController.items;
  }

  Future getTransactionCustomers(String u_id) async {
    try {
      Map data = {'uid': u_id};
      var res = await http.post(
          Uri.parse(Myurl.fullurl + "transaction_customers.php"),
          body: data);
      var jsondata = jsonDecode(res.body.toString());
      if (jsondata['status'] == true) {
        transferCustomers.transactionItems.clear();
        for (int i = 0; i < jsondata['data'].length; i++) {
          AllCustomers trasferCustomers = AllCustomers(
            cid: jsondata['data'][i]['id'],
            cname: jsondata['data'][i]['name'],
            cphone: jsondata['data'][i]['phone'],
            cimage: jsondata['data'][i]['image'],
            caddress: jsondata['data'][i]['address'],
          );
          transferCustomers.transactionItems.add(trasferCustomers);
        }
        // Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      print('transactions dashboard');
      print(e.toString());
    }
    return transferCustomers.transactionItems;
  }

  Future deleteCustomer(String uid, cid) async {
    Map data = {'user_id': uid, 'customer_id': cid};
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

  void checkShowCase() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ShowCaseWidget.of(context).startShowCase([add, profile_view, app_theme]);
    });
  }

  Future<void> checkAuth() async {
    bool isAvailable;
    isAvailable = await auth.canCheckBiometrics;

    if (isAvailable) {
      bool result = await auth.authenticate(
          localizedReason: 'Scan Device screen lock to enter app.');
      if (result) {
        var snackBar = SnackBar(
          backgroundColor: colorOfApp,
          content: Text(
            'Yay! Successfully verified.',
            style: TextStyle(color: Colors.lightGreenAccent),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        showDiaLogAlert();
      }
    } else {
      print("This Device does't have any lock.");
    }
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  @override
  void dispose() {
    subscription.cancel();
    tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkAuth();
    getConnectivity();

    getUserInformation().whenComplete(() async {
      setState(() {
        users = UserDetails(
          m_id: id,
          m_name: name,
          m_email: email,
          m_phone: phone,
          m_password: password,
          m_image: image,
          m_gender: gender,
          m_bookname: bookname,
        );
        getTotalBalance(id);
      });
      await getAllCustomers(id);
      await getLastEntriesDate(id);
    });

    tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: themeCon.isDark.value
          ? Color.fromARGB(255, 26, 34, 50)
          : Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Container(
              width: width,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: RichText(
                            // textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Hello, ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeCon.isDark.value
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                TextSpan(
                                  text: users.m_name.toUpperCase(),
                                  style: TextStyle(
                                    // fontFamily: 'KaushanScript',
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                    color: themeCon.isDark.value
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  usersInfo: users,
                                ),
                              ),
                            ).then((value) => setState(() {}));
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                width: 53,
                                height: 53,
                                child: users.m_image == "no_image.png"
                                    ? Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: colorOfApp,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: colorOfApp, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              Myurl.fullurl +
                                                  Myurl.user_imageurl +
                                                  users.m_image,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              AutoSizeText(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.center,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: themeCon.isDark.value
                                          ? Color.fromARGB(176, 190, 189, 199)
                                          : Color.fromARGB(175, 154, 153, 164),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: AutoSizeText(
                                      users.m_bookname,
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            BookNameChnge(users),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.edit_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Obx(
                                () => RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: themeCon.isDark.value
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 13.5,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: 'Last Updated : ',
                                          style: TextStyle(fontSize: 12.5)),
                                      TextSpan(
                                          text: _entriesDate
                                                  .lastDate.value.isNotEmpty
                                              ? '${_entriesDate.lastDate.value}'
                                              : '-',
                                          style: TextStyle(
                                              color:
                                                  colorOfApp.withOpacity(0.7),
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Spacer(),
                          Obx(
                            () => Column(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    themeCon.isDark.value =
                                        !themeCon.isDark.value;
                                    themeCon.changeTheme(themeCon.isDark.value);
                                    sp = await SharedPreferences.getInstance();
                                    sp.setBool('theme', themeCon.isDark.value);
                                  },
                                  icon: Icon(
                                    themeCon.isDark.value
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    size: 26,
                                  ),
                                ),
                                AutoSizeText(
                                  themeCon.isDark.value ? 'Dark' : 'Light',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: themeCon.isDark.value
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Card(
              elevation: 4,
              shadowColor: themeCon.isDark.value ? Colors.white : Colors.black,
              child: Container(
                // height: 70,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.5,
                    color: colorOfApp,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Obx(
                          () => RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                              children: [
                                TextSpan(
                                    text: "You'll receive the total amount "),
                                TextSpan(
                                  text: '₹${balance.totalGetBalance.value}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                      child: VerticalDivider(
                        // width: 6,
                        color: colorOfApp, thickness: 1.5,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Obx(
                          () => RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                              children: [
                                TextSpan(
                                    text: "You'll must pay the total amount "),
                                TextSpan(
                                  text:
                                      '₹${balance.totalGiveBalance.value.abs()}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //list containers..
            TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: colorOfApp,
              unselectedLabelStyle:
                  TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              physics: BouncingScrollPhysics(),
              indicatorWeight: BorderSide.strokeAlignCenter,
              labelStyle: TextStyle(
                decoration: TextDecoration.combine([TextDecoration.none]),
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
              indicator: BoxDecoration(
                color: colorOfApp,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              dragStartBehavior: DragStartBehavior.start,
              // labelPadding: EdgeInsets.all(10),
              padding: EdgeInsets.all(12),
              labelColor: Colors.black,
              controller: tabController,
              indicatorColor: colorOfApp,
              dividerColor: Colors.transparent,
              tabs: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Tab(
                      child: Obx(
                        () => Row(
                          children: [
                            AutoSizeText('Transactions'),
                            AutoSizeText(
                                ' (${transferCustomers.transactionItems.length.toString()})'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.search),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Tab(
                      child: Obx(
                        () => Row(
                          children: [
                            AutoSizeText('Customers'),
                            AutoSizeText(
                                ' (${_customersController.items.length.toString()})'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _customerpage(context),
                  _searchAllCustomers(context),
                  _Allcustomerpage(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDiaLogAlert() async => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: CupertinoAlertDialog(
            title: const Text(
              'myDailyBook is Locked!',
              style: TextStyle(fontSize: 18),
            ),
            content: const Text(
                'Authentication is required to access the myDailyBook app.'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Get.back();
                    checkAuth();
                  },
                  child: Text(
                    'Unlock now',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ),
      );

  void deleteItem(String id) {
    transferCustomers.transactionItems.removeWhere((item) => item.cid == id);
    _customersController.items.removeWhere((item) => item.cid == id);
    transferCustomers.transactionItems.refresh();
    _customersController.items.refresh();
  }

  final TextEditingController _searchController = TextEditingController();
  RxList filteredCustomer = <AllCustomers>[].obs;
  _seacrhCustomer(String val) {
    filteredCustomer.clear();
    val.toLowerCase();
    if (val.isEmpty) {
      return;
    } else {
      setState(() {
        filteredCustomer.addAll(
          _customersController.items.where((searchItem) =>
              searchItem.cname.toLowerCase().contains(val.toLowerCase()) ||
              searchItem.cphone.contains(val)),
        );
      });
    }
  }

  Widget _customerpage(BuildContext dcontext) {
    return Scaffold(
      body: Obx(
        () => Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: themeCon.isDark.value
                ? Color.fromARGB(176, 190, 189, 199)
                : Color.fromARGB(175, 154, 153, 164),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
            ),
          ),
          child: FutureBuilder(
            future: getTransactionCustomers(id),
            builder: (context, data) {
              if (data.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitCircle(
                    color: colorOfApp,
                  ),
                );
              } else if (data.hasError) {
                return Center(
                  child: AutoSizeText(
                    'Error in loading customers, please try again.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              } else if (transferCustomers.transactionItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: Image.asset(
                          "assets/images/customer.png",
                          height: 140,
                          width: 140,
                        ),
                      ),
                      AutoSizeText(
                        'No transaction customers were located.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Obx(
                  () => LiquidPullToRefresh(
                    height: 100,
                    borderWidth: BorderSide.strokeAlignCenter,
                    animSpeedFactor: 2.0,
                    color: colorOfApp.withOpacity(0.5),
                    showChildOpacityTransition: false,
                    backgroundColor: Colors.deepPurple,
                    onRefresh: () async {
                      await getTotalBalance(id);
                      await getTransactionCustomers(id);
                      await getLastEntriesDate(id);
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: transferCustomers.transactionItems.length,
                      itemBuilder: (BuildContext context, index) {
                        String src =
                            transferCustomers.transactionItems[index].cimage;
                        return Slidable(
                          startActionPane: ActionPane(
                            motion: StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  var del_id = transferCustomers
                                      .transactionItems[index].cid;
                                  AwesomeDialog(
                                    context: dcontext,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.topSlide,
                                    titleTextStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    descTextStyle: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    title: 'Delete customer!',
                                    desc:
                                        'Do you really want to delete ${transferCustomers.transactionItems[index].cname}?',
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      deleteCustomer(id, del_id)
                                          .whenComplete(() {
                                        deleteItem(del_id);
                                      });
                                    },
                                  ).show();
                                },
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 12,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 25),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionHistory(
                                      transferCustomers.transactionItems[index],
                                    ),
                                  ),
                                ).then((value) async {
                                  await getTotalBalance(id);
                                  await getLastEntriesDate(id);
                                });
                              },
                              leading: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => customers_image(
                                      transferCustomers.transactionItems[index],
                                    ),
                                  );
                                },
                                child: Container(
                                  child: src.isEmpty
                                      ? CircleAvatar(
                                          radius: 27,
                                          backgroundImage: AssetImage(
                                              'assets/images/my.jpg'),
                                        )
                                      : CachedNetworkImage(
                                          width: 50,
                                          height: 50,
                                          imageUrl: Myurl.fullurl +
                                              Myurl.customers_imageUrl +
                                              src,
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
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                ),
                              ),
                              title: Text(
                                transferCustomers.transactionItems[index].cname,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(transferCustomers
                                  .transactionItems[index].cphone),
                              trailing: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChooseTransition(
                                        transferCustomers
                                            .transactionItems[index],
                                        'home',
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: colorOfApp,
                                  size: 27,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactAccess(),
              ),
            );
          },
          child: Icon(
            Icons.person_add_alt_1,
            color: colorOfApp,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _searchAllCustomers(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: themeCon.isDark.value
            ? Color.fromARGB(176, 190, 189, 199)
            : Color.fromARGB(175, 154, 153, 164),
      ),
      child: Column(
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            // elevation: 5,
            margin: EdgeInsets.only(left: 20, right: 20, top: 15),
            child: TextFormField(
              onChanged: (value) {
                _seacrhCustomer(value.trim());
                print(value.toString());
              },
              controller: _searchController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: themeCon.isDark.value
                          ? Colors.white60
                          : Colors.black54,
                    ),
                  ),
                  hintText: 'Search customers...',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: themeCon.isDark.value
                          ? Colors.white60
                          : Colors.black54,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  suffixIcon: Icon(Icons.search)),
            ),
          ),
          Expanded(
            child: filteredCustomer.isEmpty
                ? _searchController.text.isNotEmpty && filteredCustomer.isEmpty
                    ? Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                                color: themeCon.isDark.value
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.6)),
                            children: [
                              TextSpan(text: 'No contacts found for "'),
                              TextSpan(
                                text: _searchController.text.toString(),
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: '"')
                            ],
                          ),
                        ),
                      )
                    : Opacity(
                        opacity: 0.5,
                        child: Image.asset(
                          "assets/images/search.png",
                          height: 200,
                          width: 200,
                        ),
                      )
                : Obx(
                    () => ListView.builder(
                      itemCount: filteredCustomer.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomer[index];
                        return Card(
                          elevation: 12,
                          margin:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 7),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionHistory(
                                    customer,
                                  ),
                                ),
                              ).then((value) async {
                                await getTotalBalance(id);
                                await getLastEntriesDate(id);
                              });
                            },
                            leading: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => customers_image(
                                    customer,
                                  ),
                                );
                              },
                              child: Container(
                                child: customer.cimage == ""
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
                                            customer.cimage,
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
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                              ),
                            ),
                            title: Text(
                              customer.cname,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(customer.cphone),
                            trailing: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChooseTransition(customer, 'home'),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.add,
                                color: colorOfApp,
                                size: 27,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _Allcustomerpage(BuildContext dcontext) {
    return Scaffold(
      body: Obx(
        () => Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: themeCon.isDark.value
                ? Color.fromARGB(176, 190, 189, 199)
                : Color.fromARGB(175, 154, 153, 164),
            borderRadius: BorderRadius.only(
              // topLeft: Radius.circular(25),
              topRight: Radius.circular(15),
            ),
          ),
          child: FutureBuilder(
              future: getAllCustomers(id),
              builder: (context, data) {
                if (data.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitCircle(
                      color: colorOfApp,
                    ),
                  );
                } else if (_customersController.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            "assets/images/customer.png",
                            height: 140,
                            width: 140,
                          ),
                        ),
                        AutoSizeText(
                          'No customers were located.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (data.hasError) {
                  return const AutoSizeText(
                      'Error in load customer, please try again..');
                } else {
                  return Obx(
                    () => LiquidPullToRefresh(
                      height: 100,
                      borderWidth: BorderSide.strokeAlignCenter,
                      animSpeedFactor: 2.0,
                      color: colorOfApp.withOpacity(0.5),
                      showChildOpacityTransition: false,
                      backgroundColor: Colors.deepPurple,
                      onRefresh: () async {
                        await getTotalBalance(id);
                        await getAllCustomers(id);
                        await getLastEntriesDate(id);
                      },
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _customersController.items.length,
                        itemBuilder: (BuildContext context, index) {
                          String src = _customersController.items[index].cimage;
                          return Slidable(
                            startActionPane: ActionPane(
                              motion: StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    var del_id =
                                        _customersController.items[index].cid;
                                    print(del_id);
                                    AwesomeDialog(
                                      context: dcontext,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.topSlide,
                                      titleTextStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      descTextStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500),
                                      title: 'Delete Customer!',
                                      desc:
                                          'Are you sure you want to delete ${_customersController.items[index].cname}?',
                                      btnCancelOnPress: () {},
                                      btnOkOnPress: () {
                                        deleteCustomer(id, del_id).whenComplete(
                                          () {
                                            deleteItem(del_id);
                                          },
                                        );
                                      },
                                    ).show();
                                  },
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: 12,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 25),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionHistory(
                                        _customersController.items[index],
                                      ),
                                    ),
                                  ).then((value) async {
                                    await getTotalBalance(id);
                                    await getLastEntriesDate(id);
                                  });
                                },
                                leading: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => customers_image(
                                        _customersController.items[index],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    child: src == ""
                                        ? CircleAvatar(
                                            radius: 27,
                                            backgroundImage: AssetImage(
                                                'assets/images/my.jpg'),
                                          )
                                        : CachedNetworkImage(
                                            width: 50,
                                            height: 50,
                                            imageUrl: Myurl.fullurl +
                                                Myurl.customers_imageUrl +
                                                src,
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
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  _customersController.items[index].cname,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                    _customersController.items[index].cphone),
                                trailing: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseTransition(
                                            _customersController.items[index],
                                            'home'),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: colorOfApp,
                                    size: 27,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              }),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactAccess(),
              ),
            );
          },
          child: Icon(
            Icons.person_add_alt_1,
            color: colorOfApp,
            size: 28,
          ),
        ),
      ),
    );
  }
}
