// ignore_for_file: sort_child_properties_last, unused_import, prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:http/http.dart';
import 'package:mypay/Model_Class/contacts_model.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/main.dart';
import 'package:mypay/screen/add_customer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path;

class ContactAccess extends StatefulWidget {
  const ContactAccess({super.key});

  @override
  State<ContactAccess> createState() => _ContactAccessState();
}

class _ContactAccessState extends State<ContactAccess> {
  bool isSearchField = false;
  List<Contact> allContactsDetails = [];
  List<Contacts> contacts = []; //model_of_contacts
  bool isLoading = false;
  List<Contacts> filteredContacts = [];
  ThemeController _themeController = Get.put(ThemeController());
  TextEditingController _searchController = TextEditingController();

  _imageConvert(Uint8List photo) async {
    final tempDir = await getTemporaryDirectory();
    final file = await File(
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png')
        .create();
    await file.writeAsBytes(photo);
    return file;
  }

  void loadContacts() async {
    setState(() {
      isLoading = true;
    });
    allContactsDetails = await FlutterContacts.getContacts(
        withProperties: true, withPhoto: true);
    contacts.clear();
    for (int i = 0; i < allContactsDetails.length; i++) {
      if (allContactsDetails[i].phones!.isEmpty ||
          allContactsDetails[i].phones[0].normalizedNumber.length < 10)
        continue;

      Contacts allcontacts = Contacts(
        allContactsDetails[i].phones[0].normalizedNumber.substring(3),
        allContactsDetails[i].displayName,
        allContactsDetails[i].photoOrThumbnail,
      );
      contacts.add(allcontacts);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getPermission() async {
    if (!mounted) return;
    if (await Permission.contacts.isGranted) {
      // Permission is already granted
      loadContacts();
    } else {
      // Request permission
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        loadContacts();
      } else {
        print('Contact permission denied');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getPermission().whenComplete(() {
      setState(() {});
    });
  }

  void _filterItem(String query) {
    setState(() {
      filteredContacts.clear();
    });
    query.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        contacts;
      });
    } else {
      List<Contacts> filteredList = [];
      filteredList.addAll(
        contacts.where(
          (contact) =>
              contact.name.toLowerCase().contains(query.toLowerCase()) ||
              contact.phone.contains(query),
        ),
      );
      setState(() {
        filteredContacts = filteredList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeController.isDark.value
          ? Color.fromARGB(255, 7, 16, 34)
          : Colors.white,
      appBar: AppBar(
        backgroundColor: colorOfApp,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchField = !isSearchField;
                if (isSearchField == false) {
                  _searchController.clear();
                }
              });
            },
            icon: Icon(isSearchField ? Icons.clear : Icons.search),
          )
        ],
        title: isSearchField
            ? Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _filterItem(value.trim());
                  },
                  style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                  maxLines: 1,
                  autofocus: true,
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search name, phonenumber.',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Text(
                "Contacts (${contacts.length.toString()})",
                style: TextStyle(fontSize: 21),
              ),
      ),
      body: isLoading
          ? Center(
              child: SpinKitCircle(
                color: colorOfApp,
              ),
            )
          : contacts.isEmpty
              ? Center(
                  child: Text(
                    'No contacts found.',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : Card(
                  elevation: 15,
                  child: Scrollbar(
                    trackVisibility: true,
                    child: ListView.builder(
                      itemCount: isSearchField
                          ? filteredContacts.isEmpty &&
                                  _searchController.text.isNotEmpty
                              ? 1
                              : filteredContacts.length
                          : contacts.length,
                      itemBuilder: (context, index) {
                        if (isSearchField &&
                            filteredContacts.isEmpty &&
                            _searchController.text.isNotEmpty) {
                          return Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              'No contacts found for "${_searchController.text.toString()}"',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        final selectContact = isSearchField
                            ? filteredContacts[index]
                            : contacts[index];
                        return Card(
                          elevation: 20,
                          child: ListTile(
                            onTap: () async {
                              File? photoFile;
                              if (selectContact.photo != null) {
                                photoFile =
                                    await _imageConvert(selectContact.photo!);
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddCustomer(selectContact, photoFile),
                                ),
                              );
                            },
                            leading: selectContact.photo != null
                                ? CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        MemoryImage(selectContact.photo!),
                                  )
                                : CircleAvatar(
                                    radius: 25,
                                    child: Text(selectContact.name[0]),
                                  ),
                            title: Text(selectContact.name),
                            subtitle: Text(selectContact.phone),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
