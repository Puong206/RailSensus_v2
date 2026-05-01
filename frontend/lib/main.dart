import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:railsensus/data/repositories/laporan_hapus_repository.dart';

import 'data/providers/api_provider.dart';
import 'data/providers/storage_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lokomotif_repository.dart';
import 'data/repositories/sensus_repository.dart';
import 'data/repositories/laporan_hapus_sensus_repository.dart';
import 'data/repositories/admin_master_repository.dart';
import 'logic/bloc/auth/auth_bloc.dart';
import 'logic/bloc/auth/auth_event.dart';
import 'logic/bloc/sensus/sensus_bloc.dart';
import 'logic/bloc/lokomotif/lokomotif_bloc.dart';
import 'logic/bloc/admin_master/admin_master_bloc.dart';
import 'logic/debug/bloc_observer.dart';
import 'ui/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  Bloc.observer = AppBlocObserver();

  final storageProvider = StorageProvider();
  final apiProvider = ApiProvider(storageProvider);

  final authRepository = AuthRepository(
      apiProvider: apiProvider, storageProvider: storageProvider);
  final lokomotifRepository = LokomotifRepository(apiProvider: apiProvider);
  final sensusRepository = SensusRepository(apiProvider: apiProvider);
  final laporanHapusRepository =
      LaporanHapusRepository(apiProvider: apiProvider);
  final laporanHapusSensusRepository =
      LaporanHapusSensusRepository(apiProvider: apiProvider);
  final adminMasterRepository = AdminMasterRepository(apiProvider: apiProvider);

  runApp(MyApp(
    authRepository: authRepository,
    lokomotifRepository: lokomotifRepository,
    sensusRepository: sensusRepository,
    laporanHapusRepository: laporanHapusRepository,
    laporanHapusSensusRepository: laporanHapusSensusRepository,
    adminMasterRepository: adminMasterRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final LokomotifRepository lokomotifRepository;
  final SensusRepository sensusRepository;
  final LaporanHapusRepository laporanHapusRepository;
  final LaporanHapusSensusRepository laporanHapusSensusRepository;
  final AdminMasterRepository adminMasterRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.lokomotifRepository,
    required this.sensusRepository,
    required this.laporanHapusRepository,
    required this.laporanHapusSensusRepository,
    required this.adminMasterRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: lokomotifRepository),
        RepositoryProvider.value(value: sensusRepository),
        RepositoryProvider.value(value: laporanHapusRepository),
        RepositoryProvider.value(value: laporanHapusSensusRepository),
        RepositoryProvider.value(value: adminMasterRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository)
              ..add(AuthCheckRequested()),
          ),
          BlocProvider<SensusBloc>(
            create: (context) => SensusBloc(sensusRepository: sensusRepository),
          ),
          BlocProvider<LokomotifBloc>(
            create: (context) =>
                LokomotifBloc(lokomotifRepository: lokomotifRepository),
          ),
          BlocProvider<AdminMasterBloc>(
            create: (context) =>
                AdminMasterBloc(adminMasterRepository: adminMasterRepository),
          ),
        ],
        child: MaterialApp.router(
          title: 'RailSensus',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF153D77),
              primary: const Color(0xFF153D77),
              secondary: const Color(0xFFFF9428),
              surface: Colors.white,
              error: const Color(0xFFEF4444),
            ),
            fontFamily: 'PlusJakartaSans',
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF153D77),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
          ),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
