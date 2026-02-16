import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/repositories/availability_repository.dart';
import '../datasources/provider_availability_remote_datasource.dart';
import '../models/availability_model.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final ProviderAvailabilityRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  AvailabilityRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, AvailabilityEntity>> getAvailability() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final availability = await remoteDataSource.getAvailability();
      return Right(availability.toEntity());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch availability: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AvailabilityEntity>> updateAvailability(List<DayAvailabilityEntity> weeklySchedule) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final scheduleData = weeklySchedule.map((day) {
        return {
          'dayOfWeek': day.dayOfWeek,
          'timeSlots': day.timeSlots.map((slot) => {
            'start': slot.start,
            'end': slot.end,
          }).toList(),
        };
      }).toList();

      final availability = await remoteDataSource.updateAvailability(scheduleData);
      return Right(availability.toEntity());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to update availability: ${e.toString()}'));
    }
  }
}
