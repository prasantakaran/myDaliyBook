class AllTransaction {
  String transfer_id = '',
      customer_id = '',
      give = '',
      get = '',
      time = '',
      date = '',
      description = '',
      attach = '';
  double availableBalance = 0.0;
  AllTransaction({
    required this.transfer_id,
    required this.customer_id,
    required this.give,
    required this.get,
    required this.time,
    required this.date,
    required this.description,
    required this.attach,
    required this.availableBalance,
  });

  void removeWhere(bool Function(dynamic item) param0) {}
}
