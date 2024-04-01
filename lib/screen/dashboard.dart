import 'dart:convert';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mypay/GetxController/Customers_controller.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/Model_Class/User_Details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/screen/Choose_Transition.dart';

import 'package:mypay/screen/contact_access.dart';
import 'package:mypay/screen/profile_screen.dart';
import 'package:mypay/screen/splash.dart';
import 'package:mypay/url/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey add = GlobalKey();
  final GlobalKey profile_view = GlobalKey();
  final GlobalKey app_theme = GlobalKey();
  final CustomersController _customersController =
      Get.put(CustomersController());

  bool isActive = true;
  var width, height;
  late SharedPreferences sp;
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
        if (!mounted) return;
        // customers.clear();
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
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future deleteCustomer(String uid, cid) async {
    try {
      Map data = {'user_id': uid, 'customer_id': cid};
      var res = await http
          .post(Uri.parse(Myurl.fullurl + "customer_delete.php"), body: data);
      var jsondata = jsonDecode(res.body);
      if (jsondata['status'] == true) {
        Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void checkShowCase() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ShowCaseWidget.of(context).startShowCase([add, profile_view, app_theme]);
    });
  }

  final LocalAuthentication auth = LocalAuthentication();

  Future<void> checkAuth() async {
    bool isAvailable;
    isAvailable = await auth.canCheckBiometrics;
    print(isAvailable);

    if (isAvailable) {
      bool result = await auth.authenticate(
          localizedReason: 'Scan Device screen lock to enter App.');
      if (result) {
        const snackBar = SnackBar(
          content: Text('Yay! Successfully Verified.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        showDiaLogBox();
      }
    } else {
      print("This Device does't have any lock.");
    }
  }

  @override
  void initState() {
    super.initState();

    // checkAuth();

    getUserInformation().whenComplete(() {
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
      });
      getAllCustomers(id);
    });

    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  late ScrollController _controller;
  bool showButtonText = true;
  void _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent - 50) {
      setState(() {
        showButtonText = false;
      });
    } else {
      setState(() {
        showButtonText = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    ThemeController themeCon = Get.put(ThemeController());
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: themeCon.isDark.value
            ? Color.fromARGB(255, 6, 34, 92)
            : Colors.white,
        child: Column(
          children: [
            Container(
              width: width,
              height: height * 0.30,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hey, ',
                                style: TextStyle(
                                  color: themeCon.isDark.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 22,
                                ),
                              ),
                              TextSpan(
                                text: users.m_name.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'KaushanScript',
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.bold,
                                  color: themeCon.isDark.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 17,
                                ),
                              ),
                            ],
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
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            child: Icon(
                              Icons.person,
                              size: 36,
                            ),
                            decoration: BoxDecoration(
                                // color: Colors.white,
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),

                              alignment: Alignment.center,
                              height: 35,
                              // width: ,
                              decoration: BoxDecoration(
                                  color: themeCon.isDark.value
                                      ? Color.fromARGB(197, 15, 24, 33)
                                      : Color.fromARGB(251, 222, 221, 231),
                                  // color: themeCon.isDark.value
                                  //     ? Colors.blueGrey[500]
                                  //     : Colors.blueGrey[100],
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                users.m_bookname,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.edit_rounded),
                            ),
                            Spacer(),
                            Obx(
                              () => IconButton(
                                onPressed: () async {
                                  setState(() {
                                    themeCon.isDark.value =
                                        !themeCon.isDark.value;
                                  });
                                  themeCon.changeTheme(themeCon.isDark.value);
                                  sp = await SharedPreferences.getInstance();
                                  sp.setBool('theme', themeCon.isDark.value);

                                  print(themeCon.isDark.value);
                                },
                                icon: Icon(
                                  themeCon.isDark.value
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Last Updated : 5 Jun 2024',
                          style: TextStyle(
                              color: themeCon.isDark.value
                                  ? Colors.white54
                                  : Colors.black54,
                              fontSize: 16),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              // color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (value) {
                  // _filterItems(value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25)),
                      borderSide: BorderSide()),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),

            //list containers..
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isActive = true;
                        });
                        print('Customers');
                      },
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                                "Customers ${_customersController.items.length.toString()}"),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: !isActive
                                  ? Colors.transparent
                                  : Colors.lightBlueAccent,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          if (isActive == true)
                            Container(
                              width: 90,
                              height: 2,
                              decoration:
                                  BoxDecoration(color: Colors.orangeAccent),
                            )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isActive = false;
                        });
                        print('all');
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isActive
                                  ? Colors.transparent
                                  : Colors.lightBlueAccent,
                            ),
                            child: Text(
                                "All ${_customersController.items.length.toString()}"),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          if (isActive == false)
                            Container(
                              width: 40,
                              height: 2,
                              decoration:
                                  BoxDecoration(color: Colors.orangeAccent),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: themeCon.isDark.value
                      ? Color.fromARGB(255, 38, 74, 110)
                      : Color.fromARGB(176, 190, 189, 199),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Obx(
                  () => Builder(
                    builder: (contexts) => ListView.builder(
                      controller: _controller,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: isActive
                          ? _customersController.items.length
                          : _customersController.items.length,
                      itemBuilder: (BuildContext context, index) {
                        String src = _customersController.items[index].cimage;
                        return Slidable(
                          startActionPane:
                              ActionPane(motion: StretchMotion(), children: [
                            SlidableAction(
                              // autoClose: true,
                              onPressed: (contexts) {
                                AwesomeDialog(
                                  context: contexts,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.bottomSlide,
                                  title: 'Confirmation',
                                  desc:
                                      'Are you sure you want to delete this customer?',
                                  btnCancelOnPress: () {},
                                  btnCancelText: 'Cancel',
                                  btnOkOnPress: () {
                                    // Perform delete operation
                                    deleteCustomer(
                                            id,
                                            _customersController
                                                .items[index].cid)
                                        .whenComplete(() {
                                      _customersController.items.removeWhere(
                                          (item) =>
                                              item.cid ==
                                              _customersController
                                                  .items[index].cid);
                                      // Refresh UI
                                      _customersController.items.refresh();
                                      // Show success message
                                      Get.snackbar('Success',
                                          'Customer deleted successfully');
                                    }).catchError((error) {
                                      // Show error message if deletion fails
                                      Get.snackbar('Error',
                                          'Failed to delete customer: $error');
                                    });
                                  },
                                  btnOkText: 'Delete',
                                ).show();

                                // var del_id =
                                //     _customersController.items[index].cid;
                                // print(del_id);
                                // _awasomeDailogBox(context);
                                // deleteCustomer(id, del_id).whenComplete(() {
                                //   _customersController.items
                                //       .removeWhere((item) => item.cid == del_id);
                                //   // Refresh UI
                                //   _customersController.items.refresh();
                                // });
                              },
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ]),
                          child: Card(
                            elevation: 12,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 25),
                            child: ListTile(
                              leading: Container(
                                child: src == ""
                                    ? CircleAvatar(
                                        radius: 27,
                                        backgroundImage:
                                            AssetImage('assets/images/my.jpg'),
                                      )
                                    : CachedNetworkImage(
                                        width: 50,
                                        height: 50,
                                        imageUrl: Myurl.fullurl +
                                            Myurl.imageurl +
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
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: Container(
                    // width: 90,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Test 1',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    // width: 90,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'You have to pay',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text('data')
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 85),
        child: showButtonText
            ? FloatingActionButton.extended(
                // backgroundColor: Colors.white12,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactAccess(),
                    ),
                  );
                },
                icon: Center(child: Icon(Icons.add)),
                label: Text(
                  'Add Person',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16,
                    letterSpacing: 0.4,
                  ),
                ),
              )
            : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactAccess(),
                    ),
                  );
                },
                child: Icon(Icons.person_add),
              ),
      ),
    );
  }

  Future<void> showDiaLogBox() async => showCupertinoDialog<String>(
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
}

_awasomeDailogBox(BuildContext del_context) {
  return AwesomeDialog(
    context: del_context,
    dialogType: DialogType.warning,
    animType: AnimType.topSlide,
    // showCloseIcon: false,
    title: 'Delete Customer!',
    // desc: "Yay! ${customerInfo.cname} Added Successfully.",
    titleTextStyle: TextStyle(fontSize: 15),
    // dismissOnTouchOutside: false,
    // dismissOnBackKeyPress: false,
    btnOkOnPress: () {},
    btnCancelOnPress: () {},
  ).show();
}
