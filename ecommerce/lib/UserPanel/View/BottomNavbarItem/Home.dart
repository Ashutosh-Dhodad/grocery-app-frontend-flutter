import 'dart:developer';

import 'package:ecommerce/Auth/View/LoginPage.dart';
import 'package:ecommerce/UserPanel/Controller/CartController.dart';
import 'package:ecommerce/UserPanel/Controller/ProductController.dart';
import 'package:ecommerce/UserPanel/Model/CartItemModel.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/ProductDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _userId;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).fetchProducts();
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
      userName = prefs.getString("userName");
    });
    Provider.of<CartController>(context, listen: false).fetchCart(_userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'FreshMart',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
         
        ),
        centerTitle: true,
       
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildBanner(),
          const SizedBox(height: 10),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

Widget _buildDrawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Colors.green),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome $userName 😊",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _buildDrawerItem(
          icon: Icons.card_giftcard,
          title: 'Refer & Earn',
          subtitle: 'Invite friends & earn ₹100 credits',
          onTap: () => _showSnack('Coming Soon: Refer & Earn!'),
        ),
        _buildDrawerItem(
          icon: Icons.chat,
          title: 'Customer Support & Care',
          subtitle: '24x7 help available',
          onTap: () => _showDialog("Customer Support", "📞 1800-123-4567\n📧 support@freshmart.in"),
        ),
        _buildDrawerItem(
          icon: Icons.location_on,
          title: 'Addresses',
          subtitle: 'Manage delivery addresses',
          onTap: () => _showSnack('Address page coming soon!'),
        ),
        _buildDrawerItem(
          icon: Icons.autorenew,
          title: 'Refunds',
          subtitle: 'Track return/refund status',
          onTap: () => _showDialog("Refunds", "Refunds will be credited within 5-7 business days."),
        ),
        const SizedBox(height: 170),
        Center(
          child: OutlinedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove('jwt');
              prefs.remove('userId');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  LoginPage()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    ),
  );
}


Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  String? subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: Colors.green),
    title: Text(title),
    subtitle: subtitle != null ? Text(subtitle) : null,
    trailing: const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.green),
    onTap: onTap,
  );
}

void _showSnack(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2), backgroundColor: Colors.green,),
  );
}

void _showDialog(String title, String content) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}


  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search groceries...',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search),
      ),
      onChanged: (query) {
        setState(() {
          _searchQuery = query.toLowerCase();
        });
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.local_offer, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Get 20% OFF on fresh veggies today! 🥦🍅🥬',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Consumer<ProductController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allProducts = controller.products.values.expand((list) => list).toList();
        final filteredProducts = allProducts.where((product) => product.name.toLowerCase().contains(_searchQuery)).toList();

        if (filteredProducts.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return GestureDetector(
              onTap: () {
                Provider.of<ProductController>(context, listen: false).setSelectedProduct(product);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailPage()));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.url,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 5),
                          Text(
                            '\u20B9 ${product.price}',
                            style: const TextStyle(fontSize: 16, color: Colors.green),
                          ),
                          const SizedBox(height: 5),
                          OutlinedButton(
                            onPressed: () {
                              final cartItem = CartItemModel(
                                productId: product.id,
                                productName: product.name,
                                price: product.price,
                                quantity: 1,
                                imageUrl: product.url,
                              );
                              Provider.of<CartController>(context, listen: false).addItem(_userId!, cartItem);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                                
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Add to Cart', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
