import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUsecase {
  final ProfileRepository repository;

  UpdateProfileUsecase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(ProfileEntity profile) async {
    return await repository.updateProfile(profile);
  }
}

