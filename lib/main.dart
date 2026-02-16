import 'package:hamro_service/app/app.dart';
import 'package:hamro_service/core/network/dio_client.dart';
import 'package:hamro_service/core/providers/shared_prefs_provider.dart';
import 'package:hamro_service/core/services/connectivity/connectivity_service.dart';
import 'package:hamro_service/core/services/hive/hive_service.dart';
import 'package:hamro_service/core/services/storage/user_session_service.dart';
import 'package:hamro_service/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:hamro_service/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:hamro_service/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hamro_service/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hamro_service/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:hamro_service/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:hamro_service/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hamro_service/features/home/data/datasources/home_local_datasource.dart';
import 'package:hamro_service/features/home/data/datasources/home_remote_datasource.dart';
import 'package:hamro_service/features/home/data/repositories/home_repository_impl.dart';
import 'package:hamro_service/features/services/data/datasources/services_local_datasource.dart';
import 'package:hamro_service/features/services/data/datasources/services_remote_datasource.dart';
import 'package:hamro_service/features/services/data/repositories/services_repository_impl.dart';
import 'package:hamro_service/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:hamro_service/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:hamro_service/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:hamro_service/features/provider/data/datasources/provider_local_datasource.dart';
import 'package:hamro_service/features/provider/data/datasources/provider_remote_datasource.dart';
import 'package:hamro_service/features/provider/data/repositories/provider_repository_impl.dart';
import 'package:hamro_service/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:hamro_service/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:hamro_service/features/payment/presentation/providers/payment_provider.dart';
import 'package:hamro_service/features/provider/data/datasources/provider_verification_remote_datasource.dart';
import 'package:hamro_service/features/provider/data/repositories/provider_verification_repository_impl.dart';
import 'package:hamro_service/features/provider/presentation/providers/provider_verification_provider.dart';
import 'package:hamro_service/features/provider/data/datasources/provider_availability_remote_datasource.dart';
import 'package:hamro_service/features/provider/data/repositories/availability_repository_impl.dart';
import 'package:hamro_service/features/provider/presentation/providers/availability_provider.dart';
import 'package:hamro_service/features/contact/data/datasources/contact_remote_datasource.dart';
import 'package:hamro_service/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:hamro_service/features/contact/presentation/providers/contact_provider.dart';
import 'package:hamro_service/features/home/presentation/providers/home_dashboard_provider.dart';
import 'package:hamro_service/features/services/presentation/providers/services_list_provider.dart';
import 'package:hamro_service/features/booking/presentation/providers/booking_provider.dart';
import 'package:hamro_service/features/provider/presentation/providers/provider_dashboard_provider.dart';
import 'package:hamro_service/data/data_sources/remote/image_upload_api.dart';
import 'package:hamro_service/data/repositories/image_repository_impl.dart';
import 'package:hamro_service/features/profile/presentation/viewmodel/profile_viewmodel.dart';
import 'package:hamro_service/features/profile/presentation/providers/image_upload_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  final sharedPreferences = await SharedPreferences.getInstance();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWith(
            (ref) => Future.value(sharedPreferences),
          ),
          authRepositoryProvider.overrideWith(
            (ref) {
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final connectivityService = ConnectivityService();
              final dioClient = DioClient(session: sessionService);
              final remoteDatasource = AuthRemoteDatasource(dio: dioClient.dio);
              final localDatasource = AuthLocalDatasource(
                sessionService: sessionService,
              );
              return AuthRepositoryImpl(
                localDatasource: localDatasource,
                remoteDatasource: remoteDatasource,
                sessionService: sessionService,
                connectivityService: connectivityService,
              );
            },
          ),
          profileRepositoryProvider.overrideWith(
            (ref) {
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final connectivityService = ConnectivityService();
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = ProfileRemoteDataSourceImpl(dio: dioClient.dio);
              final localDatasource = ProfileLocalDatasource();
              return ProfileRepositoryImpl(
                remoteDataSource: remoteDataSource,
                localDatasource: localDatasource,
                sessionService: sessionService,
                connectivityService: connectivityService,
              );
            },
          ),
          imageRepositoryProvider.overrideWith(
            (ref) {
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final api = ImageUploadApi(dio: dioClient.dio);
              return ImageRepositoryImpl(api: api);
            },
          ),
          homeRepositoryProvider.overrideWith(
            (ref) {
              final connectivityService = ConnectivityService();
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = HomeRemoteDataSourceImpl(dio: dioClient.dio);
              final localDataSource = HomeLocalDataSourceImpl();
              return HomeRepositoryImpl(
                remoteDataSource: remoteDataSource,
                localDataSource: localDataSource,
                connectivityService: connectivityService,
              );
            },
          ),
          servicesRepositoryProvider.overrideWith(
            (ref) {
              final connectivityService = ConnectivityService();
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = ServicesRemoteDataSourceImpl(dio: dioClient.dio);
              final localDataSource = ServicesLocalDataSourceImpl();
              return ServicesRepositoryImpl(
                remoteDataSource: remoteDataSource,
                localDataSource: localDataSource,
                connectivityService: connectivityService,
              );
            },
          ),
          bookingRepositoryProvider.overrideWith(
            (ref) {
              final connectivityService = ConnectivityService();
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = BookingRemoteDataSourceImpl(dio: dioClient.dio);
              final localDataSource = BookingLocalDataSourceImpl();
              final servicesRemoteDataSource = ServicesRemoteDataSourceImpl(dio: dioClient.dio);
              return BookingRepositoryImpl(
                remoteDataSource: remoteDataSource,
                localDataSource: localDataSource,
                connectivityService: connectivityService,
                servicesRemoteDataSource: servicesRemoteDataSource,
              );
            },
          ),
          providerRepositoryProvider.overrideWith(
            (ref) {
              final connectivityService = ConnectivityService();
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = ProviderRemoteDataSourceImpl(dio: dioClient.dio);
              final localDataSource = ProviderLocalDataSourceImpl();
              return ProviderRepositoryImpl(
                remoteDataSource: remoteDataSource,
                localDataSource: localDataSource,
                connectivityService: connectivityService,
              );
            },
          ),
          paymentRepositoryProvider.overrideWith(
            (ref) {
              final connectivityService = ConnectivityService();
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = PaymentRemoteDataSourceImpl(dio: dioClient.dio);
              return PaymentRepositoryImpl(
                remoteDataSource: remoteDataSource,
                connectivityService: connectivityService,
              );
            },
          ),
          providerVerificationRepositoryProvider.overrideWith(
            (ref) {
              final connectivityService = ConnectivityService();
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = ProviderVerificationRemoteDataSourceImpl(dio: dioClient.dio);
              return ProviderVerificationRepositoryImpl(
                remoteDataSource: remoteDataSource,
                connectivityService: connectivityService,
              );
            },
          ),
          availabilityRepositoryProvider.overrideWith(
            (ref) {
              final connectivityService = ConnectivityService();
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = ProviderAvailabilityRemoteDataSourceImpl(dio: dioClient.dio);
              return AvailabilityRepositoryImpl(
                remoteDataSource: remoteDataSource,
                connectivityService: connectivityService,
              );
            },
          ),
          contactRepositoryProvider.overrideWith(
            (ref) {
              final connectivityService = ConnectivityService();
              final sessionService = UserSessionService(prefs: sharedPreferences);
              final dioClient = DioClient(session: sessionService);
              final remoteDataSource = ContactRemoteDataSourceImpl(dio: dioClient.dio);
              return ContactRepositoryImpl(
                remoteDataSource: remoteDataSource,
                connectivityService: connectivityService,
              );
            },
          ),
        ],
        child: const App(),
      ),
    );
  });
}
