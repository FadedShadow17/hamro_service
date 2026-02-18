import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hamro_service/features/booking/presentation/widgets/booking_status_badge.dart';
import 'package:hamro_service/core/constants/booking_status.dart';

void main() {
  group('BookingStatusBadge Widget Tests', () {
    testWidgets('should display PENDING status badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookingStatusBadge(status: BookingStatus.pending),
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('should display CONFIRMED status badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookingStatusBadge(status: BookingStatus.confirmed),
          ),
        ),
      );

      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('should display COMPLETED status badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookingStatusBadge(status: BookingStatus.completed),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('should display CANCELLED status badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookingStatusBadge(status: BookingStatus.cancelled),
          ),
        ),
      );

      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('should display compact badge when isCompact is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookingStatusBadge(
              status: BookingStatus.pending,
              isCompact: true,
            ),
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
    });
  });
}
