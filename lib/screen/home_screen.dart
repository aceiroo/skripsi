import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_app/model/Item.dart';
import 'package:stock_app/screen/add_item_screen.dart';
import 'package:stock_app/screen/detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_app/screen/login_screen.dart';

final _auth = FirebaseAuth.instance;
var loggedInUser = _auth.currentUser;

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> logout() async {
    await _auth.signOut();

    Navigator.pushNamed(context, LoginScreen.id);
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
        title: Text("List of Items"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddItemScreen.id);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: StreamBuilder<QuerySnapshot>(
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
                item.get("purchase_price"),
                item.get("selling_price"),
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
                // trailing: IconButton(
                //   icon: Icon(Icons.more_vert),
                //   onPressed: () {
                //     print("More Vertical Pressed");
                //   },
                // ),
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
      ),
    );
  }
}
