import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_service/core/error/failures.dart';
import 'package:hamro_service/features/profile/domain/entities/profile_entity.dart';
import 'package:hamro_service/features/profile/domain/repositories/profile_repository.dart';
import 'package:hamro_service/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ProfileRepository])
import 'update_profile_usecase_test.mocks.dart';

void main() {
  late UpdateProfileUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UpdateProfileUsecase(mockRepository);
  });

  const testProfileEntity = ProfileEntity(
    userId: '123',
    fullName: 'Updated User',
    email: 'updated@example.com',
    phoneNumber: '9876543210',
    avatarUrl: 'https://example.com/new-avatar.jpg',
  );

  group('UpdateProfileUsecase', () {
    test('should return updated ProfileEntity when update is successful', () async {
      when(mockRepository.updateProfile(any))
          .thenAnswer((_) async => Right(testProfileEntity));

      final result = await usecase.call(testProfileEntity);

      expect(result, Right(testProfileEntity));
      verify(mockRepository.updateProfile(testProfileEntity)).called(1);
    });

    test('should return ServerFailure when update fails with invalid data', () async {
      when(mockRepository.updateProfile(any))
          .thenAnswer((_) async => Left(ServerFailure('Invalid data')));

      final result = await usecase.call(testProfileEntity);

      expect(result, Left(ServerFailure('Invalid data')));
      verify(mockRepository.updateProfile(testProfileEntity)).called(1);
    });
  });
}
