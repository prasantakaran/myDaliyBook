import 'package:get/get.dart';
import 'package:mypay/Model_Class/Customers_details.dart';

class CustomersController extends GetxController {
  RxList items = <AllCustomers>[].obs;
}

class TransferCustomers extends GetxController {
  RxList transactionItems = <AllCustomers>[].obs;
}
