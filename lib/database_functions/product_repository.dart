class Product {
  String id;
  String name;
  String price;
  String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      category: map['category'] ?? '',
    );
  }
}
