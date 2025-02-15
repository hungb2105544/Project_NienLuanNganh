class FavoriteProduct {
  final String id;
  final String id_user;
  final List<String> id_product;

  FavoriteProduct({
    required this.id,
    required this.id_user,
    required this.id_product,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      id: json['_id'],
      id_user: json['id_user'],
      id_product: List<String>.from(json['id_product']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id_user': id_user,
      'id_product': id_product,
    };
  }

  @override
  String toString() {
    return 'FavoriteProduct{id: $id, id_user: $id_user, id_product: $id_product}';
  }
}
