import 'dart:developer';
import 'package:ecommerce/AdminPanel/Services/AdminService.dart';
import 'package:ecommerce/UserPanel/Controller/CategoryController.dart';
import 'package:ecommerce/UserPanel/Model/CategoryModel.dart';
import 'package:ecommerce/UserPanel/Service/CategoryService.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/CategoryProductsPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  final CategoryService _categoryService = CategoryService();
  Map<String, List<CategoryModel>> categories = {};
  bool isLoading = true;
  String? _role;
  @override
  void initState() {
    super.initState();
    log("IN INIT");
    _loadUserRole();
    fetchCategories();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? '';
    });
  }

  Future<void> fetchCategories() async {
    await _categoryService.fetchCategoris();
    log("IN INIT FETCH CATEGORIES");
    setState(() {
      categories = _categoryService.getAllCategories;
      log("CATEGORIES: $categories");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'All Categories',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Center(child: Text("No categories available"))
              : ListView.builder(
                  itemCount: categories.keys.length,
                  itemBuilder: (context, index) {
                    String categoryName = categories.keys.elementAt(index);
                    List<CategoryModel> categoryList =
                        categories[categoryName]!;
                    return CategorySection(
                      categoryName: categoryName,
                      categoryList: categoryList,
                    );
                  },
                ),
      floatingActionButton:_role == null?null : _role!.toLowerCase() == 'admin' ?
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
              builder: (context) => _buildBottomSheet(context),
            );
          },
          child: Text(
            "Add Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ):null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBottomSheet(BuildContext context) {

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
            "Add Category",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          /// **Category Name Input**
          TextField(
            controller: categoryController,
            decoration: InputDecoration(
              labelText: "Category Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),

          /// **Product Name Input**
          TextField(
            controller: productController,
            decoration: InputDecoration(
              labelText: "Product Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),

          /// **Image URL Input**
          TextField(
            controller: imageController,
            decoration: InputDecoration(
              labelText: "Image URL",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),

          /// **Submit Button**
          ElevatedButton(
            onPressed: () {
              _submitCategory(
                context,
                categoryController.text,
                productController.text,
                imageController.text,
              );
            },
            child: Text("Submit"),
          ),
          SizedBox(height: 20),
        ],
      ),
    ),
  );
}

void _submitCategory(BuildContext context, String categoryName, String prodName, String imgUrl) async{
  if (categoryName.isEmpty || prodName.isEmpty || imgUrl.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  // Send Data to Backend (You can replace this with an API call)
  log("Category: $categoryName, Product: $prodName, Image: $imgUrl");
  try {
      await AdminService().addCategory({
        categoryName: [
          {
            'categoryName': categoryName,
            'imgUrl': imgUrl,
            'prodName': prodName,
          }
        ]
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Category Added Successfully")),
      );

      categoryController.clear();
      productController.clear();
      imageController.clear();

    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to Add Category")),
      );
    }

  // Close the Bottom Sheet
  Navigator.pop(context);
}

}

class CategorySection extends StatelessWidget {
  final String categoryName;
  final List<CategoryModel> categoryList;

  CategorySection({required this.categoryName, required this.categoryList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: const Color.fromARGB(255, 198, 197, 197),
        ),
        Row(children: [
          const SizedBox(
            width: 35,
          ),
          Text(
            categoryName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ]),
        const SizedBox(
          height: 20,
        ),
        Wrap(
          spacing: 25,
          runSpacing: 25,
          children: categoryList
              .map((category) => buildCategoryCard(category, context))
              .toList(),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget buildCategoryCard(CategoryModel category, BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Provider.of<CategoryController>(context, listen: false)
                .setSelectedCategory(category);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CategoryProductsPage()));
          },
          child: Container(
            width: 120,
            height: 120,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left: 35),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 243, 241, 241),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)],
            ),
            child: Image.network(
              category.imgUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 35, top: 10),
          child: Text(
            category.prodName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
