import 'package:flutter/material.dart';
import 'package:project/model/product/product.dart';

class CardView extends StatefulWidget {
  final Product product;

  const CardView({Key? key, required this.product}) : super(key: key);

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  String? selectedSize; // Lưu kích cỡ được chọn
  int quantity = 1; // Lưu số lượng sản phẩm

  // Danh sách các kích cỡ có sẵn (giả sử sản phẩm có các kích cỡ)
  final List<String> availableSizes = ['S', 'M', 'L', 'XL'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name), // Hiển thị tên sản phẩm trên AppBar
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị hình ảnh sản phẩm
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  width: double.infinity,
                  height: 500,
                  fit: BoxFit.cover,
                  image: Image.network(
                          "http://10.0.2.2:8090/api/files/products/${widget.product.id}/${widget.product.image}")
                      .image,
                ),
              ),
              const SizedBox(height: 20),
              // Hiển thị tên sản phẩm
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Hiển thị giá sản phẩm
              Text(
                '${widget.product.price} VND', // Giả sử Product có thuộc tính price
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Size:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedSize,
                    hint: const Text('Choose size'), // Gợi ý chọn kích cỡ
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSize = newValue; // Cập nhật kích cỡ được chọn
                      });
                    },
                    items: availableSizes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: Alignment.center,
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantity:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--; // Giảm số lượng
                            });
                          }
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++; // Tăng số lượng
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Hiển thị mô tả sản phẩm
              Text(
                widget.product
                    .description, // Giả sử Product có thuộc tính description
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          color: Colors.transparent,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (selectedSize == null) {
                  // Hiển thị thông báo nếu chưa chọn kích cỡ
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a size'),
                    ),
                  );
                } else {
                  // Xử lý thêm sản phẩm vào giỏ hàng
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${widget.product.name} (Size: $selectedSize, Quantity: $quantity) added to cart'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
