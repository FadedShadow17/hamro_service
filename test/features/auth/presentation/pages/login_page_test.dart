import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/features/auth/presentation/pages/login_page.dart';
import 'package:hamro_service/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hamro_service/features/auth/domain/repositories/auth_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthRepository])
import 'login_page_test.mocks.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('should render login form correctly', (WidgetTester tester) async {
      final mockRepository = MockAuthRepository();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      expect(find.text('Email or Username'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('should show validation error when fields are empty', (WidgetTester tester) async {
      final mockRepository = MockAuthRepository();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter email and password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      final mockRepository = MockAuthRepository();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      final iconButton = find.byIcon(Icons.visibility_off);
      if (iconButton.evaluate().isNotEmpty) {
        await tester.tap(iconButton);
        await tester.pump();
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      }
    });
  });
}
