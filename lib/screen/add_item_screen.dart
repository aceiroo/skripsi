import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_app/screen/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddItemScreen extends StatefulWidget {
  static const String id = "add_item_screen";

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  late String name;
  late int stock;
  late String description;
  late String purchase_price;
  late String selling_price;
  final _firestore = FirebaseFirestore.instance;
  final _storageRef = FirebaseStorage.instance.ref();

  bool isLoading = false;

  File? image;
  final picker = ImagePicker();

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      }
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      }
    });
  }

  Future showOptions() async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    getImageFromGallery();
                  },
                  child: Text("Photo Gallery"),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    getImageFromCamera();
                  },
                  child: Text("Camera"),
                ),
              ],
            ));
  }

  void addNewItem() async {
    setState(() {
      isLoading = true;
    });

    var uuid = Uuid().v1();
    Reference reference = _storageRef.child("image_$uuid.jpg");

    final newMetadata = SettableMetadata(
      contentType: "image/jpeg",
    );

    try {
      await reference.putFile(image!, newMetadata);
      final url = await reference.getDownloadURL();

      await _firestore.collection("items").add({
        "name": name,
        "stock": stock,
        "description": description,
        "purchase_price": purchase_price,
        "selling_price": selling_price,
        "image": url,
      });
    } on FirebaseException catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });

    Navigator.pushNamed(context, HomeScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Item"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                image != null ? Image.file(image!) : Container(),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.image),
                        onPressed: showOptions,
                        label: Text("Choose Image"),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Name"),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text("Stock"),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    stock = int.parse(value);
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Description"),
                  ),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Purchase Price (Rp)"),
                  ),
                  onChanged: (value) {
                    purchase_price = value;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Selling Price (Rp)"),
                  ),
                  onChanged: (value) {
                    selling_price = value;
                  },
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                        ),
                        icon: Icon(Icons.add),
                        label: Text(
                          "Add Item",
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        onPressed: addNewItem,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
