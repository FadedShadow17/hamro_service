import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentEntity>>> getPayableBookings();
  Future<Either<Failure, PaymentEntity>> payForBooking(String bookingId, String paymentMethod);
  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory();
}
