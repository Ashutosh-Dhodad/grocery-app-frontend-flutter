import 'dart:convert';
import 'dart:developer';
import 'package:ecommerce/AdminPanel/View/AdminHomePage.dart';
import 'package:ecommerce/UserPanel/View/BottomNavbarItem/UserHomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Logincontroller {
    Future<void> login(String userNameController, String passwordController, BuildContext context) async {
    final url = Uri.parse('http://192.168.35.151:8081/api/auth/authenticate');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userNameController);
    
    log('Attempting to login with URL: $url');
    log('Username: $userNameController');
    log('Password: $passwordController');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
         'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': userNameController,
          'password': passwordController,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['jwt'];
        log('Login successful! Token: $token');

        // Store the token
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setString('jwt', token);
        final storedToken = prefs.getString('jwt');
        log('Stored token: $storedToken');

        final userId = data['userId'];
        await prefs.setInt("userId", userId);
        await prefs.setString('role', data['role']);

        if(data['role'].toLowerCase() == 'user'){
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const UserHomePage()));
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  AdminHomePage()));
        }


      } else {
        log('Login failed! ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed! Please enter valid username and password'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print('Error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}