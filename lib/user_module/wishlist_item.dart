import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class WishlistItem {
  @HiveField(0)
  String name;

  @HiveField(1)
  String price;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  String description; // Add this property

  @HiveField(4)
  String sex; // Add this property

  @HiveField(5)
  String color; // Add this property

  @HiveField(6)
  String age; // Add this property

  WishlistItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.sex,
    required this.color,
    required this.age,
  });
}

class WishlistAdapter extends TypeAdapter<WishlistItem> {
  @override
  final typeId = 2;

  @override
  WishlistItem read(BinaryReader reader) {
    return WishlistItem(
      name: reader.readString(),
      price: reader.readString(),
      imageUrl: reader.readString(),
      description: '',
      sex: '',
      color: '',
      age: '',
    );
  }

  @override
  void write(BinaryWriter writer, WishlistItem obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.price);
    writer.writeString(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
