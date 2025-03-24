import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/auth_service.dart';
import 'package:project/model/address/address.dart';
import 'package:project/model/address/address_manager.dart';
import 'package:project/model/cart/cart.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/order/order.dart';
import 'package:project/model/product/product.dart';
import 'package:project/model/product/product_manager.dart';
import 'package:project/model/promotion/promotion.dart';
import 'package:project/model/promotion_user/promotion_user.dart';
import 'package:project/model/promotion_user/promotion_user_manager.dart';
import 'package:project/model/user/user.dart';
import 'package:project/success_screen_order.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

class OrderTemp extends StatefulWidget {
  const OrderTemp({super.key, required this.cartItems});
  final List<Map<String, dynamic>> cartItems;

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
  List<Promotion> promotionsUserHaved = [];
  String? selectedPromotionId;

  @override
  void initState() {
    super.initState();
    fetchData();
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      getPromotion(authService.currentUser!.id, context);
    }
  }

  Future<void> getPromotion(String userId, BuildContext context) async {
    final promotionUserManager =
        Provider.of<PromotionUserManager>(context, listen: false);
    try {
      await promotionUserManager.getPromotionByUserId(userId);
      final now = DateTime.now();
      setState(() {
        promotionsUserHaved = promotionUserManager.promotions
            .where((promo) =>
                promo.active &&
                promo.startDate.isBefore(now) &&
                promo.endDate.isAfter(now) &&
                promo.minOrderValue <= totalPrice &&
                promo.usedCount < promo.maxUsage)
            .toList();
      });
    } catch (e) {
      print('Error getting promotion: $e');
      setState(() {
        promotionsUserHaved = [];
      });
    }
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

    if (selectedPromotionId != null) {
      final selectedPromotion = promotionsUserHaved
          .firstWhere((promo) => promo.id == selectedPromotionId);
      if (selectedPromotion.discountType == 'percentage') {
        total = total * (1 - selectedPromotion.discountValue / 100);
      } else if (selectedPromotion.discountType == 'fixed') {
        total = total - selectedPromotion.discountValue;
        if (total < 0) total = 0;
      }
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

    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cart is empty. Cannot create order.")),
      );
      return;
    }

    final body = <String, dynamic>{
      "userid": user.id,
      "order_code": "OCD${randomNumeric(5)}",
      "order_date": DateTime.now().toIso8601String(),
      "total_number": totalPrice,
      "status": "pending",
      "payment_method": paymentMethod,
      "address_id": selectedAddress!.id,
      "promotion_id": selectedPromotionId,
    };

    try {
      // Create the order
      await dataBase.pb.collection('orders').create(body: body);
      final order = await dataBase.pb.collection('orders').getList(
            filter: 'userid="${user.id}"',
            sort: '-created',
          );
      final Order newOrder = Order.fromJson(order.items[0].toJson());

      // Create order items
      for (var item in widget.cartItems) {
        final bodyOrderItem = <String, dynamic>{
          "order_id": newOrder.id,
          "items": {
            "product_id": item['product_id'],
            "quantity": item['quantity'] ?? 1,
          },
        };
        await dataBase.pb.collection('order_item').create(body: bodyOrderItem);
      }

      // Update product quantities
      for (var item in widget.cartItems) {
        final productId = item['product_id'];
        final orderedQuantity = item['quantity'] ?? 1;
        final selectedSize = item['size']?.toString();

        if (selectedSize == null) {
          throw Exception("Size not specified for product $productId");
        }

        final productResponse =
            await dataBase.pb.collection('products').getOne(productId);
        final product = Product.fromJson(productResponse.toJson());

        if (product.sizes != null && product.sizes!.isNotEmpty) {
          final sizesList = product.sizes!['items'] as List<dynamic>? ?? [];
          bool sizeFound = false;
          for (var sizeEntry in sizesList) {
            if (sizeEntry['size'] == selectedSize) {
              final currentQuantity = (sizeEntry['quantity'] as num).toInt();
              final newQuantity = currentQuantity - orderedQuantity;

              if (newQuantity < 0) {
                throw Exception(
                    "Insufficient stock for product $productId, size $selectedSize");
              }

              sizeEntry['quantity'] = newQuantity;
              sizeFound = true;
              break;
            }
          }

          if (!sizeFound) {
            throw Exception(
                "Size $selectedSize not found for product $productId");
          }

          final updatedSizesString = jsonEncode(sizesList);
          final updateBody = <String, dynamic>{
            "sizes": updatedSizesString,
            "updated": DateTime.now().toIso8601String(),
          };
          await dataBase.pb
              .collection('products')
              .update(productId, body: updateBody);
        }
      }

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
        "order_id": newOrder.id,
        "items": listNewItems,
        "updated": DateTime.now().toIso8601String(),
      };
      await dataBase.pb.collection('cart').update(cart.id, body: bodyCart);

      if (selectedPromotionId != null) {
        final promoUserRecords = await dataBase.pb
            .collection('user_promotions')
            .getFullList(
                filter:
                    "user_id = '${user.id}' && promotion_id = '$selectedPromotionId'");
        if (promoUserRecords.isNotEmpty) {
          final promoUser =
              PromotionUser.fromJson(promoUserRecords.first.toJson());
          await Provider.of<PromotionUserManager>(context, listen: false)
              .usePromotion(promoUser);

          final promoResponse = await dataBase.pb
              .collection('promotions')
              .getOne(selectedPromotionId!);
          final promotion = Promotion.fromJson(promoResponse.toJson());
          final newUsedCount = promotion.usedCount + 1;

          await dataBase.pb
              .collection('promotions')
              .update(selectedPromotionId!, body: {
            'used_count': newUsedCount,
            'updated': DateTime.now().toIso8601String(),
          });
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
    } catch (e) {
      print("Error creating order: $e");
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
      appBar: AppBar(
        title: const Text('Order Information'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildUserInfo(user),
              const SizedBox(height: 16),
              const Text(
                'List Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              listProduct.isEmpty
                  ? const Center(child: Text("No products available"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        final product = listProduct.firstWhere(
                            (p) => p.id == item['product_id'],
                            orElse: () => Product(
                                id: '',
                                name: 'Unknown',
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
                      },
                    ),
              const SizedBox(height: 16),
              const Text(
                'Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              addresses.isEmpty
                  ? const Center(child: Text("No addresses available"))
                  : AddressSelection(
                      addresses: addresses,
                      onAddressSelected: (selected) {
                        setState(() {
                          selectedAddress = selected;
                        });
                      },
                    ),
              const SizedBox(height: 16),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              PaymentDropdown(
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Promotion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              PromotionDropdown(
                promotions: promotionsUserHaved,
                totalPrice: totalPrice,
                onChanged: (value) {
                  setState(() {
                    selectedPromotionId = value;
                    totalPrice = _calculateTotalPrice(listProduct);
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildTotalAndButtons(totalPrice),
    );
  }

  Widget _buildUserInfo(User? user) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullname ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.phone ?? 'Unknown',
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 4),
                const Text('Order Status: Pending',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAndButtons(double total) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              "Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format(total)}",
              key: ValueKey(total),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: makeOrder,
            icon: const Icon(Icons.check_circle, size: 22, color: Colors.white),
            label: const Text('Place Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(14),
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
                              offset: const Offset(0, 4),
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
                      const SizedBox(width: 10),
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
                            const SizedBox(height: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        value: selectedMethod,
        hint:
            const Text("Select Payment Method", style: TextStyle(fontSize: 16)),
        isExpanded: true,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        items: paymentMethods.map((method) {
          return DropdownMenuItem(
            value: method,
            child: Text(method,
                style: const TextStyle(fontWeight: FontWeight.w500)),
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

class PromotionDropdown extends StatefulWidget {
  final List<Promotion> promotions;
  final double totalPrice;
  final Function(String?) onChanged;

  const PromotionDropdown({
    super.key,
    required this.promotions,
    required this.totalPrice,
    required this.onChanged,
  });

  @override
  _PromotionDropdownState createState() => _PromotionDropdownState();
}

class _PromotionDropdownState extends State<PromotionDropdown> {
  String? selectedPromotionId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        value: selectedPromotionId,
        hint: const Text("Select Promotion", style: TextStyle(fontSize: 16)),
        isExpanded: true,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        items: widget.promotions.map((promotion) {
          final discountText = promotion.discountType == 'percentage'
              ? '${promotion.discountValue}% off'
              : '${NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format(promotion.discountValue)} off';
          return DropdownMenuItem(
            value: promotion.id,
            child: Text(
              '${promotion.code} ($discountText)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedPromotionId = value;
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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Hero(
          tag: product.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "http://10.0.2.2:8090/api/files/products/${product.id}/${product.image}",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
          ),
        ),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${NumberFormat('#,##0', 'vi_VN').format(product.price * quantity)} VND | Số lượng: $quantity'),
      ),
    );
  }
}
