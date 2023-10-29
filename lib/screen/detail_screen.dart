import 'package:flutter/material.dart';
import 'package:stock_app/model/Item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stock_app/screen/edit_item_screen.dart';

class DetailScreen extends StatefulWidget {
  DetailScreen({super.key, required this.item});

  late Item item;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.item.name),
          actions: [
            IconButton(
              onPressed: () {
                deleteDialog(
                  context,
                  widget.item.name,
                  widget.item.id,
                  widget.item.image,
                );
              },
              icon: Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditItemScreen(item: widget.item),
                  ),
                );
              },
              icon: Icon(Icons.edit),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                image: NetworkImage(
                  widget.item.image,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontSize: 28.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Rp.${widget.item.price}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      widget.item.description,
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ExpansionTile(
                      title: Text(
                        "Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text("Stock"),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(widget.item.stock.toString()),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Future<void> deleteDialog(
      BuildContext context, String name, String id, String imgUrl) {
    final _firestore = FirebaseFirestore.instance;
    final _storageRef = FirebaseStorage.instance.refFromURL(imgUrl);

    void deleteDocument() async {
      try {
        await _storageRef.delete();
        await _firestore.collection("items").doc(id).delete();

        Navigator.of(context)
          ..pop()
          ..pop();
      } catch (e) {
        print(e);
      }
    }

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete $name"),
            content: Text("Are you sure?"),
            actions: [
              TextButton(
                onPressed: deleteDocument,
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
              ),
            ],
          );
        });
  }
}
