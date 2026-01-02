import 'package:flutter/material.dart';
import 'package:hamro_service/features/auth/presentation/pages/login_page.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

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

                        // Title
                        Text(
                          'Select a Role',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                        ),

                        const SizedBox(height: 60),

                        // User Card
                        _RoleCard(
                          title: 'User',
                          description:
                              'To place any type of order to search for a performer',
                          imagePath: 'assets/images/user.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Service Provider Card
                        _RoleCard(
                          title: 'Service Provider',
                          description:
                              'Search and execute orders in your field of activity',
                          imagePath: 'assets/images/service_provider.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 60),

                        // Skip and Start Link
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Skip and Start',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 140,
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
          child: Stack(
            children: [
              // Content Section (Left Side)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 24, right: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),

              // Image Section (Right Side with Overlap)
              Positioned(
                right: -20,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).dividerColor,
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
