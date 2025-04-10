
import 'package:ecommerce/Auth/View/LoginPage.dart';
import 'package:ecommerce/UserPanel/Controller/CartController.dart';
import 'package:ecommerce/UserPanel/Controller/CategoryController.dart';
import 'package:ecommerce/UserPanel/Controller/ProductController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MainApp()
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => CategoryController()),
      ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    )
    );
  }
}
