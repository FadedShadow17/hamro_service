import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/payment_repository_impl.dart';

final paymentRepositoryProvider = Provider<PaymentRepositoryImpl>((ref) {
  throw UnimplementedError('paymentRepositoryProvider must be overridden');
});
