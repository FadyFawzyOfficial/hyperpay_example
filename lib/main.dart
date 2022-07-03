import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const platform = MethodChannel('com.fadyfawzy/paymentMethod');

  Future<String> get getCheckoutID async {
    String _checkoutID = '';

    try {
      final headers = {
        'Authorization':
            'Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg=',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final body = {
        'entityId': '8a8294174b7ecb28014b9699220015ca',
        'amount': '92.00',
        'currency': 'EUR',
        'paymentType': 'DB',
      };

      final Response response = await post(
        Uri.parse('https://eu-test.oppwa.com/v1/checkouts'),
        headers: headers,
        body: body,
      );

      final Map _resBody = json.decode(response.body);
      if (_resBody['result'] != null && _resBody['result']['code'] != null) {
        if (_resBody['result']['code'] == '000.200.100') {
          _checkoutID = _resBody['id'];
        }
      }

      return _checkoutID;
    } catch (e) {
      print('Failed to get payment method: $e.');
      rethrow;
    }
  }

  Future<void> _getPaymentResponse() async {
    try {
      String checkoutId = await getCheckoutID;
      var result =
          await platform.invokeMethod('getPaymentMethod', <String, dynamic>{
        'checkoutId': checkoutId,
      });
      print(result);
    } on PlatformException catch (e) {
      print("Failed to get payment method: '${e.message}'.");
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyper Pay',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Container(),
    );
  }
}
