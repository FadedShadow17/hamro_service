import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/provider_local_datasource.dart';
import '../../data/repositories/provider_repository_impl.dart';
import '../../domain/usecases/get_provider_dashboard_data.dart';

export '../../domain/usecases/get_provider_dashboard_data.dart';

final providerLocalDataSourceProvider = Provider<ProviderLocalDataSource>((ref) {
  return ProviderLocalDataSourceImpl();
});

final providerRepositoryProvider = Provider<ProviderRepositoryImpl>((ref) {
  final datasource = ref.watch(providerLocalDataSourceProvider);
  return ProviderRepositoryImpl(localDataSource: datasource);
});

final getProviderDashboardDataProvider = Provider<GetProviderDashboardData>((ref) {
  final repository = ref.watch(providerRepositoryProvider);
  return GetProviderDashboardData(repository);
});

final providerDashboardDataProvider = FutureProvider<ProviderDashboardData>((ref) async {
  final useCase = ref.watch(getProviderDashboardDataProvider);
  return await useCase();
});
