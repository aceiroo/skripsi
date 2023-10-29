import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_app/model/Item.dart';
import 'package:stock_app/model/OrderItem.dart';
import 'package:stock_app/screen/add_item_screen.dart';
import 'package:stock_app/screen/detail_order_screen.dart';
import 'package:stock_app/screen/detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_app/screen/login_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:stock_app/model/ChartData.dart';

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
  String? totalRevenue;
  int? totalOrder;
  int? totalItem;

  List<ChartData> salesData = [];

  Future<void> logout() async {
    await _auth.signOut();

    Navigator.pushNamed(context, LoginScreen.id);
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void getData() async {
    final order =
        await _firestore.collection("orders").orderBy("created_at").get();
    final items = await _firestore.collection("items").get();
    num sum = 0;

    List<int> monthSales = [];
    Map<int, int> countData = {};

    for (var doc in order.docs) {
      final price =
          doc.data()["quantity"] * int.parse(doc.data()["price_per_unit"]);

      sum = sum + price;

      monthSales.add(doc.data()['created_at'].toDate().month);
    }

    monthSales.forEach((i) => countData[i] = (countData[i] ?? 0) + 1);

    print(countData.toString());

    setState(() {
      totalItem = items.docs.length;
      totalOrder = order.docs.length;
      totalRevenue = sum.toString();

      countData.forEach((key, value) {
        if (key == DateTime.january) {
          salesData.add(ChartData("Jan", value));
        } else if (key == DateTime.february) {
          salesData.add(ChartData("Feb", value));
        } else if (key == DateTime.march) {
          salesData.add(ChartData("Mar", value));
        } else if (key == DateTime.april) {
          salesData.add(ChartData("Apr", value));
        } else if (key == DateTime.may) {
          salesData.add(ChartData("May", value));
        } else if (key == DateTime.june) {
          salesData.add(ChartData("Jun", value));
        } else if (key == DateTime.july) {
          salesData.add(ChartData("Jul", value));
        } else if (key == DateTime.august) {
          salesData.add(ChartData("Aug", value));
        } else if (key == DateTime.september) {
          salesData.add(ChartData("Sep", value));
        } else if (key == DateTime.october) {
          salesData.add(ChartData("Oct", value));
        } else if (key == DateTime.november) {
          salesData.add(ChartData("Nov", value));
        } else if (key == DateTime.december) {
          salesData.add(ChartData("Dec", value));
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = [
      ItemList(),
      OrderList(),
      Dashboard(
        totalRevenue: totalRevenue.toString(),
        totalOrder: totalOrder ?? 0,
        totalItem: totalItem ?? 0,
        salesData: salesData,
      ),
    ];
    List<Text> appBarTitle = [
      Text("List of Items"),
      Text("List of Orders"),
      Text("Dashboard"),
    ];

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailOrderScreen(order: orderList[index]),
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

class Dashboard extends StatelessWidget {
  Dashboard({
    required this.totalRevenue,
    required this.totalOrder,
    required this.totalItem,
    required this.salesData,
  });

  late String totalRevenue;
  late int totalOrder;
  late int totalItem;
  List<ChartData> salesData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text("Total Revenue"),
                    leading: Icon(Icons.monetization_on),
                    subtitle: Text("Rp.${totalRevenue}"),
                    subtitleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("Total Order"),
                          leading: Icon(Icons.shopping_cart),
                          subtitle: Text(totalOrder.toString()),
                          subtitleTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("Total Item"),
                          leading: Icon(Icons.info),
                          subtitle: Text(totalItem.toString()),
                          subtitleTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            SfCartesianChart(
              isTransposed: true,
              title: ChartTitle(text: "Yearly Sales Analysis"),
              primaryXAxis: CategoryAxis(),
              series: [
                BarSeries(
                  dataSource: salesData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  borderRadius: BorderRadius.circular(15.0),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                  ),
                )
              ],
            )
          ],
        ),
      ),
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
