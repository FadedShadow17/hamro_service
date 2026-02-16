import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayableBookings() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final payments = await remoteDataSource.getPayableBookings();
      return Right(payments.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch payable bookings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> payForBooking(String bookingId, String paymentMethod) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final payment = await remoteDataSource.payForBooking(bookingId, paymentMethod);
      return Right(payment.toEntity());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to process payment: ${e.toString()}'));
    }
  }
}
