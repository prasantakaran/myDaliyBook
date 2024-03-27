import 'dart:ffi';

import 'package:get/get.dart';
import 'package:mypay/Model_Class/calculator_model.dart';

class CalculatorController extends GetxController {
  var math = CalculatorModel("0", "0").obs;
  AnswerController _answerController = Get.put(AnswerController());

  numberChange(String f, String s) {
    math.value = CalculatorModel(f, s);
    _answerController.calculate(math.value);
  }
}

class AnswerController extends GetxController {
  var result = 0.obs;

  int get finalResult => result.value;
  void calculate(CalculatorModel calobj) {
    result.value = int.parse(calobj.f) + int.parse(calobj.s);
  }
}
