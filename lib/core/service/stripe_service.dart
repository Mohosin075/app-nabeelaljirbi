import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static final StripeService instance = StripeService._internal();
  factory StripeService() => instance;
  StripeService._internal();

  /// Creates a PaymentMethod using the details entered in the CardField.
  /// The CardField must be present in the widget tree and focused/complete.
  Future<String?> createPaymentMethod() async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      return paymentMethod.id;
    } on StripeException catch (e) {
      debugPrint('Stripe Error: ${e.error.localizedMessage}');
      return null;
    } catch (e) {
      debugPrint('Error creating PaymentMethod: $e');
      return null;
    }
  }

  /// Create Payment Intent directly via Stripe API (Client-side)
  /// Note: This uses the Secret Key, which should technically be on the backend.
  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    try {
      final secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

      // Calculate amount in smallest currency unit (e.g. cents)
      final int amountInCents = (amount * 100).toInt();

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error creating Payment Intent: $e');
      return null;
    }
  }

  /// Initialize the Payment Sheet with the client secret fetched from the backend.
  Future<void> initPaymentSheet({
    required String paymentIntentClientSecret,
    required String merchantDisplayName,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentClientSecret,
        merchantDisplayName: merchantDisplayName,
        style: ThemeMode.light,
      ),
    );
  }

  /// Display the Payment Sheet.
  /// Throws an exception if payment is cancelled or fails.
  Future<void> presentPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet();
  }
}
