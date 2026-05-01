import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_state.dart';
import '../../data/models/lokomotif_model.dart';
import '../pages/splash_page.dart';
import '../pages/landing_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/main_layout.dart';
import '../pages/admin_main_layout.dart';
import '../pages/detail_sensus_page.dart';
import '../pages/form_sensus_page.dart';
import '../pages/lokomotif_form_page.dart';
import '../pages/detail_lokomotif_page.dart';
import '../pages/laporan_hapus_page.dart';
import '../pages/laporan_hapus_sensus_page.dart';
import '../pages/edit_profile_page.dart';
import '../pages/change_password_page.dart';
import '../pages/master_data/master_kereta_page.dart';
import '../pages/master_data/master_depo_page.dart';
import '../pages/master_data/master_users_page.dart';
import '../pages/admin_reports_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainLayout(),
    ),
    GoRoute(
      path: '/admin-main',
      builder: (context, state) => const AdminMainLayout(),
    ),
    GoRoute(
      path: '/sensus/detail/:id',
      builder: (context, state) => DetailSensusPage(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/sensus/form',
      builder: (context, state) => const FormSensusPage(),
    ),
    GoRoute(
      path: '/lokomotif/form',
      builder: (context, state) => LokomotifFormPage(
        lokomotif: state.extra as LokomotifModel?,
      ),
    ),
    GoRoute(
      path: '/lokomotif/detail/:id',
      builder: (context, state) => DetailLokomotifPage(
        data: state.extra as LokomotifModel,
      ),
    ),
    GoRoute(
      path: '/laporan-hapus',
      builder: (context, state) => const LaporanHapusPage(),
    ),
    GoRoute(
      path: '/laporan-hapus-sensus',
      builder: (context, state) => const LaporanHapusSensusPage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: '/admin/master-kereta',
      builder: (context, state) => const MasterKeretaPage(),
    ),
    GoRoute(
      path: '/admin/master-depo',
      builder: (context, state) => const MasterDepoPage(),
    ),
    GoRoute(
      path: '/admin/master-users',
      builder: (context, state) => const MasterUsersPage(),
    ),
    GoRoute(
      path: '/admin/reports',
      builder: (context, state) => const AdminReportsPage(),
    ),
  ],
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register' || state.matchedLocation == '/landing';
    
    if (authState is AuthInitial) return null; // Let splash handle it

    if (authState is AuthUnauthenticated) {
      if (state.matchedLocation == '/') return '/landing';
      if (!isGoingToAuth) return '/login';
    }

    if (authState is AuthAuthenticated) {
      final isAdmin = authState.user?.role == 'Admin';

      if (isGoingToAuth || state.matchedLocation == '/') {
        return isAdmin ? '/admin-main' : '/main';
      }

      // If user is not admin but tries to access admin-main, send to main
      if (!isAdmin && state.matchedLocation.startsWith('/admin')) {
        return '/main';
      }
      
      // If user is admin but tries to access main, send to admin-main
      if (isAdmin && state.matchedLocation == '/main') {
        return '/admin-main';
      }
    }

    return null;
  },
);
