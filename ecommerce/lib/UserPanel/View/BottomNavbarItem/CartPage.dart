import 'dart:developer';
import 'package:ecommerce/UserPanel/Controller/CartController.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/BottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int? _userId;
  late Future<void> _loadUserIdFuture;

  @override
  void initState() {
    super.initState();
    _loadUserIdFuture = _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId') ?? 0;
    setState(() {
      _userId = id;
      log("UserId: $_userId");
    });

    // Fetch cart using shared CartController
    final cartController = Provider.of<CartController>(context, listen: false);
    await cartController.fetchCart(_userId!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadUserIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading user ID'));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cart'),
              centerTitle: true,
            ),
            body: Column(
              children: [
                Consumer<CartController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.cartItems.isEmpty) {
                      return const Center(child: Text('No products available'));
                    }

                    final items = controller.cartItems.toList();

                    return Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\u20B9 ${item.price}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        '\u20B9 ${item.price + 20}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  leading: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                      '\u20B9 ${item.price.toStringAsFixed(2)}'),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 50,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 208, 76, 120),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (item.quantity > 0) {
                                            final newQuantity =
                                                item.quantity - 1;
                                            Provider.of<CartController>(context,
                                                    listen: false)
                                                .updateItemQuantity(
                                                    _userId!,
                                                    item.productId,
                                                    newQuantity);
                                          }
                                        },
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text("  ${item.quantity}  "),
                                      InkWell(
                                        onTap: () {
                                          final newQuantity = item.quantity + 1;
                                          Provider.of<CartController>(context,
                                                  listen: false)
                                              .updateItemQuantity(
                                                  _userId!,
                                                  item.productId,
                                                  newQuantity);
                                        },
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return const MyBottomSheet();
                  },
                );
              },
              label: const Text(
                "Checkout Now",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),

            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        }
      },
    );
  }
}
