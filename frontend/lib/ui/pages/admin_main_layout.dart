import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_state.dart';

import 'admin_dashboard_page.dart';
import 'lokomotif_list_page.dart';
import 'sensus_feed_page.dart';
import 'admin_reports_page.dart';
import 'profile_page.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AdminDashboardPage(
        onNavigateToReports: () {
          setState(() {
            _currentIndex = 3;
          });
        },
      ),
      const LokomotifListPage(),
      const SensusFeedPage(),
      const AdminReportsPage(),
      const ProfilePage(),
    ];

    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFF153D77),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF153D77),
                    fontFamily: 'Plus Jakarta Sans',
                  );
                }
                return const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontFamily: 'Plus Jakarta Sans',
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) =>
                  setState(() => _currentIndex = index),
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.1),
              height: 65,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, color: Color(0xFF94A3B8)),
                  selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.train_outlined, color: Color(0xFF94A3B8)),
                  selectedIcon: Icon(Icons.train_outlined, color: Colors.white),
                  label: 'Sarana',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined, color: Color(0xFF94A3B8)),
                  selectedIcon: Icon(Icons.assignment_outlined, color: Colors.white),
                  label: 'Sensus',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_shared_outlined, color: Color(0xFF94A3B8)),
                  selectedIcon: Icon(Icons.folder_shared_outlined, color: Colors.white),
                  label: 'Laporan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                  selectedIcon: Icon(Icons.person_outline, color: Colors.white),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ));
  }
}
