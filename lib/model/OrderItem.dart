class OrderItem {
  late String id;
  late String invoice_number;
  late Map<String, dynamic> item;
  late int quantity;
  late String price_per_unit;
  late DateTime created_at;

  OrderItem(
    this.id,
    this.invoice_number,
    this.item,
    this.quantity,
    this.price_per_unit,
    this.created_at,
  );
}
