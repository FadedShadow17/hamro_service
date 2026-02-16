import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/provider_repository_impl.dart';
import '../../domain/usecases/get_provider_dashboard_data.dart';

export '../../domain/usecases/get_provider_dashboard_data.dart';

final providerRepositoryProvider = Provider<ProviderRepositoryImpl>((ref) {
  throw UnimplementedError('providerRepositoryProvider must be overridden');
});

final getProviderDashboardDataProvider = Provider<GetProviderDashboardData>((ref) {
  final repository = ref.watch(providerRepositoryProvider);
  return GetProviderDashboardData(repository);
});

final providerDashboardDataProvider = FutureProvider<ProviderDashboardData>((ref) async {
  final useCase = ref.watch(getProviderDashboardDataProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});
