import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mypay/GetxController/Calculator_controller.dart';

class CustomTextField extends StatelessWidget {
  // const CustomTextField({super.key});
  TextEditingController fn = TextEditingController();
  TextEditingController sn = TextEditingController();

  CalculatorController _calculatorController = Get.put(CalculatorController());
  AnswerController _answerController = Get.put(AnswerController());

  @override
  Widget build(BuildContext context) {
    void CalCulate(String f, String s) {
      var val = int.parse(f) + int.parse(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Obx(
                () => Text(
                  _answerController.result.value.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.50,
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    controller: fn,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                        hintText: '0'),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width * 0.50,
                    padding: EdgeInsets.all(8),
                    child: TextFormField(
                      controller: sn,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(),
                          hintText: '0'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    shape: BeveledRectangleBorder(),
                    backgroundColor: Colors.deepPurple),
                onPressed: () {
                  _calculatorController.numberChange(
                      fn.text.trim(), sn.text.trim());
                },
                icon: Icon(Icons.calculate_outlined),
                label: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Caculate',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
