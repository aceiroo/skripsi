import 'package:flutter/material.dart';
import 'package:stock_app/model/Item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
                  context,
                  widget.item.name,
                  widget.item.id,
                  widget.item.image,
                );
              },
              icon: Icon(Icons.delete),
            ),
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
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text("Purchase Price"),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text("Rp.${widget.item.purchase_price}"),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text("Selling Price"),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text("Rp.${widget.item.selling_price}"),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text("Profit"),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                    "Rp.${int.parse(widget.item.selling_price) - int.parse(widget.item.purchase_price)}"),
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

  Future<void> deleteDialog(BuildContext context, BuildContext detailContext,
      String name, String id, String imgUrl) {
    final _firestore = FirebaseFirestore.instance;
    final _storageRef = FirebaseStorage.instance.refFromURL(imgUrl);

    void deleteDocument() async {
      try {
        await _storageRef.delete();
        await _firestore.collection("items").doc(id).delete();

        Navigator.of(context).pop();
        Navigator.of(detailContext).pop();
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
