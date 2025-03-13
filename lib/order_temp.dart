// import 'package:flutter/material.dart';
// import 'package:project/auth_service.dart';
// import 'package:project/model/address/address.dart';
// import 'package:project/model/address/address_manager.dart';
// import 'package:project/model/cart/cart.dart';
// import 'package:project/model/database/pocketbase.dart';
// import 'package:project/model/order/order.dart';
// import 'package:project/model/product/product.dart';
// import 'package:project/model/product/product_manager.dart';
// import 'package:project/model/user/user.dart';
// import 'package:project/order_information_page.dart';
// import 'package:project/success_screen_order.dart';
// import 'package:provider/provider.dart';
// import 'package:random_string/random_string.dart';

// class OrderTemp extends StatefulWidget {
//   const OrderTemp({super.key, required this.listId});
//   final List<String> listId;

//   @override
//   State<OrderTemp> createState() => _OrderTempState();
// }

// class _OrderTempState extends State<OrderTemp> {
//   List<Product> listProduct = [];
//   List<Address> addresses = [];
//   String? paymentMethod;
//   Address? selectedAddress;
//   double totalPrice = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     fetchProduct();
//     fetchAddress();
//   }

//   Future<void> fetchProduct() async {
//     List<Product> list = await getProductsOfOrder(widget.listId);
//     if (mounted) {
//       setState(() {
//         listProduct = list;
//         totalPrice = list.fold(0.0, (sum, item) => sum + item.price);
//       });
//     }
//   }

//   Future<void> fetchAddress() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     final user = authService.currentUser;

//     if (user == null) {
//       print("User is null. Cannot fetch addresses.");
//       return;
//     }

//     print("Fetching addresses for User ID: ${user.id}");

//     try {
//       List<Address> list = await AddressManager().getAddressesByUserId(user.id);
//       if (mounted) {
//         setState(() {
//           addresses = list;
//         });
//       }
//     } catch (e) {
//       print("Error fetching addresses: $e");
//     }
//   }

//   Future<List<Product>> getProductsOfOrder(List<String> idProducts) async {
//     ProductManager productManager = ProductManager();
//     List<Product> products = [];

//     for (var id in idProducts) {
//       final product = await productManager.getProductById(id);
//       products.add(product);
//     }

//     return products;
//   }

//   Future<void> makeOrder() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     final user = authService.currentUser;
//     final DataBase dataBase = DataBase();
//     if (user == null || paymentMethod == null || selectedAddress == null) {
//       print("Error: Missing order details.");
//       return;
//     }

//     final body = <String, dynamic>{
//       "userid": user.id,
//       "order_code": "OCD${randomNumeric(5)}",
//       "order_date": DateTime.now().toString(),
//       "total_number": widget.listId.length,
//       "status": "pending",
//       "payment_method": paymentMethod,
//       "address_id": selectedAddress!.id,
//       "total_number": totalPrice,
//     };
//     print(body);
//     try {
//       await dataBase.pb.collection('orders').create(body: body);
//       print("Order created successfully.");
//     } catch (e) {
//       print("Create order error: $e");
//     }
//     try {
//       final order = await dataBase.pb.collection('orders').getList(
//             filter: 'userid="${user.id}"',
//             sort: '-created',
//           );
//       final Order newOrder = Order.fromJson(order.items[0].toJson());
//       final bodyOrderItem = <String, dynamic>{
//         "order_id": newOrder.id,
//         "product_id": widget.listId,
//       };
//       // Create order item
//       await dataBase.pb.collection('order_item').create(body: bodyOrderItem);
//       print("Order item created successfully.");
//       // Update cart
//       final recordCart = await dataBase.pb
//           .collection('cart')
//           .getFullList(filter: 'user_id = "${user.id}"');
//       final Cart cart = Cart.fromJson(recordCart.first.toJson());
//       List<String> listOldId = cart.productId;
//       List<String> listNewId = [];

//       for (var id in listOldId) {
//         if (!widget.listId.contains(id)) {
//           listNewId.add(id);
//         }
//       }
//       // Update cart
//       final bodyCart = <String, dynamic>{
//         "user_id": "${user.id}",
//         "product_id": listNewId,
//       };
//       await dataBase.pb.collection('cart').update('${cart.id}', body: bodyCart);
//     } catch (e) {
//       print("Get order error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);
//     final user = authService.currentUser;

