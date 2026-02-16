import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contact_entity.dart';

abstract class ContactRepository {
  Future<Either<Failure, ContactEntity>> createContact({
    required String subject,
    required String message,
    required String category,
    int? rating,
  });
  Future<Either<Failure, List<ContactEntity>>> getMyContacts();
  Future<Either<Failure, List<ContactEntity>>> getTestimonials({int? limit});
}
