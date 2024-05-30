import 'dart:typed_data';

class Contacts {
  String phone = '', name = '';
  Uint8List? photo;
  Contacts(this.phone, this.name, this.photo);
}
