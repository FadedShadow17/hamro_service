import 'package:hamro_service/app/app.dart';
import 'package:hamro_service/core/providers/shared_prefs_provider.dart';
import 'package:hamro_service/core/services/hive/hive_service.dart';
import 'package:hamro_service/core/services/storage/user_session_service.dart';
import 'package:hamro_service/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:hamro_service/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hamro_service/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hamro_service/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:hamro_service/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hamro_service/features/profile/presentation/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive before runApp
  await HiveService.init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      ProviderScope(
        overrides: [
          // Override SharedPreferences provider
          sharedPrefsProvider.overrideWith(
            (ref) => Future.value(sharedPreferences),
          ),
          // Override AuthRepository provider
          authRepositoryProvider.overrideWith(
            (ref) {
              // Use the already-initialized SharedPreferences directly
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final datasource = AuthLocalDatasource(
                sessionService: sessionService,
              );
              return AuthRepositoryImpl(
                datasource: datasource,
                sessionService: sessionService,
              );
            },
          ),
          // Override ProfileRepository provider
          profileRepositoryProvider.overrideWith(
            (ref) {
              // Use the already-initialized SharedPreferences directly
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final datasource = ProfileLocalDatasource();
              return ProfileRepositoryImpl(
                datasource: datasource,
                sessionService: sessionService,
              );
            },
          ),
        ],
        child: const App(),
      ),
    );
  });
}
