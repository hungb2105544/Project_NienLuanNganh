import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/model/address/address.dart';
import 'package:project/model/address/address_manager.dart';
import 'package:project/model/cart/cart.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/order/order.dart';
import 'package:project/model/product/product.dart';
import 'package:project/model/product/product_manager.dart';
import 'package:project/model/user/user.dart';
import 'package:project/order_information_page.dart';
import 'package:project/success_screen_order.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

class OrderTemp extends StatefulWidget {
  const OrderTemp({super.key, required this.cartItems});
  final List<Map<String, dynamic>> cartItems; // Danh sách items từ giỏ hàng

  @override
  State<OrderTemp> createState() => _OrderTempState();
}

class _OrderTempState extends State<OrderTemp> {
  List<Product> listProduct = [];
  List<Address> addresses = [];
  String? paymentMethod;
  Address? selectedAddress;
  double totalPrice = 0.0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await Future.wait([fetchProduct(), fetchAddress()]);
    } catch (e) {
      setState(() {
        errorMessage = "Error loading data: $e";
        isLoading = false;
      });
    }
  }

  Future<void> fetchProduct() async {
    List<Product> list = await getProductsOfOrder(
        widget.cartItems.map((item) => item['product_id'] as String).toList());
    if (mounted) {
      setState(() {
        listProduct = list;
        totalPrice = _calculateTotalPrice(list);
        isLoading = false;
      });
    }
  }

  double _calculateTotalPrice(List<Product> products) {
    double total = 0.0;
    for (var item in widget.cartItems) {
      final product = products.firstWhere((p) => p.id == item['product_id'],
          orElse: () => Product(
              id: '',
              name: '',
              price: 0.0,
              image: '',
              description: '',
              created: DateTime.now(),
              updated: DateTime.now()));
      final quantity = (item['quantity'] as int? ?? 1);
      total += product.price * quantity;
    }
    return total;
  }

  Future<void> fetchAddress() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      setState(() {
        errorMessage = "User not logged in.";
        isLoading = false;
      });
      return;
    }

    try {
      List<Address> list = await AddressManager().getAddressesByUserId(user.id);
      if (mounted) {
        setState(() {
          addresses = list;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching addresses: $e";
        isLoading = false;
      });
    }
  }

  Future<List<Product>> getProductsOfOrder(List<String> idProducts) async {
    ProductManager productManager = ProductManager();
    List<Product> products = [];

    for (var id in idProducts) {
      final product = await productManager.getProductById(id);
      products.add(product);
    }
    return products;
  }

  Future<void> makeOrder() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final DataBase dataBase = DataBase();

    if (user == null || paymentMethod == null || selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all order details.")),
      );
      return;
    }

    final body = <String, dynamic>{
      "userid": user.id,
      "order_code": "OCD${randomNumeric(5)}",
      "order_date": DateTime.now().toString(),
      "total_number": widget.cartItems.length, // Số lượng sản phẩm
      "status": "pending",
      "payment_method": paymentMethod,
      "address_id": selectedAddress!.id,
      "total_price": totalPrice, // Tổng giá tiền
    };

    try {
      // Tạo đơn hàng
      await dataBase.pb.collection('orders').create(body: body);

      // Lấy đơn hàng vừa tạo
      final order = await dataBase.pb.collection('orders').getList(
            filter: 'userid="${user.id}"',
            sort: '-created',
          );
      final Order newOrder = Order.fromJson(order.items[0].toJson());

      // Tạo từng order_item cho mỗi sản phẩm
      for (var item in widget.cartItems) {
        final bodyOrderItem = <String, dynamic>{
          "order_id": newOrder.id,
          "product_id": item['product_id'],
          "quantity": item['quantity'] ?? 1,
        };
        await dataBase.pb.collection('order_item').create(body: bodyOrderItem);
      }

      // Cập nhật giỏ hàng
      final recordCart = await dataBase.pb
          .collection('cart')
          .getFullList(filter: 'user_id = "${user.id}"');
      final Cart cart = Cart.fromJson(recordCart.first.toJson());
      List<Map<String, dynamic>> listOldItems = cart.items;
      List<Map<String, dynamic>> listNewItems = listOldItems
          .where((oldItem) => !widget.cartItems.any((newItem) =>
              newItem['product_id'] == oldItem['product_id'] &&
              newItem['size'] == oldItem['size']))
          .toList();

      final bodyCart = <String, dynamic>{
        "user_id": user.id,
        "items": listNewItems,
        "updated": DateTime.now().toIso8601String(),
      };
      await dataBase.pb.collection('cart').update(cart.id, body: bodyCart);

      // Chuyển đến màn hình thành công
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order Information')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User information', style: _titleStyle),
              SizedBox(height: 8),
              _buildUserInfo(user),
              SizedBox(height: 8),
              Text('List Products', style: _titleStyle),
              listProduct.isEmpty
                  ? Center(child: Text("No products available"))
                  : Column(
                      children: widget.cartItems.map((item) {
                        final product = listProduct.firstWhere(
                            (p) => p.id == item['product_id'],
                            orElse: () => Product(
                                id: '',
                                name: '',
                                price: 0.0,
                                image: '',
                                description: '',
                                created: DateTime.now(),
                                updated: DateTime.now()));
                        return ProductItemInOrder(
                          product: product,
                          quantity: item['quantity'] ?? 1,
                          onRemove: () {},
                        );
                      }).toList(),
                    ),
              SizedBox(height: 8),
              Text('Address', style: _titleStyle),
              addresses.isEmpty
                  ? Center(child: Text("No addresses available"))
                  : AddressSelection(
                      addresses: addresses,
                      onAddressSelected: (selected) {
                        setState(() {
                          selectedAddress = selected;
                        });
                      },
                    ),
              SizedBox(height: 8),
              Text('Payment Method', style: _titleStyle),
              PaymentDropdown(
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildUserInfo(User? user) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, size: 30, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullname ?? 'Unknown', style: _boldTextStyle),
                SizedBox(height: 4),
                Text(user?.phone ?? 'Unknown', style: _normalTextStyle),
                SizedBox(height: 4),
                Text('Order Status: Pending', style: _normalTextStyle),
              ],
            ),
          ),
          Icon(Icons.access_time, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text('Total: ${totalPrice.toStringAsFixed(2)} VND',
              style: TextStyle(fontSize: 18, color: Colors.black)),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 5,
            ),
            onPressed: makeOrder,
            child: Text('Place Order',
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black, width: 2),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))
      ],
    );
  }
}

