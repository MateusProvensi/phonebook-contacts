import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phonebook_contacts/helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;
  late Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
      return;
    }

    _editedContact = Contact.fromMap(widget.contact!.toMap());
    _nameController.text = _editedContact.name ?? "";
    _emailController.text = _editedContact.email ?? "";
    _phoneController.text = _editedContact.phone ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null &&
                _editedContact.name!.isNotEmpty) {
              Navigator.pop(context, _editedContact);
              return;
            }
            FocusScope.of(context).requestFocus(_nameFocus);
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          controller: ScrollController(),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  ImagePicker().pickImage(source: ImageSource.camera).then(
                    (file) {
                      if (file != null) {
                        setState(() {
                          _editedContact.image = file.path;
                        });
                      }
                    },
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _editedContact.image != null
                          ? FileImage(File(_editedContact.image!))
                          : const AssetImage('images/dog.jpg') as ImageProvider,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Descartar Alterações'),
            content: const Text('Se sair as alterações serão perdidas'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Sim'),
              ),
            ],
          );
        },
      );
      return Future.value(false);
    }

    return Future.value(true);
  }
}
