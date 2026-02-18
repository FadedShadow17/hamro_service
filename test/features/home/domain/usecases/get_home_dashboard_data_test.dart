import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_service/core/error/failures.dart';
import 'package:hamro_service/features/home/domain/entities/popular_service.dart';
import 'package:hamro_service/features/home/domain/entities/service_category.dart';
import 'package:hamro_service/features/home/domain/repositories/home_repository.dart';
import 'package:hamro_service/features/home/domain/usecases/get_home_dashboard_data.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([HomeRepository])
import 'get_home_dashboard_data_test.mocks.dart';

void main() {
  late GetHomeDashboardData usecase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = GetHomeDashboardData(mockRepository);
  });

  final testMostBookedServices = [
    const ServiceCategory(
      id: '1',
      name: 'Cleaning',
      iconKey: 'cleaning',
    ),
    const ServiceCategory(
      id: '2',
      name: 'Plumbing',
      iconKey: 'plumbing',
    ),
  ];

  final testPopularServices = [
    const PopularService(
      id: '1',
      title: 'House Cleaning',
      priceRs: 1000,
      categoryTag: 'Cleaning',
    ),
    const PopularService(
      id: '2',
      title: 'Pipe Repair',
      priceRs: 1500,
      categoryTag: 'Plumbing',
    ),
  ];

  group('GetHomeDashboardData', () {
    test('should return HomeDashboardData when both requests are successful', () async {
      when(mockRepository.getMostBookedServices())
          .thenAnswer((_) async => Right(testMostBookedServices));
      when(mockRepository.getPopularServices())
          .thenAnswer((_) async => Right(testPopularServices));

      final result = await usecase.call();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          expect(data.mostBookedServices, testMostBookedServices);
          expect(data.popularServices, testPopularServices);
        },
      );
      verify(mockRepository.getMostBookedServices()).called(1);
      verify(mockRepository.getPopularServices()).called(1);
    });

    test('should return Failure when getMostBookedServices fails', () async {
      when(mockRepository.getMostBookedServices())
          .thenAnswer((_) async => Left(ServerFailure('Server error')));
      when(mockRepository.getPopularServices())
          .thenAnswer((_) async => Right(testPopularServices));

      final result = await usecase.call();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, ServerFailure('Server error')),
        (data) => fail('Should not return data'),
      );
      verify(mockRepository.getMostBookedServices()).called(1);
      verifyNever(mockRepository.getPopularServices());
    });

    test('should return Failure when getPopularServices fails', () async {
      when(mockRepository.getMostBookedServices())
          .thenAnswer((_) async => Right(testMostBookedServices));
      when(mockRepository.getPopularServices())
          .thenAnswer((_) async => Left(ServerFailure('Server error')));

      final result = await usecase.call();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, ServerFailure('Server error')),
        (data) => fail('Should not return data'),
      );
      verify(mockRepository.getMostBookedServices()).called(1);
      verify(mockRepository.getPopularServices()).called(1);
    });
  });
}
