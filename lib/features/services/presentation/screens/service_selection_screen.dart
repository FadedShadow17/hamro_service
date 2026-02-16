import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/services_list_provider.dart';
import '../widgets/service_item_card.dart';
import '../../../booking/presentation/screens/booking_screen.dart';

class ServiceSelectionScreen extends ConsumerWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final servicesState = ref.watch(servicesListProvider('all'));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Select a Service'),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
      ),
      body: servicesState.when(
        data: (state) {
          final services = state.services.take(10).toList();
          
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.miscellaneous_services_outlined,
                    size: 64,
                    color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No services available',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(servicesListProvider('all'));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
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
                          builder: (context) => BookingScreen(service: service),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? AppColors.textWhite50 : AppColors.textLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading services',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(servicesListProvider('all'));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
