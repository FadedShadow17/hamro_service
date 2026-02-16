import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/services_list_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/service_item_card.dart';
import '../../../booking/presentation/screens/booking_screen.dart';

class ServicesByCategoryScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const ServicesByCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<ServicesByCategoryScreen> createState() => _ServicesByCategoryScreenState();
}

class _ServicesByCategoryScreenState extends ConsumerState<ServicesByCategoryScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryName;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final servicesState = ref.watch(servicesListProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Most Popular Services',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: servicesState.when(
        data: (state) => _buildContent(context, ref, state, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ServicesScreenState state,
    bool isDark,
  ) {
    return Column(
      children: [
        CategoryChips(
          categories: state.categories,
          selectedCategory: state.selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
        Expanded(
          child: state.services.isEmpty
              ? Center(
                  child: Text(
                    'No services available',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.services.length,
                  itemBuilder: (context, index) {
                    final service = state.services[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ServiceItemCard(
                        service: service,
                        onViewProfile: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('View Profile - Coming soon')),
                          );
                        },
                        onBookNow: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BookingScreen(
                                service: service,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
