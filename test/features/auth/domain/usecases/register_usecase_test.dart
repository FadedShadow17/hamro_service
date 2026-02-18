import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_service/core/error/failures.dart';
import 'package:hamro_service/features/auth/domain/entities/auth_entity.dart';
import 'package:hamro_service/features/auth/domain/repositories/auth_repository.dart';
import 'package:hamro_service/features/auth/domain/usecases/register_usecase.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthRepository])
import 'register_usecase_test.mocks.dart';

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(mockRepository);
  });

  const testAuthEntity = AuthEntity(
    authId: '123',
    fullName: 'New User',
    email: 'newuser@example.com',
    username: 'newuser',
    phoneNumber: '1234567890',
    role: 'USER',
  );

  group('RegisterUsecase', () {
    test('should return AuthEntity when registration is successful', () async {
      when(mockRepository.register(
        fullName: anyNamed('fullName'),
        email: anyNamed('email'),
        username: anyNamed('username'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        role: anyNamed('role'),
      )).thenAnswer((_) async => Right(testAuthEntity));

      final result = await usecase.call(
        fullName: 'New User',
        email: 'newuser@example.com',
        username: 'newuser',
        password: 'password123',
        phoneNumber: '1234567890',
        role: 'USER',
      );

      expect(result, Right(testAuthEntity));
      verify(mockRepository.register(
        fullName: 'New User',
        email: 'newuser@example.com',
        username: 'newuser',
        password: 'password123',
        phoneNumber: '1234567890',
        role: 'USER',
      )).called(1);
    });

    test('should return UserAlreadyExistsFailure when email already exists', () async {
      when(mockRepository.register(
        fullName: anyNamed('fullName'),
        email: anyNamed('email'),
        username: anyNamed('username'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        role: anyNamed('role'),
      )).thenAnswer((_) async => Left(UserAlreadyExistsFailure('Email already exists')));

      final result = await usecase.call(
        fullName: 'New User',
        email: 'existing@example.com',
        password: 'password123',
      );

      expect(result, Left(UserAlreadyExistsFailure('Email already exists')));
      verify(mockRepository.register(
        fullName: 'New User',
        email: 'existing@example.com',
        username: null,
        password: 'password123',
        phoneNumber: null,
        role: null,
      )).called(1);
    });

    test('should return ServerFailure when registration validation fails', () async {
      when(mockRepository.register(
        fullName: anyNamed('fullName'),
        email: anyNamed('email'),
        username: anyNamed('username'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        role: anyNamed('role'),
      )).thenAnswer((_) async => Left(ServerFailure('Validation failed')));

      final result = await usecase.call(
        fullName: '',
        email: 'invalid-email',
        password: '123',
      );

      expect(result, Left(ServerFailure('Validation failed')));
      verify(mockRepository.register(
        fullName: '',
        email: 'invalid-email',
        username: null,
        password: '123',
        phoneNumber: null,
        role: null,
      )).called(1);
    });
  });
}
