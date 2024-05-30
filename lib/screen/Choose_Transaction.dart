import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:lottie/lottie.dart';
import 'package:mypay/Model_Class/Customers_details.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/Amount_Input.dart';

class ChooseTransition extends StatefulWidget {
  AllCustomers customers;
  String pageValue;
  ChooseTransition(this.customers, this.pageValue);
  @override
  State<ChooseTransition> createState() =>
      _ChooseTransitionState(customers, pageValue);
}

class _ChooseTransitionState extends State<ChooseTransition> {
  AllCustomers customers;
  String pageValue;
  _ChooseTransitionState(this.customers, this.pageValue);
  bool isGive = false;
  bool isGet = false;
  bool isConfirmButton = false;

  @override
  Widget build(BuildContext context) {
    ThemeController themeCon = Get.put(ThemeController());
    return Scaffold(
      backgroundColor:
          themeCon.isDark.value ? Color.fromARGB(255, 7, 16, 34) : Colors.white,
      appBar: AppBar(
        backgroundColor: colorOfApp,
        title: Text(
          'Select "Transactions."',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    "Please select and click on the action you wish to perform.",
                    textAlign: TextAlign.center,
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              child: Lottie.asset(
                'assets/lottie/note_book.json',
                height: 300,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: themeCon.isDark.value ? Colors.white : Colors.black,
                  ),
                  children: [
                    TextSpan(text: 'Sure! '),
                    TextSpan(text: 'If You have received money from '),
                    TextSpan(
                      text: '${customers.cname},',
                      style: TextStyle(
                          fontSize: 17.5,
                          color: colorOfApp,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' then click on '),
                    TextSpan(
                      text: '(YouGot)',
                      style: const TextStyle(color: Colors.green),
                    ),
                    TextSpan(text: '. Otherwise, if '),
                    TextSpan(
                      text: customers.cname,
                      style: TextStyle(
                          fontSize: 17.5,
                          color: colorOfApp,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' has received money from You,'),
                    TextSpan(text: ' click on '),
                    TextSpan(
                      text: '(YouGave)',
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isGet ? Colors.green : Colors.transparent),
                        onPressed: () {
                          setState(() {
                            isConfirmButton = true;
                            isGet = true;
                            isGive = false;
                          });
                        },
                        icon: Icon(Icons.download),
                        label: Text(
                          'YouGot',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      if (isGet)
                        Container(
                          width: 100,
                          height: 3,
                          decoration: BoxDecoration(color: Colors.orangeAccent),
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isGive ? Colors.red : Colors.transparent),
                        onPressed: () {
                          setState(() {
                            isConfirmButton = true;
                            isGive = true;
                            isGet = false;
                          });
                        },
                        icon: Icon(Icons.upload),
                        label: Text(
                          'YouGave',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      if (isGive)
                        Container(
                          width: 110,
                          height: 3,
                          decoration: BoxDecoration(color: Colors.orangeAccent),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 150),
            if (isConfirmButton)
              Container(
                // alignment: Alignment.bottomCenter,
                padding: EdgeInsets.symmetric(horizontal: 25),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    side: BorderSide(color: Color.fromARGB(255, 19, 24, 29)),
                    backgroundColor: colorOfApp,
                  ),
                  onPressed: () {
                    print('Cradit');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AmountInput(
                          customers,
                          isGet ? "You Got" : "You Gave",
                          pageValue == 'transaction'
                              ? 'transactionPage'
                              : 'homePage',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
