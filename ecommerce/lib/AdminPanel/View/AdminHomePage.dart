// REPLACE your existing AdminHomePage with this

import 'dart:developer';
import 'package:ecommerce/AdminPanel/Services/AdminService.dart';
import 'package:ecommerce/AdminPanel/View/AllUsersPage.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/CategoryPage.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminHomePage> {
  Map<String, dynamic> fetchedStats = {};
  List<dynamic> recentOrders = [];
  List<dynamic> topProducts = [];
  bool isLoading = true;

  final AdminService adminService = AdminService();

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  void fetchDashboardData() async {
    try {
      fetchedStats = await adminService.getDashboardStats();
      recentOrders = await adminService.getRecentOrders();
      topProducts = await adminService.getBestSellingProducts();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _markOrderAsShifted(String orderId) async {
    try {
      await adminService.markOrderAsShifted(orderId);
      fetchDashboardData(); // refresh dashboard
    } catch (e) {
      log("Failed to update order status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🛒 Grocery Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatisticsGrid(),
                  SizedBox(height: 25),
                  _buildSectionTitle("🧾 Recent Orders"),
                  _buildScrollableTable(_buildOrdersTable()),
                  SizedBox(height: 25),
                  _buildSectionTitle("🌟 Best-Selling Products"),
                  _buildTopProductsGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard("Total Products", fetchedStats["totalProducts"].toString(), Colors.blue, Icons.shopping_cart),
        _buildStatCard("Total Orders", fetchedStats["totalOrders"].toString(), Colors.orange, Icons.receipt_long),
        _buildStatCard("Total Users", fetchedStats["totalUsers"].toString(), Colors.green, Icons.people),
        _buildStatCard("Pending Orders", fetchedStats["pendingOrders"].toString(), Colors.red, Icons.hourglass_bottom),
        _buildStatCard("Total Revenue", "\$${fetchedStats["totalRevenue"] ?? 0}", Colors.purple, Icons.attach_money),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return InkWell(
      onTap: () async {
        if (title == "Total Products") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryPage()));
        } else if (title == "Total Users") {
          try {
            final allUsers = await adminService.getAllUsers();
            Navigator.push(context, MaterialPageRoute(builder: (context) => AllUsersPage(users: allUsers)));
          } catch (e) {
            log("Failed to fetch users: $e");
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTable() {
    return _buildDataTable(
      columns: ["Order ID", "Customer", "Status", "Action"],
      rows: recentOrders.map((order) {
        final orderId = order['orderId']?.toString() ?? "N/A";
        final customer = order['customerName'] ?? "N/A";
        final status = order['status'] ?? "unknown";

        return DataRow(cells: [
          DataCell(Text("#$orderId")),
          DataCell(Row(
            children: [
              CircleAvatar(child: Icon(Icons.person, size: 16), radius: 12),
              SizedBox(width: 8),
              Text(customer),
            ],
          )),
          DataCell(Text(
            status,
            style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold),
          )),
          DataCell(
            status.toLowerCase() == 'pending'
                ? ElevatedButton.icon(
                    onPressed: () => _markOrderAsShifted(orderId),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    icon: Icon(Icons.check, color: Colors.white,),
                    label: Text("Mark Shifted", style: TextStyle(color: Colors.white),),
                  )
                : Text("Shifted", style: TextStyle(color: Colors.grey)),
          ),
        ]);
      }).toList(),
    );
  }

  Widget _buildTopProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: topProducts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final product = topProducts[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(product['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
              SizedBox(height: 10),
              Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 6),
              Text("${product['sales']} sales", style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollableTable(Widget table) {
    return SizedBox(height: 400, child: table);
  }

  Widget _buildDataTable({required List<String> columns, required List<DataRow> rows}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 32,
          horizontalMargin: 16,
          headingRowHeight: 40,
          dataRowHeight: 64,
          columns: columns
              .map((col) => DataColumn(label: Text(col, style: TextStyle(fontWeight: FontWeight.bold))))
              .toList(),
          rows: rows.isEmpty
              ? [
                  DataRow(cells: List.generate(columns.length, (index) => DataCell(Text(index == 0 ? "No data" : ""))))
                ]
              : rows,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "delivered":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
