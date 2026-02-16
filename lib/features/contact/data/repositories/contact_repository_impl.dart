import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_remote_datasource.dart';
import '../models/contact_model.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  ContactRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, ContactEntity>> createContact({
    required String subject,
    required String message,
    required String category,
    int? rating,
  }) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final contact = await remoteDataSource.createContact(
        subject: subject,
        message: message,
        category: category,
        rating: rating,
      );
      return Right(contact.toEntity());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to create contact: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ContactEntity>>> getMyContacts() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final contacts = await remoteDataSource.getMyContacts();
      return Right(contacts.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch contacts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ContactEntity>>> getTestimonials({int? limit}) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final testimonials = await remoteDataSource.getTestimonials(limit: limit);
      return Right(testimonials.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch testimonials: ${e.toString()}'));
    }
  }
}
