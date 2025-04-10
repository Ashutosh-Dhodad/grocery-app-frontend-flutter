import 'dart:convert';
import 'dart:developer';

import 'package:ecommerce/Auth/View/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SignUpController{

  Future<void> signUp(String userNameController, String emailController, String passwordController, String roleController, BuildContext context) async {
    final url = Uri.parse('http://192.168.35.151:8081/api/users/register');
    log('Attempting to login with URL: $url');
    log('Username: $userNameController');
    log('email: $emailController');
    log('Password: $passwordController');
    log('Role: $roleController');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
         'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': userNameController,
          'email': emailController,
          'password': passwordController,
          'role': roleController,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.body;
        final token = data;
        log('register successful! Token: $token');

        // Store the token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', token);

        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sign Up Successful"),
          backgroundColor: Colors.green,
        ));
      } else {
        log('Registration failed! ${response.body}');
        final errorMessage = response.body;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      log('Error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}