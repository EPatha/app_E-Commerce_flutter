class Product {
  final String id;
  final String name;
  final String image;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
  });

  // Convert Product to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id.isEmpty ? null : int.parse(id),
      'name': name,
      'image': image,
      'description': description,
      'price': price,
    };
  }

  // Create Product from Map (SQLite)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'] as String,
      image: map['image'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }

  // Copy method for updating product
  Product copy({
    String? id,
    String? name,
    String? image,
    String? description,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      price: price ?? this.price,
    );
  }
}
