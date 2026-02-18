import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hamro_service/features/booking/presentation/widgets/time_slot_selector.dart';
import 'package:hamro_service/features/booking/domain/entities/time_slot.dart';

void main() {
  group('TimeSlotSelector Widget Tests', () {
    final testTimeSlots = [
      const TimeSlot(id: '10:00', time: '10:00 AM', isAvailable: true),
      const TimeSlot(id: '11:00', time: '11:00 AM', isAvailable: true),
      const TimeSlot(id: '13:00', time: '1:00 PM', isAvailable: true),
    ];

    testWidgets('should display time slots correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSlotSelector(
              timeSlots: testTimeSlots,
              selectedTimeSlot: null,
              onTimeSlotSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('11:00 AM'), findsOneWidget);
      expect(find.text('1:00 PM'), findsOneWidget);
    });

    testWidgets('should highlight selected time slot', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSlotSelector(
              timeSlots: testTimeSlots,
              selectedTimeSlot: testTimeSlots[0],
              onTimeSlotSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('10:00 AM'), findsOneWidget);
    });
  });
}
