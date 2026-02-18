import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_service/core/error/failures.dart';
import 'package:hamro_service/features/auth/domain/entities/auth_entity.dart';
import 'package:hamro_service/features/auth/domain/repositories/auth_repository.dart';
import 'package:hamro_service/features/auth/domain/usecases/login_usecase.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthRepository])
import 'login_usecase_test.mocks.dart';

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  const testAuthEntity = AuthEntity(
    authId: '123',
    fullName: 'Test User',
    email: 'test@example.com',
    username: 'testuser',
    role: 'USER',
  );

  group('LoginUsecase', () {
    test('should return AuthEntity when login is successful', () async {
      when(mockRepository.login(
        emailOrUsername: anyNamed('emailOrUsername'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(testAuthEntity));

      final result = await usecase.call(
        emailOrUsername: 'test@example.com',
        password: 'password123',
      );

      expect(result, Right(testAuthEntity));
      verify(mockRepository.login(
        emailOrUsername: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should return AuthenticationFailure when credentials are invalid', () async {
      when(mockRepository.login(
        emailOrUsername: anyNamed('emailOrUsername'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Left(AuthenticationFailure('Invalid credentials')));

      final result = await usecase.call(
        emailOrUsername: 'wrong@example.com',
        password: 'wrongpassword',
      );

      expect(result, Left(AuthenticationFailure('Invalid credentials')));
      verify(mockRepository.login(
        emailOrUsername: 'wrong@example.com',
        password: 'wrongpassword',
      )).called(1);
    });

    test('should return ServerFailure when network error occurs', () async {
      when(mockRepository.login(
        emailOrUsername: anyNamed('emailOrUsername'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Left(ServerFailure('Network error')));

      final result = await usecase.call(
        emailOrUsername: 'test@example.com',
        password: 'password123',
      );

      expect(result, Left(ServerFailure('Network error')));
      verify(mockRepository.login(
        emailOrUsername: 'test@example.com',
        password: 'password123',
      )).called(1);
    });
  });
}
