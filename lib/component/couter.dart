import 'package:flutter/material.dart';

class CounterProduct extends StatefulWidget {
  const CounterProduct(
      {super.key,
      required this.number,
      required this.increaseNumber,
      required this.decreaseNumber});
  final int number;
  final void Function() increaseNumber;
  final void Function() decreaseNumber;
  @override
  State<CounterProduct> createState() => _CounterProductState();
}

class _CounterProductState extends State<CounterProduct> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          // color: Colors.grey,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.remove,
                size: 16,
              ),
              onPressed: widget.decreaseNumber,
            ),
          ),
        ),
        Text('${widget.number}'),
        Container(
          height: 40,
          width: 40,
          // color: Colors.grey,
          child: IconButton(
            icon: Icon(
              Icons.add,
              size: 16,
            ),
            onPressed: widget.increaseNumber,
          ),
        ),
      ],
    );
  }
}
