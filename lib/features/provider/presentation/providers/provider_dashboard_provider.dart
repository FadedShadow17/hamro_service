import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/provider_repository_impl.dart';
import '../../domain/usecases/get_provider_dashboard_data.dart';
import '../../data/repositories/provider_verification_repository_impl.dart';
import '../../presentation/providers/provider_verification_provider.dart';

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

final providerVerificationStatusForDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(providerVerificationRepositoryProvider);
  final result = await repository.getVerificationSummary();
  return result.fold(
    (failure) => {'status': 'ERROR', 'error': failure.message},
    (summary) => summary,
  );
});
