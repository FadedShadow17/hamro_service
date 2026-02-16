import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/domain/entities/service_item.dart';
import '../../../services/presentation/providers/services_list_provider.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final searchResultsProvider = FutureProvider<List<ServiceItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  if (query.isEmpty) {
    return [];
  }

  final servicesState = await ref.read(servicesListProvider('all').future);
  
  final searchTerm = query.toLowerCase();
  final filteredServices = servicesState.services.where((service) {
    return service.title.toLowerCase().contains(searchTerm);
  }).toList();

  return filteredServices;
});
