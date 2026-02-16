import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../domain/entities/contact_entity.dart';
import '../../presentation/providers/contact_provider.dart';

final testimonialsPageProvider = FutureProvider<List<ContactEntity>>((ref) async {
  final repository = ref.watch(contactRepositoryProvider);
  final result = await repository.getTestimonials(limit: 20);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (testimonials) => testimonials,
  );
});

class TestimonialsPage extends ConsumerWidget {
  const TestimonialsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final testimonialsAsync = ref.watch(testimonialsPageProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Testimonials',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: testimonialsAsync.when(
        data: (testimonials) {
          if (testimonials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No testimonials yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];
              return _TestimonialCard(
                subject: testimonial.subject,
                message: testimonial.message,
                rating: testimonial.rating,
                isDark: isDark,
              );
            },
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(testimonialsPageProvider),
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String subject;
  final String message;
  final int? rating;
  final bool isDark;

  const _TestimonialCard({
    required this.subject,
    required this.message,
    this.rating,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Text(
                  subject,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (rating != null)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating! ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
