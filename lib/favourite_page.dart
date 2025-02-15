import 'package:flutter/material.dart';
import 'package:project/model/product/product.dart'; // Import model Product
// Import ProductManager

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key, required this.FavoriteProducts})
      : super(key: key);
  final List<Product> FavoriteProducts; // Danh sách sản phẩm yêu thích
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  void _removeFromFavourites(String productId) {
    setState(() {
      widget.FavoriteProducts.removeWhere((product) => product.id == productId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product removed from favourites'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: widget.FavoriteProducts.isEmpty
          ? const Center(
              child: Text(
                'No favourite products yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.FavoriteProducts.length,
              itemBuilder: (context, index) {
                final product = widget.FavoriteProducts[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        image: Image.network(
                                "http://10.0.2.2:8090/api/files/products/${widget.FavoriteProducts[index].id}/${widget.FavoriteProducts[index].image}")
                            .image,
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFromFavourites(product.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
