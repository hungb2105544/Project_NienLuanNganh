import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/component/card_product.dart';
import 'package:project/model/favorite_product/favorite_product_manager.dart';
import 'package:project/model/user/user.dart';
import 'package:provider/provider.dart';

class FavoriteProductsScreen extends StatefulWidget {
  const FavoriteProductsScreen({Key? key}) : super(key: key);

  @override
  _FavoriteProductsScreenState createState() => _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState extends State<FavoriteProductsScreen> {
  AuthService? authService;
  User? user;
  bool _isInitialized = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    authService = Provider.of<AuthService>(context, listen: false);
    final favoriteManager =
        Provider.of<FavoriteProductManager>(context, listen: false);

    if (authService!.currentUser == null) {
      debugPrint('No user logged in');
      return;
    }

    user = authService!.currentUser!;
    debugPrint('User ID: ${user!.id}');

    try {
      await favoriteManager.fetchFavoriteProducts(user!);
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              scrolledUnderElevation: 0,
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
                'Favorite Products',
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
            ),
          ];
        },
        body: !_isInitialized
            ? const Center(child: CircularProgressIndicator())
            : Consumer<FavoriteProductManager>(
                builder: (context, favoriteManager, child) {
                  final favoriteProducts = favoriteManager.favoriteProduct
                      .where((product) => product.name
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();

                  if (favoriteProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No favorite products yet',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      const SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Your Favorites',
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
                            (context, index) {
                              final product = favoriteProducts[index];
                              return CardProductCustom(product: product);
                            },
                            childCount: favoriteProducts.length,
                          ),
                        ),
                      ),
                    ],
                  );
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
              padding: EdgeInsets.only(left: 60, right: 15),
              child: Icon(Icons.search_outlined),
            ),
            hintText: 'Search',
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.only(left: 20),
          ),
          onChanged: (query) {
            setState(() {
              searchQuery = query;
            });
          },
        ),
      ),
    );
  }
}
