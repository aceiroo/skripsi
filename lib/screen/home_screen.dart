import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_app/model/Item.dart';
import 'package:stock_app/model/OrderItem.dart';
import 'package:stock_app/screen/add_item_screen.dart';
import 'package:stock_app/screen/detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_app/screen/login_screen.dart';

final _auth = FirebaseAuth.instance;
var loggedInUser = _auth.currentUser;
final _firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  List<Widget> widgetOptions = [
    ItemList(),
    OrderList(),
    Text("Dashboard"),
  ];
  List<Text> appBarTitle = [
    Text("List of Items"),
    Text("List of Orders"),
    Text("Dashboard"),
  ];

  Future<void> logout() async {
    await _auth.signOut();

    Navigator.pushNamed(context, LoginScreen.id);
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: appBarTitle.elementAt(selectedIndex),
          actions: [
            IconButton(
              onPressed: logout,
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Order",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dashboard",
            )
          ],
          currentIndex: selectedIndex,
          onTap: onItemTapped,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (selectedIndex == 0) {
              Navigator.pushNamed(context, AddItemScreen.id);
            }
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: widgetOptions.elementAt(selectedIndex));
  }
}

class OrderList extends StatelessWidget {
  const OrderList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("orders").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ),
          );
        }

        final orders = snapshot.data?.docs;
        List<OrderItem> orderList = [];

        for (var order in orders!) {
          orderList.add(
            OrderItem(
              order.id,
              order.get("invoice_number"),
              order.get("item_id"),
              order.get("item_name"),
              order.get("item_image"),
              order.get("quantity"),
              order.get("price_per_unit"),
            ),
          );
        }

        return ListView.builder(
          itemCount: orderList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                  "${orderList[index].invoice_number} | ${orderList[index].item_name} | ${orderList[index].quantity} x  Rp.${orderList[index].price_per_unit}"),
              leading: CircleAvatar(
                child: Image.network(orderList[index].item_image),
              ),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => DetailScreen(item: itemList[index]),
                //   ),
                // );
              },
            );
          },
        );
      },
    );
  }
}

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("items").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
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

        return ListView.builder(
          itemCount: itemList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(itemList[index].name),
              leading: CircleAvatar(
                child: Image.network(itemList[index].image),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(item: itemList[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
