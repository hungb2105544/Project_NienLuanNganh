import 'package:flutter/material.dart';

class ColourProduct extends StatefulWidget {
  const ColourProduct({super.key, required this.colour});
  final List<Color> colour;

  @override
  State<ColourProduct> createState() => _ColourProductState();
}

class _ColourProductState extends State<ColourProduct> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor =
        widget.colour.isNotEmpty ? widget.colour[0] : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bảng màu: ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 100,
        ),
        Wrap(
          spacing: 10,
          children: widget.colour.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.06,
                height: MediaQuery.of(context).size.height * 0.03,
                decoration: BoxDecoration(
                  color: color,
                  border: _selectedColor == color
                      ? Border.all(
                          color: Colors.black,
                          width: 2,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.03),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
