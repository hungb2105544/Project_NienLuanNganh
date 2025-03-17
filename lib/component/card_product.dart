// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:project/auth_service.dart';
// import 'package:project/card_view.dart';
// import 'package:project/component/love_button.dart';
// import 'package:project/model/product/product.dart';
// import 'package:provider/provider.dart'; // Để lấy User nếu cần
// import 'package:project/model/user/user.dart'; // Giả định đường dẫn

// class CardProductCustom extends StatefulWidget {
//   const CardProductCustom({super.key, required this.product});
//   final Product product;

//   @override
//   State<CardProductCustom> createState() => _CardProductCustomState();
// }

// class _CardProductCustomState extends State<CardProductCustom> {
//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     final user = authService.currentUser!;

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CardView(product: widget.product),
//           ),
//         );
//       },
//       child: Stack(
//         children: [
//           ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight: 300,
//               maxHeight: 300,
//               minWidth: (MediaQuery.of(context).size.width * 0.2) - 1,
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color.fromARGB(44, 0, 0, 0),
//                     spreadRadius: 1,
//                     blurRadius: 5,
//                     offset: Offset(1, 1),
//                   )
//                 ],
//                 color: Colors.white,
//                 borderRadius: BorderRadius.all(Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: (MediaQuery.of(context).size.height * 0.2) + 10,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                       child: Image(
//                         width: 400,
//                         fit: BoxFit.cover,
//                         image: Image.network(
//                                 "http://10.0.2.2:8090/api/files/products/${widget.product.id}/${widget.product.image}")
//                             .image,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: ListTile(
//                       titleTextStyle: TextStyle(
//                           overflow: TextOverflow.ellipsis,
//                           fontSize: 16,
//                           color: Colors.black),
//                       subtitleTextStyle: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.normal,
//                           fontStyle: FontStyle.italic,
//                           color: Colors.black),
//                       title: Text(
//                         widget.product.name,
//                         maxLines: 2,
//                       ),
//                       subtitle: Padding(
//                         padding: const EdgeInsets.only(top: 10),
//                         child: Text(
//                             '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(widget.product.price)}'),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             height: MediaQuery.of(context).size.height * 0.07,
//             width: MediaQuery.of(context).size.height * 0.07,
//             top: 1,
//             right: 1,
//             child: LoveButton(
//               productId: widget.product.id,
//               user: user, // Truyền User vào đây
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/auth_service.dart';
import 'package:project/card_view.dart';
import 'package:project/component/love_button.dart';
import 'package:project/model/product/product.dart';
import 'package:provider/provider.dart';
import 'package:project/model/user/user.dart';

class CardProductCustom extends StatefulWidget {
  const CardProductCustom({super.key, required this.product});
  final Product product;

  @override
  State<CardProductCustom> createState() => _CardProductCustomState();
}

class _CardProductCustomState extends State<CardProductCustom> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardView(product: widget.product),
          ),
        );
      },
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 300,
              maxHeight: 300,
              minWidth: (MediaQuery.of(context).size.width * 0.2) - 1,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(44, 0, 0, 0),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(1, 1),
                  )
                ],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.2) + 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Image(
                        width: 400,
                        fit: BoxFit.cover,
                        image: Image.network(
                                "http://10.0.2.2:8090/api/files/products/${widget.product.id}/${widget.product.image}")
                            .image,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      titleTextStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16,
                          color: Colors.black),
                      subtitleTextStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic,
                          color: Colors.black),
                      title: Text(
                        widget.product.name,
                        maxLines: 2,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                            '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(widget.product.price)}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.height * 0.07,
              top: 1,
              right: 1,
              child: (user != null)
                  ? LoveButton(
                      productId: widget.product.id,
                      user: user, // Truyền user có thể null
                    )
                  : Container()),
        ],
      ),
    );
  }
}
