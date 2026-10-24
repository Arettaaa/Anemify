import 'package:get_it/get_it.dart';

import '../../features/scan/data/repositories/scan_repository_impl.dart';
import '../../features/scan/domain/repositories/scan_repository.dart';
import '../../features/scan/domain/usecases/classify_anemia_risk.dart';
import '../../features/scan/presentation/bloc/scan_bloc.dart';

final sl = GetIt.instance;

void setupInjection() {
  sl.registerLazySingleton<ScanRepository>(() => ScanRepositoryImpl());
  sl.registerLazySingleton(() => ClassifyAnemiaRisk(sl()));
  sl.registerFactory(() => ScanBloc(repository: sl(), classify: sl()));
}