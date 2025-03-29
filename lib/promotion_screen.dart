import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/login.dart';
import 'package:project/model/promotion/promotion.dart';
import 'package:project/model/promotion/promotion_manager.dart';
import 'package:project/model/promotion_user/promotion_user.dart';
import 'package:project/model/promotion_user/promotion_user_manager.dart';
import 'package:provider/provider.dart';

class PromotionListScreen extends StatefulWidget {
  const PromotionListScreen({super.key});

  @override
  State<PromotionListScreen> createState() => _PromotionListScreenState();
}

class _PromotionListScreenState extends State<PromotionListScreen> {
  late Future<void> _fetchPromotions;
  List<Promotion> _filteredPromotions = [];
  late PromotionManager _promotionManager;

  @override
  void initState() {
    super.initState();
    _fetchPromotions = Future.delayed(Duration.zero, () {
      _promotionManager = Provider.of<PromotionManager>(context, listen: false);
      return _promotionManager.getAllPromotions().then((_) {
        setState(() {
          _filteredPromotions = _promotionManager.promotions;
        });
      });
    });
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
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            border: InputBorder.none,
            suffixIcon: Padding(
              padding: EdgeInsets.only(left: 60, right: 15),
              child: Icon(Icons.search_outlined),
            ),
            hintText: 'Search promotions',
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.only(left: 20),
          ),
          onChanged: (query) {
            setState(() {
              if (query.isEmpty) {
                _filteredPromotions = _promotionManager.promotions;
              } else {
                _filteredPromotions = _promotionManager.promotions
                    .where((promotion) =>
                        promotion.code
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                        promotion.description
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                    .toList();
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthService authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You need to login to view promotions',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Login Now'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
              'Promotions',
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
          SliverToBoxAdapter(
            child: Consumer2<PromotionManager, PromotionUserManager>(
              builder:
                  (context, promotionManager, promotionUserManager, child) {
                return FutureBuilder<void>(
                  future: _fetchPromotions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (_filteredPromotions.isEmpty &&
                        promotionManager.promotions.isEmpty) {
                      return const Center(
                          child: Text('No promotions available'));
                    }

                    if (_filteredPromotions.isEmpty) {
                      return const Center(
                          child: Text('No matching promotions found'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      itemCount: _filteredPromotions.length,
                      itemBuilder: (context, index) {
                        final promotion = _filteredPromotions[index];
                        return PromotionCard(
                          promotion: promotion,
                          userId: user.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PromotionCard extends StatefulWidget {
  final Promotion promotion;
  final String userId;

  const PromotionCard(
      {super.key, required this.promotion, required this.userId});

  @override
  State<PromotionCard> createState() => _PromotionCardState();
}

class _PromotionCardState extends State<PromotionCard> {
  bool _isSaved = false;
  bool _isUsed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPromotionStatus();
  }

  Future<void> _checkPromotionStatus() async {
    final promotionUserManager =
        Provider.of<PromotionUserManager>(context, listen: false);
    try {
      final records = await promotionUserManager.promotionUserDatabase.pb
          .collection('user_promotions')
          .getFullList(filter: "user_id = '${widget.userId}'");
      final promotionUsers =
          records.map((e) => PromotionUser.fromJson(e.toJson())).toList();

      setState(() {
        _isSaved =
            promotionUsers.any((pu) => pu.promotionId == widget.promotion.id);

        final promotionUser = promotionUsers.firstWhere(
          (pu) => pu.promotionId == widget.promotion.id,
          orElse: () => PromotionUser(
            id: '',
            userId: '',
            promotionId: '',
            savedAt: DateTime.now(),
            isUsed: false,
            created: DateTime.now(),
            updated: DateTime.now(),
          ),
        );
        _isUsed = promotionUser.isUsed;
      });
    } catch (e) {
      print('Error checking promotion status: $e');
    }
  }

  Future<void> _savePromotion() async {
    final promotionUserManager =
        Provider.of<PromotionUserManager>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      await promotionUserManager.savePromotion(
          widget.userId, widget.promotion.id);
      setState(() {
        _isSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.done, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Saved promotion: ${widget.promotion.code}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Error: $e',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: widthScreen * 0.2,
              height: 80,
              decoration: BoxDecoration(
                color: (widget.promotion.discountType == 'percentage')
                    ? Colors.blue
                    : Colors.yellow[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_offer,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.promotion.code,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.promotion.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Discount: ${widget.promotion.discountValue}${widget.promotion.discountType == "percentage" ? "%" : ""}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (_isUsed)
                      const Text(
                        'Used',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _isSaved || _isUsed || _isLoading
                    ? null
                    : () {
                        _savePromotion();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (widget.promotion.discountType == 'percentage')
                          ? Colors.blue
                          : Colors.yellow[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isUsed
                            ? 'Used'
                            : _isSaved
                                ? 'Saved'
                                : 'Get Now',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
