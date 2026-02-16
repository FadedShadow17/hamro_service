import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/availability_entity.dart';

abstract class AvailabilityRepository {
  Future<Either<Failure, AvailabilityEntity>> getAvailability();
  Future<Either<Failure, AvailabilityEntity>> updateAvailability(List<DayAvailabilityEntity> weeklySchedule);
}
