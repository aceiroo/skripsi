import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:stock_app/model/Item.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

final _firestore = FirebaseFirestore.instance;

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  static const String id = "add_order_screen";

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  int selectedValue = 0;

  String? price_per_unit;
  String? item_id;
  String? item_name;
  String? item_image;
  int stock = 0;
  int quantity = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void addOrder() async {
    setState(() {
      isLoading = true;
    });

    final itemRef =
    await _firestore.collection("items").doc(item_id.toString()).get();


    Map<String, dynamic> orderData = {
      "created_at": DateTime.now(),
      "invoice_number": "INV${Random().nextInt(99999999)}",
      "item": itemRef.data(),
      "price_per_unit": price_per_unit.toString(),
      "quantity": quantity,
    };

    await _firestore.collection("orders").add(orderData);

    await _firestore
        .collection("items")
        .doc(item_id)
        .update({"stock": stock - quantity});

    setState(() {
      isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Order"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection("items").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        );
                      }

                      final items = snapshot.data?.docs;
                      List<Item> itemList = [];

                      for (var item in items!) {
                        itemList.add(
                          Item(
                            item.id,
                            item.get("name"),
                            item.get("stock"),
                            item.get("description"),
                            item.get("image"),
                            item.get("price"),
                          ),
                        );
                      }

                      price_per_unit = itemList[selectedValue].price;
                      item_id = itemList[selectedValue].id;
                      stock = itemList[selectedValue].stock;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButton(
                              value: selectedValue,
                              items: itemList.map((item) {
                                return DropdownMenuItem(
                                  child: Text(item.name),
                                  value: itemList.indexOf(item),
                                );
                              }).toList(),
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  selectedValue = value!;
                                  price_per_unit = itemList[value].price;
                                  item_id = itemList[value].id;
                                  stock = itemList[value].stock;
                                });
                              }),
                          ExpansionTile(
                            title: Text("Detail Item"),
                            children: [
                              Image.network(itemList[selectedValue].image),
                              SizedBox(
                                height: 15.0,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text("Price"),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                          "Rp.${itemList[selectedValue]
                                              .price}"),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text("Stock"),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        itemList[selectedValue]
                                            .stock
                                            .toString(),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      );
                    }),
                SizedBox(
                  height: 15.0,
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    label: Text("Quantity"),
                  ),
                  onChanged: (value) {
                    setState(() {
                      quantity = int.parse(value);
                    });
                  },
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                        (quantity > stock || quantity == 0 || stock == 0)
                            ? null
                            : addOrder,
                        icon: Icon(Icons.add),
                        label: Text("Add Order"),
                      ),
                    )
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
