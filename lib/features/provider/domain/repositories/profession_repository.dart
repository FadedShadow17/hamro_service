import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profession_entity.dart';

abstract class ProfessionRepository {
  Future<Either<Failure, List<ProfessionEntity>>> getAllProfessions();
}
