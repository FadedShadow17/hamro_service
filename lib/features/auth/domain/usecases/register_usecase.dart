import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<Either<Failure, AuthEntity>> call({
    required String fullName,
    required String email,
    String? username,
    required String password,
    String? phoneNumber,
    String? role,
  }) async {
    return await repository.register(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      phoneNumber: phoneNumber,
      role: role,
    );
  }
}

