class OrderItem {
  late String id;
  late String invoice_number;
  late String item_id;
  late String item_name;
  late String item_image;
  late int quantity;
  late String price_per_unit;
  late DateTime created_at;

  OrderItem(
    this.id,
    this.invoice_number,
    this.item_id,
    this.item_name,
    this.item_image,
    this.quantity,
    this.price_per_unit,
    this.created_at,
  );
}
