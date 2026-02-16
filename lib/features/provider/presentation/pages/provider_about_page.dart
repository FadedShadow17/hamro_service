import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../data/repositories/provider_verification_repository_impl.dart';
import '../../presentation/providers/provider_verification_provider.dart';
import 'provider_verification_page.dart';
import '../../../auth/presentation/view_model/auth_viewmodel.dart';
import '../../../profile/presentation/viewmodel/profile_viewmodel.dart';

final verificationStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(providerVerificationRepositoryProvider);
  final result = await repository.getVerificationSummary();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (summary) => summary,
  );
});

class ProviderAboutPage extends ConsumerWidget {
  const ProviderAboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authViewModelProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final verificationStatusAsync = ref.watch(verificationStatusProvider);

    final name = profileState.profile?.fullName ?? authState.user?.fullName ?? 'Provider';
    final email = profileState.profile?.email ?? authState.user?.email ?? '';
    final role = authState.user?.role ?? 'provider';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text(
          'About',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.work,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role == 'provider' ? 'Service Provider' : 'User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Verification Status Section
              Text(
                'Verification Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              verificationStatusAsync.when(
                data: (summary) => _buildVerificationStatus(context, isDark, summary),
                loading: () => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Error loading verification status',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Profile Information
              Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context,
                      isDark,
                      Icons.person,
                      'Name',
                      name,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      isDark,
                      Icons.email,
                      'Email',
                      email,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStatus(BuildContext context, bool isDark, Map<String, dynamic> summary) {
    final status = summary['status'] as String? ?? 'NOT_SUBMITTED';
    final isApproved = status == 'APPROVED';
    final isRejected = status == 'REJECTED';
    final isPending = status == 'PENDING_REVIEW';

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    if (isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Verified';
      statusDescription = 'Your verification has been approved. You can now browse user requests.';
    } else if (isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'Pending Review';
      statusDescription = 'Your verification is under review. Please wait for approval.';
    } else if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Rejected';
      final rejectionReason = summary['rejectionReason'] as String?;
      statusDescription = rejectionReason != null
          ? 'Rejection reason: $rejectionReason'
          : 'Your verification was rejected. Please resubmit.';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info_outline;
      statusText = 'Not Verified';
      statusDescription = 'Please complete verification to browse user requests.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isApproved) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProviderVerificationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isRejected ? 'Resubmit Verification' : 'Complete Verification',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, bool isDark, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
