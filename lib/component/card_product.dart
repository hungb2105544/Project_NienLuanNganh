import 'package:flutter/material.dart';
import 'package:project/card_view.dart';
import 'package:project/component/love_button.dart';
import 'package:project/model/product/product.dart';

class CardProductCustom extends StatefulWidget {
  const CardProductCustom({super.key, required this.product});
  final Product product;

  @override
  State<CardProductCustom> createState() => _CardProductCustomState();
}

class _CardProductCustomState extends State<CardProductCustom> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
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
                    //Truyền vào sản phẩm sau đó lấy ra tên sản phẩm ở đây
                    title: Text(
                      widget.product.name,
                      maxLines: 2,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text('${widget.product.price}' + ' VND'),
                    ),
                  )),
                ],
              ),
            ),
          ),
          Positioned(
            height: MediaQuery.of(context).size.height * 0.07,
            width: MediaQuery.of(context).size.height * 0.07,
            top: 1,
            right: 1,
            child: LoveButton(),
          ),
        ],
      ),
    );
  }
}
