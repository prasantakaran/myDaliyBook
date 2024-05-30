// ignore_for_file: unnecessary_import, file_names

import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';

class TotalTransactions extends GetxController {
  RxDouble totalTransactions = 0.0.obs;
}

class UserTransactionBalance extends GetxController {
  RxDouble totalGiveBalance = 0.0.obs;
  RxDouble totalGetBalance = 0.0.obs;
}

class LastEntriesDate extends GetxController {
  RxString lastDate = ''.obs;
}
