import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_home_dashboard_data.dart';

export '../../domain/usecases/get_home_dashboard_data.dart';

final homeRepositoryProvider = Provider<HomeRepositoryImpl>((ref) {
  throw UnimplementedError('homeRepositoryProvider must be overridden');
});

final getHomeDashboardDataProvider = Provider<GetHomeDashboardData>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetHomeDashboardData(repository);
});

final homeDashboardDataProvider = FutureProvider<HomeDashboardData>((ref) async {
  final useCase = ref.watch(getHomeDashboardDataProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});
