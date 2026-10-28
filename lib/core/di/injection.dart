import 'package:get_it/get_it.dart';

import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/history_usecases.dart';
import '../../features/scan/data/repositories/scan_repository_impl.dart';
import '../../features/scan/domain/repositories/scan_repository.dart';
import '../../features/scan/domain/usecases/classify_anemia_risk.dart';
import '../../features/scan/presentation/bloc/scan_bloc.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/ttd/data/datasources/ttd_local_datasource.dart';
import '../../features/ttd/data/repositories/ttd_repository_impl.dart';
import '../../features/ttd/domain/repositories/ttd_repository.dart';
import '../../features/ttd/domain/usecases/ttd_usecases.dart';
final sl = GetIt.instance;

void setupInjection() {
    // Profile
  sl.registerLazySingleton(() => ProfileLocalDataSource());
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetProfiles(sl()));
  sl.registerLazySingleton(() => GetActiveProfile(sl()));
  sl.registerLazySingleton(() => AddProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => SetActiveProfile(sl()));

  // TTD
  sl.registerLazySingleton(() => TtdLocalDataSource(sl()));
  sl.registerLazySingleton<TtdRepository>(() => TtdRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetTtdSettings(sl()));
  sl.registerLazySingleton(() => SaveTtdSettings(sl()));
  sl.registerLazySingleton(() => GetTtdLogs(sl()));
  sl.registerLazySingleton(() => SetTtdTaken(sl()));
  sl.registerLazySingleton(() => const CalculateTtdStats());

  // Scan
  sl.registerLazySingleton<ScanRepository>(() => ScanRepositoryImpl());
  sl.registerLazySingleton(() => ClassifyAnemiaRisk(sl()));
  sl.registerFactory(() => ScanBloc(repository: sl(), classify: sl()));

  // Riwayat skrining
  sl.registerLazySingleton(() => HistoryLocalDataSource());
  sl.registerLazySingleton<HistoryRepository>(() => HistoryRepositoryImpl(sl(), sl()));  
  sl.registerFactory(() => SaveScanToHistory(sl()));
  sl.registerFactory(() => GetScanHistory(sl()));
  sl.registerFactory(() => GetHistoryEntry(sl()));
  sl.registerFactory(() => DeleteHistoryEntry(sl()));
  sl.registerFactory(() => ClearHistory(sl()));
}