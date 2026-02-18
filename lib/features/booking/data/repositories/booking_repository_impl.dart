import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/entities/service_option.dart';
import '../../domain/entities/time_slot.dart';
import '../datasources/booking_local_datasource.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_model.dart';
import '../../../services/data/datasources/services_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final BookingLocalDataSource localDataSource;
  final ConnectivityService connectivityService;
  final ServicesRemoteDataSource? servicesRemoteDataSource;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
    this.servicesRemoteDataSource,
  });

  @override
  Future<List<ServiceOption>> getServiceOptions(String serviceId, String categoryTag) {
    return localDataSource.getServiceOptions(serviceId, categoryTag);
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date) {
    return localDataSource.getAvailableTimeSlots(date);
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlotsFromAPI({
    required String serviceId,
    required String date,
    required String area,
  }) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    if (servicesRemoteDataSource == null) {
      return const Left(ServerFailure('Services remote datasource not available'));
    }

    try {
      final providers = await servicesRemoteDataSource!.getAvailableProviders(
        serviceId: serviceId,
        date: date,
        area: area,
      );

      final timeSlots = <TimeSlot>[];
      final Set<String> uniqueTimes = {};

      for (final provider in providers) {
        final availability = provider['availability'];
        if (availability != null && availability is Map) {
          final timeSlotsList = availability['timeSlots'];
          if (timeSlotsList != null && timeSlotsList is List) {
            for (final slot in timeSlotsList) {
              if (slot is Map) {
                final startTime = slot['start'] as String?;
                if (startTime != null && !uniqueTimes.contains(startTime)) {
                  uniqueTimes.add(startTime);


                  timeSlots.add(TimeSlot(
                    id: startTime,
                    time: _formatTime(startTime),
                    isAvailable: true,
                  ));
                }
              }
            }
          }
        }
      }

      if (timeSlots.isEmpty) {
        final defaultSlots = _generateDefaultTimeSlots();
        return Right(defaultSlots);
      }

      timeSlots.sort((a, b) => a.time.compareTo(b.time));
      return Right(timeSlots);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch time slots: ${e.toString()}'));
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  List<TimeSlot> _generateDefaultTimeSlots() {
    final slots = <TimeSlot>[];
    for (int hour = 9; hour <= 17; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 12 ? 12 : hour);
        final timeStr = '$displayHour:${minute.toString().padLeft(2, '0')} $period';

        final idStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        slots.add(TimeSlot(
          id: idStr,
          time: timeStr,
          isAvailable: true,
        ));
      }
    }
    return slots;
  }

  @override
  Future<Either<Failure, BookingModel>> createBooking({
    required String serviceId,
    String? providerId,
    required String date,
    required String timeSlot,
    required String area,
  }) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.createBooking(
        serviceId: serviceId,
        date: date,
        timeSlot: timeSlot,
        area: area,
      );
      return Right(booking);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingModel>>> getMyBookings({String? status}) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final bookings = await remoteDataSource.getMyBookings(status: status);
      return Right(bookings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> cancelBooking(String bookingId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.cancelBooking(bookingId);
      return Right(booking);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingModel>>> getProviderBookings({String? status}) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final bookings = await remoteDataSource.getProviderBookings(status: status);
      return Right(bookings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> acceptBooking(String bookingId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.acceptBooking(bookingId);
      return Right(booking);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> declineBooking(String bookingId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.declineBooking(bookingId);
      return Right(booking);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> completeBooking(String bookingId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.completeBooking(bookingId);
      return Right(booking);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> updateBooking({
    required String bookingId,
    String? date,
    String? timeSlot,
    String? area,
  }) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.updateBooking(
        bookingId: bookingId,
        date: date,
        timeSlot: timeSlot,
        area: area,
      );
      return Right(booking);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> updateBookingStatus(String bookingId, String status) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final booking = await remoteDataSource.updateBookingStatus(bookingId, status);
      return Right(booking);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
