import 'package:flutter/material.dart';
import 'package:project/model/product/product.dart';

class CartItem extends StatelessWidget {
  final Product product;
  final String size;
  final int quantity;
  final bool isSelected;
  final Function(bool) onToggleSelection;
  final VoidCallback onDelete;

  const CartItem({
    super.key,
    required this.product,
    required this.size,
    required this.quantity,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => onToggleSelection(value ?? false),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                "http://10.0.2.2:8090/api/files/products/${product.id}/${product.image}",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Size: $size', style: const TextStyle(fontSize: 14)),
                  Text('Quantity: $quantity',
                      style: const TextStyle(fontSize: 14)),
                  Text(
                    'Price: ${(product.price * quantity).toStringAsFixed(2)} VND',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: onDelete,
              ),
            )
          ],
        ),
      ),
    );
  }
}
