import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_option.dart';
import '../entities/time_slot.dart';
import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<List<ServiceOption>> getServiceOptions(String serviceId, String categoryTag);
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date);
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlotsFromAPI({
    required String serviceId,
    required String date,
    required String area,
  });
  Future<Either<Failure, BookingModel>> createBooking({
    required String serviceId,
    required String date,
    required String timeSlot,
    required String area,
  });
  Future<Either<Failure, List<BookingModel>>> getMyBookings({String? status});
  Future<Either<Failure, BookingModel>> cancelBooking(String bookingId);
  Future<Either<Failure, List<BookingModel>>> getProviderBookings({String? status});
  Future<Either<Failure, BookingModel>> acceptBooking(String bookingId);
  Future<Either<Failure, BookingModel>> declineBooking(String bookingId);
  Future<Either<Failure, BookingModel>> completeBooking(String bookingId);
  Future<Either<Failure, BookingModel>> updateBookingStatus(String bookingId, String status);
}
