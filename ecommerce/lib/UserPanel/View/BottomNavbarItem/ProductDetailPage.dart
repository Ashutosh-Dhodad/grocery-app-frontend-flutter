import 'package:ecommerce/UserPanel/Controller/ProductController.dart';
import 'package:ecommerce/UserPanel/Service/OrderService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  int? _userId;
  String? _userRole;
  bool _isLoading = false;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
       _userId = prefs.getInt('userId') ?? 0;
      _userRole = prefs.getString('role') ?? '';
    });
  }

  Future<void> _buyNow() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to make a purchase.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final selectedProduct = Provider.of<ProductController>(context, listen: false).selectedProduct;
      await _orderService.buyProduct(_userId!, selectedProduct!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final selectedProduct = Provider.of<ProductController>(context, listen: false).selectedProduct;

    if (selectedProduct == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("No Product Selected"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 350,
                width: double.infinity,
                child: Image.network(
                  selectedProduct.url,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 35,
                left: 16,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 96, 95, 95).withOpacity(1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedProduct.name,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          Container(
                            height: 30,
                            width: 60,
                            padding: EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 20),
                                  const Text(
                                    "4.5",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\u20B9 ${selectedProduct.price}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '\u20B9 ${selectedProduct.price + 20}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedProduct.description,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: const Color.fromARGB(255, 121, 120, 120)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 50,
                        width: 260,
                        padding: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color.fromARGB(255, 224, 226, 225)),
                        child: Row(
                          children: [
                            Icon(Icons.delivery_dining_outlined, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              "Estimated Delivery Time : 10 mins",
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                          height: 200,
                          width: 330,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 211, 208, 208).withOpacity(1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 150,
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color.fromARGB(255, 247, 243, 243),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.policy_sharp, size: 100),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: const Text("No Return Or Replacement"),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 150,
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color.fromARGB(255, 247, 243, 243),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.local_shipping, size: 100),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: const Text("Fast Delivery"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: (_userRole!.toLowerCase() == 'user')
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _buyNow,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Buy Now'),
              ),
            )
          : null,
    );
  }
}