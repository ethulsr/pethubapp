// order_item.dart
import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class OrderItem {
  @HiveField(0)
  String productImage;

  @HiveField(1)
  String productName;

  @HiveField(2)
  String status;

  @HiveField(3)
  double totalPrice;

  OrderItem({
    required this.productImage,
    required this.productName,
    required this.status,
    required this.totalPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productImage: map['productImage'] ?? '',
      productName: map['productName'] ?? '',
      status: map['status'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }
}

class OrderAdapter extends TypeAdapter<OrderItem> {
  @override
  final typeId = 3;

  @override
  OrderItem read(BinaryReader reader) {
    return OrderItem(
      productImage: reader.readString(),
      productName: reader.readString(),
      status: reader.readString(),
      totalPrice: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer.writeString(obj.productImage);
    writer.writeString(obj.productName);
    writer.writeString(obj.status);
    writer.writeDouble(obj.totalPrice);
  }
}
