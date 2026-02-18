import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/features/booking/presentation/widgets/edit_booking_dialog.dart';
import 'package:hamro_service/features/booking/data/models/booking_model.dart';
import 'package:hamro_service/features/booking/presentation/providers/booking_provider.dart';
import 'package:hamro_service/features/booking/domain/repositories/booking_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([BookingRepository])
import 'edit_booking_dialog_test.mocks.dart';

void main() {
  group('EditBookingDialog Widget Tests', () {
    final testBooking = BookingModel(
      id: '1',
      userId: 'user1',
      serviceId: 'service1',
      date: '2024-01-15',
      timeSlot: '13:00',
      area: 'Test Area',
      status: 'PENDING',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      service: {
        'id': 'service1',
        'name': 'Test Service',
      },
    );

    testWidgets('should display edit booking dialog correctly', (WidgetTester tester) async {
      final mockRepository = MockBookingRepository();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditBookingDialog(booking: testBooking),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Booking'), findsOneWidget);
      expect(find.text('Test Area'), findsOneWidget);
    });

    testWidgets('should validate form fields', (WidgetTester tester) async {
      final mockRepository = MockBookingRepository();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditBookingDialog(booking: testBooking),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please select a date'), findsNothing);
    });

    testWidgets('should close dialog on cancel', (WidgetTester tester) async {
      final mockRepository = MockBookingRepository();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditBookingDialog(booking: testBooking),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Booking'), findsNothing);
    });
  });
}
