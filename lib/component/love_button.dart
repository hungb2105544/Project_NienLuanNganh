import 'package:flutter/material.dart';
import 'package:project/model/favorite_product/favorite_product_manager.dart';
import 'package:provider/provider.dart';
import 'package:project/model/user/user.dart';

class LoveButton extends StatefulWidget {
  final String productId;
  final User? user;

  const LoveButton({
    super.key,
    required this.productId,
    this.user,
  });

  @override
  State<LoveButton> createState() => _LoveButtonState();
}

class _LoveButtonState extends State<LoveButton> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    final favoriteManager =
        Provider.of<FavoriteProductManager>(context, listen: false);
    isLiked = favoriteManager.favoriteProductIds.contains(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProductManager>(
      builder: (context, favoriteManager, child) {
        isLiked = favoriteManager.favoriteProductIds.contains(widget.productId);

        return IconButton(
          onPressed: widget.user == null
              ? null
              : () async {
                  setState(() {
                    isLiked = !isLiked;
                  });
                  try {
                    if (isLiked) {
                      await favoriteManager.addFavoriteProduct(
                          widget.productId, widget.user!);
                    } else {
                      await favoriteManager.removeFavoriteProduct(
                          widget.productId, widget.user!);
                    }
                  } catch (e) {
                    setState(() {
                      isLiked = !isLiked;
                    });
                    print("Lỗi khi cập nhật yêu thích: $e");
                  }
                },
          icon: ClipOval(
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(124, 187, 187, 187)),
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  isLiked
                      ? 'assets/images/heart.png'
                      : 'assets/images/heart_outline.png',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
