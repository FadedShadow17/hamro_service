import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/services_local_datasource.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/usecases/get_services_by_category.dart';
import '../../domain/entities/service_item.dart';

/// Local data source provider
final servicesLocalDataSourceProvider = Provider<ServicesLocalDataSource>((ref) {
  return ServicesLocalDataSourceImpl();
});

/// Repository provider
final servicesRepositoryProvider = Provider<ServicesRepositoryImpl>((ref) {
  final datasource = ref.watch(servicesLocalDataSourceProvider);
  return ServicesRepositoryImpl(localDataSource: datasource);
});

/// Get services by category use case provider
final getServicesByCategoryProvider = Provider<GetServicesByCategory>((ref) {
  final repository = ref.watch(servicesRepositoryProvider);
  return GetServicesByCategory(repository);
});

/// Services screen state
class ServicesScreenState {
  final String selectedCategory;
  final List<String> categories;
  final List<ServiceItem> services;
  final bool isLoading;

  ServicesScreenState({
    required this.selectedCategory,
    required this.categories,
    required this.services,
    this.isLoading = false,
  });

  ServicesScreenState copyWith({
    String? selectedCategory,
    List<String>? categories,
    List<ServiceItem>? services,
    bool? isLoading,
  }) {
    return ServicesScreenState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Services list provider factory
final servicesListProvider = FutureProvider.family<ServicesScreenState, String>((ref, category) async {
  final getServices = ref.read(getServicesByCategoryProvider);

  final services = await getServices(category);

  final categories = ['All', 'Plumbing', 'Cleaning', 'Electrician', 'Carpenter', 'Painter', 'Mason', 'Welder', 'Roofer', 'Pest Controller'];

  return ServicesScreenState(
    selectedCategory: category,
    categories: categories,
    services: services,
  );
});
