import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting current logged-in user
class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<Either<Failure, AuthEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}

