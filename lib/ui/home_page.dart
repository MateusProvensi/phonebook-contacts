import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phonebook_contacts/helpers/contact_helper.dart';
import 'package:phonebook_contacts/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderAZ, orderZA }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de A-Z'),
                value: OrderOptions.orderAZ,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de Z-A'),
                value: OrderOptions.orderZA,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactPage(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      // onTap: () => _showContactPage(contact: contacts[index]),
      onTap: () => _showOptions(context, index),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: contacts[index].image != null
                        ? FileImage(File(contacts[index].image!))
                        : const AssetImage('images/dog.jpg') as ImageProvider,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contacts[index].name ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    contacts[index].email ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    contacts[index].phone ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact,
        ),
      ),
    );

    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
        _getAllContacts();
        return;
      }
      await helper.saveContact(recContact);
      _getAllContacts();
      return;
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then(
      (list) {
        setState(() {
          contacts = list;
        });
      },
    );
  }

  _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse('tel:${contacts[index].phone}'));
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Ligar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      onPressed: () {
                        helper.deleteContact(contacts[index].id!);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                      child: const Text(
                        'Excluir',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderAZ:
        contacts.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
      case OrderOptions.orderZA:
        contacts.sort((a, b) {
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
