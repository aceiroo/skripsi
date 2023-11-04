import 'package:flutter/material.dart';
import 'package:stock_app/model/OrderItem.dart';

class DetailOrderScreen extends StatefulWidget {
  DetailOrderScreen({super.key, required this.order});

  static const String id = "detail_order_screen";

  late OrderItem order;

  @override
  State<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends State<DetailOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail ${widget.order.invoice_number}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(widget.order.item["image"].toString()),
            SizedBox(
              height: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.order.invoice_number} - ${widget.order.item["name"]}",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  ExpansionTile(
                    maintainState: false,
                    leading: Icon(Icons.info),
                    title: Text(
                      "Detail Order",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text("No. Invoice"),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text(widget.order.invoice_number),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text("Price Per Unit"),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text("Rp.${widget.order.price_per_unit}"),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text("Quantity"),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text(widget.order.quantity.toString()),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text("Total Price"),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text(
                                  "Rp.${int.parse(widget.order.price_per_unit) * widget.order.quantity}"),
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
      ),
    );
  }
}
