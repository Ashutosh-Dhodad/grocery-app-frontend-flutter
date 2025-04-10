import 'dart:developer';

import 'package:flutter/material.dart';

class AllUsersPage extends StatelessWidget {
  final List<dynamic> users;

  AllUsersPage({required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Users",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: users.isEmpty
            ? Center(
                child: Text(
                  "No users available.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final name = user['name'] ?? 'No Name';
                  final email = user['email'] ?? 'No Email';
                  log("User: $user");
                  final initials = _getInitials(name);

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          initials,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(email),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        // TODO: Add navigation to user details page
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.trim().split(" ");
    if (names.length >= 2) {
      return "${names[0][0]}${names[1][0]}".toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return "U";
  }
}
