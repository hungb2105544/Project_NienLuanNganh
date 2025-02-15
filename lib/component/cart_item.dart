import 'package:flutter/material.dart';
import 'package:project/component/couter.dart';

class Products {
  String name;
  int price;

  Products({required this.name, required this.price});
}

class CartItem extends StatefulWidget {
  CartItem({
    super.key,
    required this.onTotalChanged,
    required this.product,
  });
  final Function(int) onTotalChanged;

  final Products product;

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  bool _isChecked = false;

  int number = 1;

  void increaseNumber() {
    setState(
      () {
        number++;
        if (_isChecked) {
          widget.onTotalChanged(widget.product.price);
        }
      },
    );
  }

  void decreaseNumber() {
    setState(
      () {
        if (number > 1) {
          number--;
          if (_isChecked) {
            widget.onTotalChanged(-widget.product.price);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            width: 1,
          ),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.16,
      padding: EdgeInsets.only(
        top: 10,
      ),
      child: Row(
        children: [
          Checkbox(
            value: _isChecked,
            onChanged: (value) {
              setState(() {
                _isChecked = value!;
                widget.onTotalChanged(_isChecked
                    ? widget.product.price * number
                    : -widget.product.price * number);
              });
            },
          ),

          // Product image
          Container(
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/anh.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Product information
          Container(
            margin: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.product.name}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Price: ${widget.product.price}đ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Text('Quantity: '),
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
          Expanded(
            child: Container(
              width: 20,
              color: const Color.fromARGB(255, 235, 83, 72),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
