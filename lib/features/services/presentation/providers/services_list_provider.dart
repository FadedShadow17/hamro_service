import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/usecases/get_services_by_category.dart';
import '../../domain/entities/service_item.dart';

final servicesRepositoryProvider = Provider<ServicesRepositoryImpl>((ref) {
  throw UnimplementedError('servicesRepositoryProvider must be overridden');
});

final getServicesByCategoryProvider = Provider<GetServicesByCategory>((ref) {
  final repository = ref.watch(servicesRepositoryProvider);
  return GetServicesByCategory(repository);
});

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

final servicesListProvider = FutureProvider.family<ServicesScreenState, String>((ref, category) async {
  final getServices = ref.read(getServicesByCategoryProvider);

  final result = await getServices(category);

  final categories = ['All', 'Plumbing', 'Cleaning', 'Electrician', 'Carpenter', 'Painter', 'Mason', 'Welder', 'Roofer', 'Pest Controller', 'More'];

  return result.fold(
    (failure) => ServicesScreenState(
      selectedCategory: category,
      categories: categories,
      services: [],
    ),
    (services) => ServicesScreenState(
      selectedCategory: category,
      categories: categories,
      services: services,
    ),
  );
});