const _titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const _boldTextStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);
const _normalTextStyle = TextStyle(fontSize: 16, color: Colors.black);

class AddressSelection extends StatefulWidget {
  final List<Address> addresses;
  final Function(Address) onAddressSelected;

  const AddressSelection({
    super.key,
    required this.addresses,
    required this.onAddressSelected,
  });

  @override
  State<AddressSelection> createState() => _AddressSelectionState();
}

class _AddressSelectionState extends State<AddressSelection> {
  Address? selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 255, 255, 255),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.addresses.length,
            itemBuilder: (context, index) {
              Address address = widget.addresses[index];
              bool isSelected = selectedAddress == address;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAddress = address;
                  });
                  widget.onAddressSelected(address);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : const Color.fromARGB(255, 0, 0, 0),
                      width: isSelected ? 3 : 1.5,
                    ),
                    color: isSelected ? Colors.black : Colors.white,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.white : Colors.black,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.type,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${address.street}, ${address.city}, ${address.state}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PaymentDropdown extends StatefulWidget {
  final Function(String?) onChanged;

  const PaymentDropdown({super.key, required this.onChanged});

  @override
  _PaymentDropdownState createState() => _PaymentDropdownState();
}

class _PaymentDropdownState extends State<PaymentDropdown> {
  String? selectedMethod;
  final List<String> paymentMethods = [
    "COD",
    "Credit Card",
    "Zalopay",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        value: selectedMethod,
        hint: Text("Select Payment Method", style: TextStyle(fontSize: 16)),
        isExpanded: true,
        style: TextStyle(fontSize: 16, color: Colors.black87),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        items: paymentMethods.map((method) {
          return DropdownMenuItem(
            value: method,
            child: Text(method, style: TextStyle(fontWeight: FontWeight.w500)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedMethod = value;
          });
          widget.onChanged(value);
        },
      ),
    );
  }
}

class ProductItemInOrder extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onRemove;

  const ProductItemInOrder({
    super.key,
    required this.product,
    required this.quantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name ?? 'Unknown Product'),
      subtitle: Text('Price: ${product.price} VND x $quantity'),
      trailing: IconButton(
        icon: Icon(Icons.remove_circle),
        onPressed: onRemove,
      ),
    );
  }
}
