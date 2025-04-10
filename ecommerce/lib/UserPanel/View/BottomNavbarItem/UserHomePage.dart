import 'package:ecommerce/UserPanel/Controller/CartController.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/CategoryPage.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/Home.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/CartPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  int? _userId;

  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    CategoryPage(),
    CartPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      Provider.of<CartController>(context, listen: false).fetchCart(_userId!);
    } else {
      // Handle the case where userId is not set in SharedPreferences
      print('User ID not found in SharedPreferences');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                Consumer<CartController>(
                  builder: (context, cartController, child) {
                    final cartItemCount = cartController.items.length;
                    if (cartItemCount > 0) {
                      return Positioned(
                        left: 8,
                        bottom: 5,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$cartItemCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox(height: 0,width: 0,);
                  },
                ),
              ],
            ),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}