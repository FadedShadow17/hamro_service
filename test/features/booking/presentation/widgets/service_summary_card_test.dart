import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hamro_service/features/booking/presentation/widgets/service_summary_card.dart';

void main() {
  group('ServiceSummaryCard Widget Tests', () {
    testWidgets('should display service summary card correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceSummaryCard(
              serviceName: 'House Cleaning',
              price: 1000.0,
              duration: '2 hours',
            ),
          ),
        ),
      );

      expect(find.text('House Cleaning'), findsOneWidget);
      expect(find.text('Rs. 1000 - 2 hours'), findsOneWidget);
    });

    testWidgets('should display price with correct formatting', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceSummaryCard(
              serviceName: 'Test Service',
              price: 1500.5,
              duration: '3 hours',
            ),
          ),
        ),
      );

      expect(find.text('Rs. 1500 - 3 hours'), findsOneWidget);
    });
  });
}
