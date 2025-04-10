
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService{

  Future<void> Function() get getCheckout => _openCheckout;
  late Razorpay _razorpay;
  
  Future<void> _openCheckout() async {
    try {
      log("IN ORDER CHECKOUT-------");
      final order = await createOrder(1000);
      var options = {
        'key': 'rzp_test_haDRsJIQo9vFPJ',
        'amount': order['amount'],
        'order_id': order['id'],
        'name': 'ecommerce',
        'description': 'Payment for Order',
        'prefill': {
          'contact': '8788243121',
          'email': 'test@example.com'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      print("Error creating order: $e");
    }
  }


Future<Map<String, dynamic>> createOrder(int amount) async {
  final url = Uri.parse('http://192.168.35.151:8081/api/order/createOrder');
  final prefs = await SharedPreferences.getInstance();
  log(prefs.getString('jwt') ?? '');
  final token = prefs.getString('jwt') ?? '';


  try {
    log("Sending request to create order with amount: $amount");
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
        },
      body: jsonEncode({'amount': amount}),
    );

    log("Response received: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      log("Order created successfully: $data");
      return data;
    } else {
      log("Failed to create order. Status Code: ${response.statusCode}, Body: ${response.body}");
      throw Exception("Failed to create order. Status Code: ${response.statusCode}");
    }
  } catch (e, stackTrace) {
    log("An error occurred while creating the order: $e", stackTrace: stackTrace);
    throw Exception("An error occurred while creating the order");
  }
}



   Future<void> verifyPayment(String orderId, String paymentId, String signature) async {
    final url = Uri.parse('http://192.168.35.151:8081/api/payment/verifyPayment');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      }),
    );

    if (response.statusCode == 200) {
      print('Payment verified');
    } else {
      throw Exception('Failed to verify payment');
    }
  }

}