import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/home_local_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_home_dashboard_data.dart';

export '../../domain/usecases/get_home_dashboard_data.dart';

/// Provider for HomeLocalDataSource
final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>((ref) {
  return HomeLocalDataSourceImpl();
});

/// Provider for HomeRepository
final homeRepositoryProvider = Provider<HomeRepositoryImpl>((ref) {
  final datasource = ref.watch(homeLocalDataSourceProvider);
  return HomeRepositoryImpl(localDataSource: datasource);
});

/// Provider for GetHomeDashboardData use case
final getHomeDashboardDataProvider = Provider<GetHomeDashboardData>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetHomeDashboardData(repository);
});

/// Provider for home dashboard data
final homeDashboardDataProvider = FutureProvider<HomeDashboardData>((ref) async {
  final useCase = ref.watch(getHomeDashboardDataProvider);
  return await useCase();
});
