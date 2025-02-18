import 'package:flutter/material.dart';
import 'package:project/component/couter.dart';
import 'package:project/model/product/product.dart';

class CartItem extends StatefulWidget {
  CartItem({
    super.key,
    required this.onTotalChanged,
    required this.onListProductChanged,
    required this.product,
  });

  final Function(int) onTotalChanged;
  final Function(Function(List<String>) updateFunction) onListProductChanged;
  final Product product;

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  bool _isChecked = false;
  int number = 1;

  void increaseNumber() {
    setState(() {
      number++;
      if (_isChecked) {
        widget.onTotalChanged(widget.product.price.toInt());
      }
    });
  }

  void decreaseNumber() {
    setState(() {
      if (number > 1) {
        number--;
        if (_isChecked) {
          widget.onTotalChanged(-widget.product.price.toInt());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _isChecked,
            activeColor: Colors.black,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) {
              // setState(() {
              //   _isChecked = value!;
              //   widget.onTotalChanged(_isChecked
              //       ? widget.product.price.toInt() * number
              //       : -widget.product.price.toInt() * number);
              // });
              setState(() {
                _isChecked = value!;

                // Cập nhật tổng tiền
                widget.onTotalChanged(_isChecked
                    ? widget.product.price.toInt() * number
                    : -widget.product.price.toInt() * number);

                widget.onListProductChanged((prevList) {
                  List<String> updatedList = List.from(prevList);
                  if (_isChecked) {
                    if (!updatedList.contains(widget.product.id)) {
                      updatedList.add(widget.product.id);
                    }
                  } else {
                    updatedList.remove(widget.product.id);
                  }
                  return updatedList;
                });
              });
            },
          ),

          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "http://10.0.2.2:8090/api/files/products/${widget.product.id}/${widget.product.image}",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          // Product Information
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Price: ${widget.product.price}đ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Quantity: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      CounterProduct(
                        number: number,
                        increaseNumber: increaseNumber,
                        decreaseNumber: decreaseNumber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delete Button
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                // Handle delete action
              },
            ),
          ),
        ],
      ),
    );
  }
}
