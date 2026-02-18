import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hamro_service/features/home/presentation/widgets/stats_card.dart';

void main() {
  group('StatsCard Widget Tests', () {
    testWidgets('should display stats card correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Active Bookings',
              value: 5,
              icon: Icons.event_note,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('Active Bookings'), findsOneWidget);
      expect(find.byIcon(Icons.event_note), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Test',
              value: 10,
              icon: Icons.star,
              color: Colors.red,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(tapped, true);
    });
  });
}
