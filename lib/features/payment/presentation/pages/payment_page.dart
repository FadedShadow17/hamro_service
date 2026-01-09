import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Payment Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
