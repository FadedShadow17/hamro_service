import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/provider_order.dart';
import '../../domain/entities/provider_stats.dart';
import '../../domain/repositories/provider_repository.dart';
import '../datasources/provider_local_datasource.dart';
import '../datasources/provider_remote_datasource.dart';
import '../models/provider_order_model.dart';
import '../models/provider_stats_model.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../domain/repositories/provider_verification_repository.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final ProviderRemoteDataSource remoteDataSource;
  final ProviderLocalDataSource localDataSource;
  final ConnectivityService connectivityService;
  final ProviderVerificationRepository? verificationRepository;

  ProviderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
    this.verificationRepository,
  });

  ProviderOrderModel _bookingToOrderModel(BookingModel booking) {
    return ProviderOrderModel(
      id: booking.id,
      customerName: booking.user?['name'] ?? 
                   booking.user?['fullName'] ?? 
                   'Unknown',
      serviceName: booking.service?['name'] ?? 
                  booking.service?['title'] ?? 
                  'Service',
      status: booking.status.toUpperCase(),
      priceRs: (booking.service?['price'] ?? 
               booking.service?['basePrice'] ?? 
               0) as int,
      location: booking.area,
      createdAt: booking.createdAt,
      scheduledDate: DateTime.tryParse(booking.date),
    );
  }

  @override
  Future<Either<Failure, ProviderStats>> getProviderStats() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final dashboard = await remoteDataSource.getDashboardSummary();
        final allBookingsResponse = await remoteDataSource.getProviderBookings();
        
        int totalOrders = allBookingsResponse.length;
        int pendingOrders = 0;
        int confirmedOrders = 0;
        int completedOrders = 0;
        int totalEarnings = 0;

        for (final order in allBookingsResponse) {
          final status = order.status.toUpperCase().trim();
          
          if (status == 'PENDING') {
            pendingOrders++;
          } else if (status == 'CONFIRMED') {
            confirmedOrders++;
          } else if (status == 'COMPLETED') {
            completedOrders++;
            totalEarnings += order.priceRs;
          }
        }

        return Right(ProviderStatsModel(
          totalOrders: totalOrders,
          pendingOrders: pendingOrders,
          confirmedOrders: confirmedOrders,
          completedOrders: completedOrders,
          totalEarnings: totalEarnings,
          averageRating: dashboard.stats.averageRating,
          totalReviews: dashboard.stats.totalReviews,
        ).toEntity());
      } catch (e) {
        try {
          final model = await localDataSource.getProviderStats();
          return Right(model.toEntity());
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final model = await localDataSource.getProviderStats();
        return Right(model.toEntity());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProviderOrder>>> getPendingOrders() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final models = await remoteDataSource.getProviderBookings(status: 'PENDING');
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        try {
          final models = await localDataSource.getPendingOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final models = await localDataSource.getPendingOrders();
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProviderOrder>>> getActiveOrders() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final models = await remoteDataSource.getProviderBookings(status: 'CONFIRMED');
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        try {
          final models = await localDataSource.getActiveOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final models = await localDataSource.getActiveOrders();
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProviderOrder>>> getRecentOrders() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final allBookings = await remoteDataSource.getProviderBookings();
        final recent = allBookings
            .where((order) {
              final status = order.status.toUpperCase();
              return status == 'COMPLETED' || status == 'CANCELLED' || status == 'DECLINED';
            })
            .take(10)
            .map((model) => model.toEntity())
            .toList();
        return Right(recent);
      } catch (e) {
        try {
          final models = await localDataSource.getRecentOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final models = await localDataSource.getRecentOrders();
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProviderOrder>>> getProviderBookings({String? status}) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final models = await remoteDataSource.getProviderBookings(status: status);
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        try {
          if (status == 'PENDING' || status == null) {
            final models = await localDataSource.getPendingOrders();
            return Right(models.map((model) => model.toEntity()).toList());
          } else if (status == 'CONFIRMED' || status == 'in_progress') {
            final models = await localDataSource.getActiveOrders();
            return Right(models.map((model) => model.toEntity()).toList());
          } else {
            final models = await localDataSource.getRecentOrders();
            return Right(models.map((model) => model.toEntity()).toList());
          }
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        if (status == 'PENDING' || status == null) {
          final models = await localDataSource.getPendingOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        } else if (status == 'CONFIRMED' || status == 'in_progress') {
          final models = await localDataSource.getActiveOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        } else {
          final models = await localDataSource.getRecentOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        }
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ProviderOrder>> acceptBooking(String bookingId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.acceptBooking(bookingId);
      return Right(_bookingToOrderModel(booking).toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProviderOrder>> declineBooking(String bookingId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.declineBooking(bookingId);
      return Right(_bookingToOrderModel(booking).toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProviderOrder>> completeBooking(String bookingId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.completeBooking(bookingId);
      return Right(_bookingToOrderModel(booking).toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProviderById(String providerId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final providerData = await remoteDataSource.getProviderById(providerId);
      return Right(providerData);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkVerificationStatus() async {
    if (verificationRepository == null) {
      return const Left(CacheFailure('Verification repository not available'));
    }

    final result = await verificationRepository!.getVerificationSummary();
    return result.fold(
      (failure) => Left(failure),
      (summary) {
        return Right({
          'verificationStatus': summary['status'] ?? summary['verificationStatus'] ?? 'not_submitted',
          'serviceRole': summary['serviceRole'],
        });
      },
    );
  }
}
