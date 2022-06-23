import 'package:flutter/material.dart';
import 'package:phonebook_contacts/ui/contact_page.dart';
import 'package:phonebook_contacts/ui/home_page.dart';

class PhonebookContact extends StatelessWidget {
  const PhonebookContact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: HomePage(),
    );
  }
}
