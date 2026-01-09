import '../models/provider_order_model.dart';
import '../models/provider_stats_model.dart';

abstract class ProviderLocalDataSource {
  Future<ProviderStatsModel> getProviderStats();
  Future<List<ProviderOrderModel>> getPendingOrders();
  Future<List<ProviderOrderModel>> getActiveOrders();
  Future<List<ProviderOrderModel>> getRecentOrders();
}

class ProviderLocalDataSourceImpl implements ProviderLocalDataSource {
  @override
  Future<ProviderStatsModel> getProviderStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const ProviderStatsModel(
      totalOrders: 45,
      pendingOrders: 3,
      completedOrders: 38,
      totalEarnings: 125000,
      averageRating: 4.7,
      totalReviews: 32,
    );
  }

  @override
  Future<List<ProviderOrderModel>> getPendingOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    return [
      ProviderOrderModel(
        id: '1',
        customerName: 'John Doe',
        serviceName: 'Plumbing Repair',
        status: 'pending',
        priceRs: 1200,
        location: 'Kathmandu, Thamel',
        createdAt: now.subtract(const Duration(hours: 2)),
        scheduledDate: now.add(const Duration(days: 1)),
      ),
      ProviderOrderModel(
        id: '2',
        customerName: 'Jane Smith',
        serviceName: 'Electrical Installation',
        status: 'pending',
        priceRs: 2500,
        location: 'Kathmandu, Baneshwor',
        createdAt: now.subtract(const Duration(hours: 5)),
        scheduledDate: now.add(const Duration(days: 2)),
      ),
      ProviderOrderModel(
        id: '3',
        customerName: 'Mike Johnson',
        serviceName: 'Carpentry Work',
        status: 'pending',
        priceRs: 3500,
        location: 'Kathmandu, Patan',
        createdAt: now.subtract(const Duration(hours: 1)),
        scheduledDate: now.add(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Future<List<ProviderOrderModel>> getActiveOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    return [
      ProviderOrderModel(
        id: '4',
        customerName: 'Sarah Williams',
        serviceName: 'House Painting',
        status: 'in_progress',
        priceRs: 15000,
        location: 'Kathmandu, Lalitpur',
        createdAt: now.subtract(const Duration(days: 2)),
        scheduledDate: now,
      ),
      ProviderOrderModel(
        id: '5',
        customerName: 'David Brown',
        serviceName: 'Masonry Work',
        status: 'in_progress',
        priceRs: 8000,
        location: 'Kathmandu, Koteshwor',
        createdAt: now.subtract(const Duration(days: 1)),
        scheduledDate: now,
      ),
    ];
  }

  @override
  Future<List<ProviderOrderModel>> getRecentOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    return [
      ProviderOrderModel(
        id: '6',
        customerName: 'Emily Davis',
        serviceName: 'Welding Service',
        status: 'completed',
        priceRs: 4500,
        location: 'Kathmandu, Budhanilkantha',
        createdAt: now.subtract(const Duration(days: 3)),
        scheduledDate: now.subtract(const Duration(days: 3)),
      ),
      ProviderOrderModel(
        id: '7',
        customerName: 'Robert Wilson',
        serviceName: 'Roofing Repair',
        status: 'completed',
        priceRs: 12000,
        location: 'Kathmandu, Kalimati',
        createdAt: now.subtract(const Duration(days: 5)),
        scheduledDate: now.subtract(const Duration(days: 5)),
      ),
      ProviderOrderModel(
        id: '8',
        customerName: 'Lisa Anderson',
        serviceName: 'Pest Control',
        status: 'completed',
        priceRs: 3000,
        location: 'Kathmandu, Gongabu',
        createdAt: now.subtract(const Duration(days: 7)),
        scheduledDate: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
