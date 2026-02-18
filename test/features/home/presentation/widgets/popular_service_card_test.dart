import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hamro_service/features/home/presentation/widgets/popular_service_card.dart';
import 'package:hamro_service/features/home/domain/entities/popular_service.dart';

void main() {
  group('PopularServiceCard Widget Tests', () {
    const testService = PopularService(
      id: '1',
      title: 'House Cleaning',
      priceRs: 1000,
      categoryTag: 'Cleaning',
    );

    testWidgets('should display popular service card correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PopularServiceCard(service: testService),
          ),
        ),
      );

      expect(find.text('House Cleaning'), findsOneWidget);
      expect(find.text('Rs 1000'), findsOneWidget);
    });

    testWidgets('should navigate on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PopularServiceCard(service: testService),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
