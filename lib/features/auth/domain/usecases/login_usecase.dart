import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, AuthEntity>> call({
    required String emailOrUsername,
    required String password,
  }) async {
    return await repository.login(
      emailOrUsername: emailOrUsername,
      password: password,
    );
  }
}

