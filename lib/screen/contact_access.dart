import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mypay/Model_Class/contacts_model.dart';
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

  void loadContacts() async {
    setState(() {
      isLoading = true;
    });
    allContactsDetails = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );
    contacts.clear();
    for (int i = 0; i < allContactsDetails.length; i++) {
      if (allContactsDetails[i].phones!.isEmpty ||
          allContactsDetails[i].phones[0].normalizedNumber.length < 10)
        continue;
      Contacts allcontacts = Contacts(
        allContactsDetails[i].phones[0].normalizedNumber.substring(3),
        allContactsDetails[i].displayName,
      );
      contacts.add(allcontacts);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getPermission() async {
    if (await Permission.contacts.isGranted) {
      // Permission is already granted
      loadContacts();
    } else {
      // Request permission
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        loadContacts();
      } else {
        // Handle denied permission
        // You can show a dialog or message to inform the user
        print('Contact permission denied');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
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
        // filteredContacts = contacts;
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
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 175, 135, 215),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchField = !isSearchField;
              });
            },
            icon: Icon(isSearchField ? Icons.clear : Icons.search),
          )
        ],
        title: isSearchField
            ? Container(
                child: TextField(
                  onChanged: (value) {
                    _filterItem(value.trim());
                  },
                  style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                  maxLines: 1,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search name, phonenumber.',
                    hintStyle: TextStyle(fontSize: 18),
                  ),
                ),
              )
            : const Text(
                'Contacts',
                style: TextStyle(fontSize: 21),
              ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : contacts.isEmpty
              ? const Center(
                  child: Text(
                    'No contacts found.',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : Container(
                  child: ListView.builder(
                    itemCount: isSearchField
                        ? filteredContacts.length
                        : contacts.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCustomer(
                                  isSearchField
                                      ? filteredContacts[index]
                                      : contacts[index],
                                ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            child: Text(isSearchField
                                ? filteredContacts[index].name[0]
                                : contacts[index].name[0]),
                            radius: 25,
                            // backgroundColor: Colors.black,
                          ),
                          title: Text(isSearchField
                              ? filteredContacts[index].name
                              : contacts[index].name),
                          subtitle: Text(isSearchField
                              ? filteredContacts[index].phone
                              : contacts[index].phone),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
