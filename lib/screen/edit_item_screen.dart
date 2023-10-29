import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stock_app/model/Item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:stock_app/screen/home_screen.dart';
import 'package:uuid/uuid.dart';

final _firestore = FirebaseFirestore.instance;
final _storageRef = FirebaseStorage.instance.ref();

class EditItemScreen extends StatefulWidget {
  EditItemScreen({super.key, required this.item});

  late Item item;

  static const String id = "edit_item_screen";

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final nameController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

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

  void saveChanges() async {
    setState(() {
      isLoading = true;
    });

    var url;

    if (image != null) {
      var uuid = Uuid().v1();
      Reference reference = _storageRef.child("image_$uuid.jpg");

      final newMetadata = SettableMetadata(
        contentType: "image/jpeg",
      );

      try {
        await reference.putFile(image!, newMetadata);
        url = await reference.getDownloadURL();

        final oldImageRef =
            FirebaseStorage.instance.refFromURL(widget.item.image);
        await oldImageRef.delete();
      } on FirebaseException catch (e) {
        print(e);
      }
    }

    try {
      await _firestore.collection("items").doc(widget.item.id).update({
        "name": nameController.text,
        "stock": int.parse(stockController.text),
        "description": descriptionController.text,
        "price": priceController.text,
        "image": url != null ? url : widget.item.image
      });
    } on FirebaseException catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });

    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item.name;
    stockController.text = widget.item.stock.toString();
    descriptionController.text = widget.item.description;
    priceController.text = widget.item.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Item ${widget.item.name}"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                image != null
                    ? Image.file(image!)
                    : Image.network(widget.item.image),
                SizedBox(
                  height: 15.0,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("Choose Image"),
                  onPressed: showOptions,
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Name"),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Stock"),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextField(
                  controller: descriptionController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Description"),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Price (IDR)"),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text("Save Changes"),
                        onPressed: saveChanges,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
