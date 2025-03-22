import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String? selectedSize;
  int quantity = 1;
  bool isLoading = false;

  List<String> getAvailableSizes() {
    if (widget.product.sizes != null &&
        widget.product.sizes!['items'] != null) {
      final items = widget.product.sizes!['items'] as List<dynamic>;
      return items
          .where((item) => (item['quantity'] as int) > 0)
          .map((item) => item['size'] as String)
          .toList();
    }
    return [];
  }

  int getMaxQuantityForSize(String size) {
    if (widget.product.sizes != null &&
        widget.product.sizes!['items'] != null) {
      final items = widget.product.sizes!['items'] as List<dynamic>;
      final selectedItem = items.firstWhere(
        (item) => item['size'] == size,
        orElse: () => {'quantity': 0},
      );
      return selectedItem['quantity'] as int;
    }
    return 0;
  }

  Future<void> addToCart(String idProduct) async {
    setState(() {
      isLoading = true;
    });

    try {
      final AuthService authService =
          Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final DataBase dataBase = DataBase();

      // Kiểm tra số lượng tối đa cho kích thước đã chọn
      final maxQuantity = getMaxQuantityForSize(selectedSize!);
      if (quantity > maxQuantity) {
        throw Exception(
            'Quantity exceeds available stock ($maxQuantity) for size $selectedSize');
      }

      // Lấy giỏ hàng hiện tại của user
      final record = await dataBase.pb.collection("cart").getFullList(
            filter: 'user_id = "${user!.id}"',
          );

      if (record.isEmpty) {
        // Nếu chưa có giỏ hàng, tạo mới
        final newCart = {
          "user_id": user.id,
          "items": [
            {
              "product_id": idProduct,
              "size": selectedSize,
              "quantity": quantity,
            }
          ],
        };
        await dataBase.pb.collection("cart").create(body: newCart);
      } else {
        // Nếu đã có giỏ hàng, cập nhật
        final Cart cart = Cart.fromJson(record.first.toJson());
        // Kiểm tra xem sản phẩm với kích thước này đã tồn tại chưa
        final existingItemIndex = cart.items.indexWhere(
          (item) =>
              item['product_id'] == idProduct && item['size'] == selectedSize,
        );

        if (existingItemIndex != -1) {
          // Nếu đã tồn tại, cộng dồn số lượng
          final currentQuantity =
              cart.items[existingItemIndex]['quantity'] as int;
          if (currentQuantity + quantity > maxQuantity) {
            throw Exception(
                'Total quantity exceeds available stock ($maxQuantity) for size $selectedSize');
          }
          cart.items[existingItemIndex]['quantity'] =
              currentQuantity + quantity;
        } else {
          // Nếu chưa tồn tại, thêm mới
          cart.items.add({
            "product_id": idProduct,
            "size": selectedSize,
            "quantity": quantity,
          });
        }

        await dataBase.pb.collection("cart").update(cart.id, body: {
          "items": cart.items,
        });
      }

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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(key: UniqueKey())),
        (route) => false,
      );
    } catch (e) {
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
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Debug Product: ${widget.product}");
    print("Available sizes: ${getAvailableSizes()}");

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
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(widget.product.price)}',
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
                  DropdownButton<String>(
                    value: selectedSize,
                    hint: const Text('Choose size'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSize = newValue;
                        quantity = 1; // Reset quantity khi chọn size mới
                      });
                    },
                    items: getAvailableSizes()
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
                          final maxQuantity =
                              getMaxQuantityForSize(selectedSize ?? '');
                          if (selectedSize == null || quantity < maxQuantity) {
                            setState(() {
                              quantity++;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Cannot exceed available quantity ($maxQuantity)',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (selectedSize != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Available: ${getMaxQuantityForSize(selectedSize!)}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 20),
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
                  ? null
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
                  ? CircularProgressIndicator(color: Colors.white)
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
