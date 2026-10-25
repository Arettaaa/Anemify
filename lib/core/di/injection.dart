import 'package:get_it/get_it.dart';

import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/history_usecases.dart';
import '../../features/scan/data/repositories/scan_repository_impl.dart';
import '../../features/scan/domain/repositories/scan_repository.dart';
import '../../features/scan/domain/usecases/classify_anemia_risk.dart';
import '../../features/scan/presentation/bloc/scan_bloc.dart';

final sl = GetIt.instance;

void setupInjection() {
  // Scan
  sl.registerLazySingleton<ScanRepository>(() => ScanRepositoryImpl());
  sl.registerLazySingleton(() => ClassifyAnemiaRisk(sl()));
  sl.registerFactory(() => ScanBloc(repository: sl(), classify: sl()));

  // Riwayat skrining
  sl.registerLazySingleton(() => HistoryLocalDataSource());
  sl.registerLazySingleton<HistoryRepository>(() => HistoryRepositoryImpl(sl()));
  sl.registerFactory(() => SaveScanToHistory(sl()));
  sl.registerFactory(() => GetScanHistory(sl()));
  sl.registerFactory(() => GetHistoryEntry(sl()));
  sl.registerFactory(() => DeleteHistoryEntry(sl()));
  sl.registerFactory(() => ClearHistory(sl()));
}