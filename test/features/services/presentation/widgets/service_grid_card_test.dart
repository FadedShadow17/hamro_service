import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/features/services/presentation/widgets/service_grid_card.dart';
import 'package:hamro_service/features/services/domain/entities/service_item.dart';

void main() {
  group('ServiceGridCard Widget Tests', () {
    const testService = ServiceItem(
      id: '1',
      title: 'House Cleaning',
      priceRs: 1000.0,
      rating: 4.5,
      reviewsCount: 100,
      categoryTag: 'Cleaning',
    );

    testWidgets('should render service grid card correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ServiceGridCard(
                service: testService,
              ),
            ),
          ),
        ),
      );

      expect(find.text('House Cleaning'), findsOneWidget);
      expect(find.text('Rs 1000'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ServiceGridCard(
                service: testService,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('should display correct category icon for cleaning service', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ServiceGridCard(
                service: testService,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cleaning_services), findsWidgets);
    });
  });
}
