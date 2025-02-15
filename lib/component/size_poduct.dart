import 'package:flutter/material.dart';

class SizePoduct extends StatefulWidget {
  const SizePoduct({super.key, required this.size});
  final List<String> size;
  @override
  State<SizePoduct> createState() => _SizePoductState();
}

class _SizePoductState extends State<SizePoduct> {
  late String _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.size.isNotEmpty ? widget.size[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Size: ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 100,
        ),
        Container(
          child: Wrap(
            spacing: 10,
            children: widget.size.map((size) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSize = size;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width * 0.09,
                  height: MediaQuery.of(context).size.height * 0.04,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: (_selectedSize == size)
                        ? Border.all(
                            color: Colors.black,
                            width: 2,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.03),
                  ),
                  child: Center(
                    child: Text(
                      size,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