//     return Scaffold(
//       appBar: AppBar(title: Text('Order Information')),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           padding: EdgeInsets.all(8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('User information', style: _titleStyle),
//               SizedBox(height: 8),
//               _buildUserInfo(user),
//               SizedBox(height: 8),
//               Text('List Products', style: _titleStyle),
//               listProduct.isEmpty
//                   ? Center(child: CircularProgressIndicator())
//                   : Column(
//                       children: listProduct.map((product) {
//                         return ProductItemInOrder(
//                           product: product,
//                           quantity: 1,
//                           onRemove: () {},
//                         );
//                       }).toList(),
//                     ),
//               SizedBox(height: 8),
//               Text('Address', style: _titleStyle),
//               addresses.isEmpty
//                   ? Center(child: CircularProgressIndicator())
//                   : AddressSelection(
//                       addresses: addresses,
//                       onAddressSelected: (selected) {
//                         setState(() {
//                           selectedAddress = selected;
//                         });
//                       },
//                     ),
//               SizedBox(height: 8),
//               Text('Payment Method', style: _titleStyle),
//               PaymentDropdown(
//                 onChanged: (value) {
//                   setState(() {
//                     paymentMethod = value!;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomBar(),
//     );
//   }

//   Widget _buildUserInfo(User? user) {
//     return Container(
//       padding: EdgeInsets.all(8),
//       decoration: _boxDecoration(),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.black,
//             child: Icon(Icons.person, size: 30, color: Colors.white),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(user?.fullname ?? 'Unknown', style: _boldTextStyle),
//                 SizedBox(height: 4),
//                 Text(user?.phone ?? 'Unknown', style: _normalTextStyle),
//                 SizedBox(height: 4),
//                 Text('Order Status: Pending', style: _normalTextStyle),
//               ],
//             ),
//           ),
//           Icon(Icons.access_time, color: Colors.black54),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       height: 60,
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: [
//           Text('Tổng tiền: ${totalPrice} VND',
//               style: TextStyle(fontSize: 18, color: Colors.black)),
//           Spacer(),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               elevation: 5,
//             ),
//             onPressed: () => {
//               makeOrder(),
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SuccessScreen(),
//                 ),
//               ),
//             },
//             child: Text('Place Order',
//                 style: TextStyle(fontSize: 18, color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   BoxDecoration _boxDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: Colors.black, width: 2),
//       boxShadow: [
//         BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))
//       ],
//     );
//   }
// }

// const _titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
// const _boldTextStyle =
//     TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);
// const _normalTextStyle = TextStyle(fontSize: 16, color: Colors.black);

// class AddressSelection extends StatefulWidget {
//   final List<Address> addresses;
//   final Function(Address) onAddressSelected;

//   const AddressSelection({
//     super.key,
//     required this.addresses,
//     required this.onAddressSelected,
//   });

//   @override
//   State<AddressSelection> createState() => _AddressSelectionState();
// }

// class _AddressSelectionState extends State<AddressSelection> {
//   Address? selectedAddress;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: const Color.fromARGB(0, 255, 255, 255),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: EdgeInsets.all(8),
//           child: ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: widget.addresses.length,
//             itemBuilder: (context, index) {
//               Address address = widget.addresses[index];
//               bool isSelected = selectedAddress == address;

//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     selectedAddress = address;
//                   });
//                   widget.onAddressSelected(address);
//                 },
//                 child: AnimatedContainer(
//                   duration: Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                   margin: EdgeInsets.symmetric(vertical: 6),
//                   padding: EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: isSelected
//                           ? Colors.black
//                           : const Color.fromARGB(255, 0, 0, 0),
//                       width: isSelected ? 3 : 1.5,
//                     ),
//                     color: isSelected ? Colors.black : Colors.white,
//                     boxShadow: isSelected
//                         ? [
//                             BoxShadow(
//                               color: Colors.black26,
//                               blurRadius: 8,
//                               offset: Offset(0, 4),
//                             ),
//                           ]
//                         : [],
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         color: isSelected ? Colors.white : Colors.black,
//                         size: 24,
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               address.type,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: isSelected ? Colors.white : Colors.black,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               '${address.street}, ${address.city}, ${address.state}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: isSelected
//                                     ? Colors.white70
//                                     : Colors.black54,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class PaymentDropdown extends StatefulWidget {
//   final Function(String?) onChanged; // Callback để gửi giá trị lên widget cha

//   PaymentDropdown({required this.onChanged});

//   @override
//   _PaymentDropdownState createState() => _PaymentDropdownState();
// }

// class _PaymentDropdownState extends State<PaymentDropdown> {
//   String? selectedMethod;
//   final List<String> paymentMethods = [
//     "COD",
//     "Credit Card",
//     "Zalopay",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<String>(
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(vertical: 8),
//         ),
//         value: selectedMethod,
//         hint: Text("Select Payment Method", style: TextStyle(fontSize: 16)),
//         isExpanded: true,
//         style: TextStyle(fontSize: 16, color: Colors.black87),
//         dropdownColor: Colors.white,
//         icon: Icon(Icons.arrow_drop_down, color: Colors.black),
//         items: paymentMethods.map((method) {
//           return DropdownMenuItem(
//             value: method,
//             child: Text(method, style: TextStyle(fontWeight: FontWeight.w500)),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             selectedMethod = value;
//           });
//           widget.onChanged(value); // Gửi giá trị lên widget cha
//         },
//       ),
//     );
//   }
// }
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
  const OrderTemp({super.key, required this.listId});
  final List<String> listId;

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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchProduct();
    await fetchAddress();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchProduct() async {
    List<Product> list = await getProductsOfOrder(widget.listId);
    if (mounted) {
      setState(() {
        listProduct = list;
        totalPrice = list.fold(0.0, (sum, item) => sum + item.price);
      });
    }
  }

  Future<void> fetchAddress() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      print("User is null. Cannot fetch addresses.");
      return;
    }

    try {
      List<Address> list = await AddressManager().getAddressesByUserId(user.id);
      if (mounted) {
        setState(() {
          addresses = list;
        });
      }
    } catch (e) {
      print("Error fetching addresses: $e");
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
        SnackBar(
            content: Text('Vui lòng chọn địa chỉ và phương thức thanh toán')),
      );
      return;
    }

    final body = <String, dynamic>{
      "userid": user.id,
      "order_code": "OCD${randomNumeric(5)}",
      "order_date": DateTime.now().toString(),
      "total_number": widget.listId.length,
      "status": "pending",
      "payment_method": paymentMethod,
      "address_id": selectedAddress!.id,
      "total_price": totalPrice,
    };

    try {
      await dataBase.pb.collection('orders').create(body: body);
      final order = await dataBase.pb.collection('orders').getList(
            filter: 'userid="${user.id}"',
            sort: '-created',
          );
      final Order newOrder = Order.fromJson(order.items[0].toJson());
      final bodyOrderItem = <String, dynamic>{
        "order_id": newOrder.id,
        "product_id": widget.listId,
      };
      await dataBase.pb.collection('order_item').create(body: bodyOrderItem);

      final recordCart = await dataBase.pb
          .collection('cart')
          .getFullList(filter: 'user_id = "${user.id}"');
      final Cart cart = Cart.fromJson(recordCart.first.toJson());
      List<String> listOldId = cart.productId;
      List<String> listNewId = [];

      for (var id in listOldId) {
        if (!widget.listId.contains(id)) {
          listNewId.add(id);
        }
      }

      final bodyCart = <String, dynamic>{
        "user_id": "${user.id}",
        "product_id": listNewId,
      };
      await dataBase.pb.collection('cart').update('${cart.id}', body: bodyCart);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi đặt hàng: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Information', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Information', style: _titleStyle),
                      SizedBox(height: 8),
                      _buildUserInfo(user),
                      SizedBox(height: 16),
                      Text('List Products', style: _titleStyle),
                      SizedBox(height: 8),
                      listProduct.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : Column(
                              children: listProduct.map((product) {
                                return ProductItemInOrder(
                                  product: product,
                                  quantity: 1,
                                  onRemove: () {},
                                );
                              }).toList(),
                            ),
                      SizedBox(height: 16),
                      Text('Address', style: _titleStyle),
                      SizedBox(height: 8),
                      addresses.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : AddressSelection(
                              addresses: addresses,
                              onAddressSelected: (selected) {
                                setState(() {
                                  selectedAddress = selected;
                                });
                              },
                            ),
                      SizedBox(height: 16),
                      Text('Payment Method', style: _titleStyle),
                      SizedBox(height: 8),
                      PaymentDropdown(
                        onChanged: (value) {
                          setState(() {
                            paymentMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildUserInfo(User? user) {
    return Container(
      padding: EdgeInsets.all(16),
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
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('Total: ${totalPrice.toStringAsFixed(2)} VND',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black12, width: 1),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
      ],
    );
  }
}

const _titleStyle =
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
const _boldTextStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);
const _normalTextStyle = TextStyle(fontSize: 16, color: Colors.black54);

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
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
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
                      color: isSelected ? Colors.black : Colors.black12,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.black : Colors.black54,
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
                                color: isSelected ? Colors.black : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${address.street}, ${address.city}, ${address.state}',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isSelected ? Colors.black : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 24,
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

class PaymentDropdown extends StatelessWidget {
  final Function(String?) onChanged;

  PaymentDropdown({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
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
        hint: Text("Select Payment Method", style: TextStyle(fontSize: 16)),
        isExpanded: true,
        style: TextStyle(fontSize: 16, color: Colors.black87),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        items: ["COD", "Credit Card", "Zalopay"].map((method) {
          return DropdownMenuItem(
            value: method,
            child: Text(method, style: TextStyle(fontWeight: FontWeight.w500)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
