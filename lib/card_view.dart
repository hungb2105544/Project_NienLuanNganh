import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/home_screen.dart';
import 'package:project/model/cart/cart.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/product/product.dart';
import 'package:provider/provider.dart';

class CardView extends StatefulWidget {
  final Product product;

  const CardView({Key? key, required this.product}) : super(key: key);

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  String? selectedSize; // Lưu kích cỡ được chọn
  int quantity = 1; // Lưu số lượng sản phẩm
  bool isLoading = false; // Trạng thái loading khi thêm vào giỏ hàng

  // Danh sách các kích cỡ có sẵn
  final List<String> availableSizes = ['S', 'M', 'L', 'XL'];

  // Hàm thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(String idProduct) async {
    setState(() {
      isLoading = true; // Bắt đầu loading
    });

    try {
      final AuthService authService =
          Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final DataBase dataBase = DataBase();

      // Lấy giỏ hàng hiện tại của người dùng
      final record = await dataBase.pb.collection("cart").getFullList(
            filter: 'user_id = "${user!.id}"',
          );
      final Cart cart = Cart.fromJson(record.first.toJson());

      // Thêm sản phẩm vào giỏ hàng
      cart.productId.add(idProduct);
      await dataBase.pb.collection("cart").update(cart.id, body: {
        "product_id": cart.productId,
      });

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Added to cart successfully',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          duration: Duration(seconds: 2),
        ),
      );

      // Chuyển về màn hình HomeScreen và reload
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(key: UniqueKey())),
        (route) => false,
      );
    } catch (e) {
      // Hiển thị thông báo lỗi nếu có lỗi xảy ra
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Failed to add to cart: ${e.toString()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Kết thúc loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
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
                '${widget.product.price} VND',
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
                    hint: const Text('Choose size'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSize = newValue;
                      });
                    },
                    items: availableSizes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: Alignment.center,
                        value: value,
                        child: Text(value),
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
                              quantity--;
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
                            quantity++;
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
                widget.product.description,
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
              onPressed: isLoading
                  ? null // Vô hiệu hóa nút khi đang loading
                  : () {
                      if (selectedSize == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.white, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'Please select size',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        addToCart(widget.product.id);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white) // Hiển thị loading indicator
                  : Text(
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
