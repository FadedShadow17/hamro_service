import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_service/core/error/failures.dart';
import 'package:hamro_service/features/profile/domain/entities/profile_entity.dart';
import 'package:hamro_service/features/profile/domain/repositories/profile_repository.dart';
import 'package:hamro_service/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ProfileRepository])
import 'get_profile_usecase_test.mocks.dart';

void main() {
  late GetProfileUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = GetProfileUsecase(mockRepository);
  });

  const testProfileEntity = ProfileEntity(
    userId: '123',
    fullName: 'Test User',
    email: 'test@example.com',
    phoneNumber: '1234567890',
    avatarUrl: 'https://example.com/avatar.jpg',
  );

  group('GetProfileUsecase', () {
    test('should return ProfileEntity when profile retrieval is successful', () async {
      when(mockRepository.getProfile())
          .thenAnswer((_) async => Right(testProfileEntity));

      final result = await usecase.call();

      expect(result, Right(testProfileEntity));
      verify(mockRepository.getProfile()).called(1);
    });

    test('should return UserNotFoundFailure when profile is not found', () async {
      when(mockRepository.getProfile())
          .thenAnswer((_) async => Left(UserNotFoundFailure('Profile not found')));

      final result = await usecase.call();

      expect(result, Left(UserNotFoundFailure('Profile not found')));
      verify(mockRepository.getProfile()).called(1);
    });
  });
}
