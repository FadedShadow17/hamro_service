import 'package:flutter/material.dart';
import 'package:hamro_service/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hamro_service/features/provider/presentation/pages/provider_dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';

class RolePage extends StatelessWidget {
  const RolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFFF5F7FA),
                    const Color(0xFFE8ECF1),
                    const Color(0xFFDDE4EA),
                  ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        Text(
                          'Select a Role',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                        ),

                        const SizedBox(height: 60),

                        _RoleCard(
                          title: 'User',
                          description: 'Book services and find professionals',
                          icon: Icons.person_rounded,
                          iconColor: AppColors.primaryBlue,
                          gradientColors: [
                            AppColors.primaryBlue.withValues(alpha: 0.1),
                            AppColors.primaryBlue.withValues(alpha: 0.05),
                          ],
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const DashboardPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        _RoleCard(
                          title: 'Service Provider',
                          description: 'Offer your services and manage orders',
                          icon: Icons.work_rounded,
                          iconColor: AppColors.accentOrange,
                          gradientColors: [
                            AppColors.accentOrange.withValues(alpha: 0.1),
                            AppColors.accentOrange.withValues(alpha: 0.05),
                          ],
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const ProviderDashboardPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 128,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Premium Icon Container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.iconColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 40,
                        color: widget.iconColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
