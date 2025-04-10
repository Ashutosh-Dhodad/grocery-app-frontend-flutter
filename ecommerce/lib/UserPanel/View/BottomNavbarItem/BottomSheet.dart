import 'dart:developer';

import 'package:ecommerce/UserPanel/Controller/CartController.dart';
import 'package:ecommerce/UserPanel/Controller/ProductController.dart';
import 'package:ecommerce/UserPanel/Service/OrderService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({super.key});

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  
    int? _userId;
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
    final cartItems = Provider.of<CartController>(context, listen: false).cartItems;

    for (var item in cartItems) {
      await _orderService.buyProduct(_userId!, item.productId);
    }

    // Optionally clear cart after successful purchase
    Provider.of<CartController>(context, listen: false).clearCart(_userId!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green, duration: Duration(seconds: 2),),
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
    return Consumer<CartController>(
                builder: (context, cartController, child) {
                  final totalAmount = cartController.cartItems.fold(
                    0,
                    (sum, item) => sum + (item.price * item.quantity).toInt(),
                  );

                  return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Order Summary',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                                            
                            const SizedBox(height: 16),
                             Flexible(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: cartController.cartItems.map((item) {
                                      return ListTile(
                                        title: Text(item.productName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600
                                        ),),
                                        subtitle: Text('Quantity: ${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400
                                        ),),
                                        trailing: Text('\u20B9 ${item.price * item.quantity}'),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                               


                            const Divider(),
                            ListTile(
                              title: const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                '\u20B9 $totalAmount',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                                            
                            const SizedBox(height: 16),
                            ElevatedButton(
                            onPressed: _isLoading ? null : _buyNow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Buy Now',
                                style: TextStyle(
                                  color: Colors.white
                                ),),
                          ),
                          ],
                                            ),
                    
                  );
                },
              );
  }
}