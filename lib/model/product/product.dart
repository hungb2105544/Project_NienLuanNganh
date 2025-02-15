class Product {
  final String collectionId;
  final String collectionName;
  final String id;
  String name;
  String description;
  double price;
  String? categoryId; // Có thể nullable nếu không bắt buộc
  String image;
  Map<String, dynamic>? sizes; // JSON linh hoạt, có thể null
  DateTime created;
  DateTime updated;

  Product({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryId,
    required this.image,
    this.sizes,
    required this.created,
    required this.updated,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String) ?? DateTime.now()
          : DateTime.now(),
      updated: json['updated'] != null
          ? DateTime.tryParse(json['updated'] as String) ?? DateTime.now()
          : DateTime.now(),
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      categoryId: json['category_id']?.toString(),
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      sizes: (json['sizes'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(json['sizes'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collectionId': collectionId,
      'collectionName': collectionName,
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'image': image,
      'sizes': sizes,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Product(id: $id \n, name: $name \n, price: $price \n, categoryId: $categoryId\n , sizes: $sizes\n, created: $created \n, updated: $updated,\m image: $image )\n\n';
  }
}
