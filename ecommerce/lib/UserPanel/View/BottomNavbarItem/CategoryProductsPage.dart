import 'dart:developer';

import 'package:ecommerce/AdminPanel/Services/AdminService.dart';
import 'package:ecommerce/UserPanel/Controller/CartController.dart';
import 'package:ecommerce/UserPanel/Controller/CategoryController.dart';
import 'package:ecommerce/UserPanel/Controller/ProductController.dart';
import 'package:ecommerce/UserPanel/Model/CartItemModel.dart';
import 'package:ecommerce/UserPanel/Model/CategoriesProductModel.dart';
import 'package:ecommerce/UserPanel/Service/CategoryService.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/ProductDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProductsPage extends StatefulWidget {
  const CategoryProductsPage({super.key});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {


  CategoryService categoryService = CategoryService();
  bool isLoading = true; // Manage loading state
  List allProducts = []; // Store all products here
  int? _userId;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    // Fetch products asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final categoryController =
          Provider.of<CategoryController>(context, listen: false);
          log("this is selected products: ${categoryController.selectedCategory!.prodName}");
      await categoryService.fetchCategorisProducts(
          categoryController.selectedCategory!.prodName);
          

      // Once data is fetched, update the UI
      setState(() {
        allProducts = categoryService.getAllCategoriesProducts.values
            .expand((list) => list)
            .toList();
        isLoading = false; // Data fetched, stop loading
      });
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
      _role = prefs.getString('role') ?? '';
    });
    Provider.of<CartController>(context, listen: false).fetchCart(_userId!);
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);
    final selectedCategory = categoryController.selectedCategory;

    if (selectedCategory == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Category")),
        body: Center(child: Text("No category selected")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory.prodName,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()) // Show loading when fetching
          : allProducts.isEmpty
              ? Center(
                  child: Text(
                      "No products found in this category")) // Show message if no products
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two products per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.65, // Adjust item height
                    ),
                    itemCount: allProducts.length,
                    itemBuilder: (context, index) {
                      CategoriesProductModel product = allProducts[index];

                      return GestureDetector(
                        onTap: () {
                          Provider.of<ProductController>(context, listen: false)
                              .setSelectedProduct(product.toProductModel());
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductDetailPage()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.network(
                                    product.url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.image_not_supported,
                                          size: 50, color: Colors.grey);
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "₹ ${product.price}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                    SizedBox(height: 10),
                                    if (_role!.toLowerCase() == 'user') 
                                      CustomeCart(product: product, userId: _userId!),
                                    
                                    if (_role!.toLowerCase() == 'admin') 
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        /// **Delete Button**
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          height: 40,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.red),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () async {
                                              bool isDeleted = await AdminService().deleteProduct(product.id);
                                              if (isDeleted) {
                                                setState(() {
                                                  allProducts.removeAt(index);
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("Failed to delete product")),
                                                );
                                              }
                                            },
                                          ),
                                        ),

                                        /// **Edit Button**
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          height: 40,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.edit, color: Color.fromARGB(255, 123, 123, 123)),
                                            onPressed: () {
                                              print("Edit Product with ID: ${product.id}");
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                ),
                                                builder: (context) => AddProductBottomSheet(product: product),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

        floatingActionButton:_role!.toLowerCase() == 'admin' ? 
         Container(
        height: 50,
        width: 140,
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // To allow full-screen view
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => AddProductBottomSheet(),
            );
          },
          child: Text(
            "Add Product",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ):null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


class AddProductBottomSheet extends StatefulWidget {
  final CategoriesProductModel? product;

  const AddProductBottomSheet({super.key, this.product});

  @override
  _AddProductBottomSheetState createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  late TextEditingController productNameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController imgUrlController;
  late TextEditingController categoryController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.product != null;
    productNameController = TextEditingController(text: widget.product?.name ?? '');
    descriptionController = TextEditingController(text: widget.product?.description ?? '');
    priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    imgUrlController = TextEditingController(text: widget.product?.url ?? '');
    categoryController = TextEditingController(text: widget.product?.category ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text(
              isEditing ? "Edit Product" : "Add Product",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            TextField(controller: productNameController, decoration: InputDecoration(labelText: "Product Name", border: OutlineInputBorder())),
            SizedBox(height: 12),

            TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Product Description", border: OutlineInputBorder())),
            SizedBox(height: 12),

            TextField(controller: priceController, decoration: InputDecoration(labelText: "Product Price", border: OutlineInputBorder())),
            SizedBox(height: 12),

            TextField(controller: imgUrlController, decoration: InputDecoration(labelText: "Image URL", border: OutlineInputBorder())),
            SizedBox(height: 12),

            TextField(controller: categoryController, decoration: InputDecoration(labelText: "Category Name", border: OutlineInputBorder())),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                double? price = double.tryParse(priceController.text);
                if (price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid price")));
                  return;
                }

                CategoriesProductModel newProduct = CategoriesProductModel(
                  id: isEditing ? widget.product!.id : DateTime.now().millisecondsSinceEpoch,
                  name: productNameController.text,
                  description: descriptionController.text,
                  price: price,
                  url: imgUrlController.text,
                  category: categoryController.text,
                );

                if (isEditing) {
                  await AdminService().updateProduct(widget.product!.id, newProduct);
                } else {
                  await AdminService().addProduct(newProduct);
                }

                Navigator.pop(context);
              },
              child: Text(isEditing ? "Update" : "Submit"),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}




class CustomeCart extends StatelessWidget {
  final CategoriesProductModel product;
  final int userId;

  CustomeCart({required this.product, required this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final cartItem = CartItemModel(
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: 1,
          imageUrl: product.url,
        );

        Provider.of<CartController>(context, listen: false)
            .addItem(userId, cartItem);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product Added to Cart',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        height: 50,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Add to cart',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
