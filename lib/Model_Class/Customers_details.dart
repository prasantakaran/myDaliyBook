class AllCustomers {
  String cid = '', cname = '', cphone = '', cimage = '', caddress = '';
  AllCustomers(
      {required this.cid,
      required this.cname,
      required this.cphone,
      required this.cimage,
      required this.caddress});
}

class TransactionCustomers {
  String t_cid = '',
      t_cname = '',
      t_cphone = '',
      t_cimage = '',
      t_caddress = '';
  TransactionCustomers(
      {required this.t_cid,
      required this.t_cname,
      required this.t_cphone,
      required this.t_cimage,
      required this.t_caddress});
}

class DeleteFromWhere {
  static String value = '';
  DeleteFromWhere(val) {
    value = val;
  }
}
