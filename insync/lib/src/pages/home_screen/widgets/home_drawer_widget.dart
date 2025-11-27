import 'package:flutter/material.dart';
import 'package:insync/src/core/exntesions/build_context_extension.dart';
import 'package:insync/src/utils/nav/app_routes.dart';

class HomeDrawerWidget extends StatelessWidget {
  const HomeDrawerWidget({
    super.key,
    required this.username,
    required this.email,
    required this.onLogout,
    required this.onReloadPage,
  });

  final String username;
  final String email;
  final VoidCallback onLogout;
  final VoidCallback onReloadPage;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: context.colorScheme.primary,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: context.colorScheme.onPrimary,
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    username,
                    style: TextStyle(
                      color: context.colorScheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      email,
                      style: TextStyle(
                        color: context.colorScheme.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.home_rounded, color: context.colorScheme.onPrimary),
              ),
              title: Text(
                'Home',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.list_alt_rounded, color: context.colorScheme.onPrimary),
              ),
              title: Text(
                'Manage Habits',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onPrimary,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.of(context).pushNamed(AppRoutes.habitList);
                onReloadPage();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart_rounded, color: context.colorScheme.onPrimary),
              ),
              title: Text(
                'Insights',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onPrimary,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.of(context).pushNamed(AppRoutes.insights);
                onReloadPage();
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.logout_rounded, color: context.colorScheme.onPrimary),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: context.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: onLogout,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
