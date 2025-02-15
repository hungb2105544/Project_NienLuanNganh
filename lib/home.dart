import 'package:flutter/material.dart';
import 'package:project/component/card_product.dart';
import 'package:project/component/cart.dart';
import 'package:project/model/product/product.dart';
import 'package:project/model/product/product_manager.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController searchController = TextEditingController();
  final ProductManager productManager = ProductManager();
  @override
  void initState() {
    super.initState();
    productManager.fetchProducts();
  }

  @override
  void dispose() {
    productManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              leading: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Image.asset(
                  'assets/images/minilogo.png',
                  height: 70,
                  width: 70,
                  color: Colors.black,
                ),
              ),
              expandedHeight: 120,
              floating: true,
              pinned: true,
              title: const Text(
                'Luxury Lane',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(90),
                child: _buildSearchBar(),
              ),
              actions: [
                Container(
                  child: const Cart(numberOfCart: 0),
                  margin: EdgeInsets.only(right: 10),
                ),
              ],
            ),
          ];
        },
        body: StreamBuilder<List<Product>>(
          stream: productManager.productsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.black,
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products found'));
            } else {
              final products = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'List Product',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: 190 / 300,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final product = products[index];
                          return CardProductCustom(
                            product: product,
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(44, 0, 0, 0),
              spreadRadius: 1,
              blurRadius: 0,
              offset: Offset(1, 1),
            ),
          ],
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(50),
        ),
        height: 50,
        child: TextField(
          controller: searchController,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            border: InputBorder.none,
            suffixIcon: Padding(
              padding: EdgeInsets.only(
                left: 60,
                right: 15,
              ),
              child: Icon(Icons.search_outlined),
            ),
            hintText: 'Search',
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.only(left: 20),
          ),
        ),
      ),
    );
  }
}
