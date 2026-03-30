import 'package:get_it/get_it.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/repository_impl.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/usecases.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/child/child_bloc.dart';
import '../../presentation/bloc/vaccine/vaccine_bloc.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  // ─── Data Sources ───────────────────────────────────────────
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSource());

  // ─── Repositories ───────────────────────────────────────────
  sl.registerLazySingleton<ChildRepository>(() => ChildRepositoryImpl(sl()));
  sl.registerLazySingleton<VaccineRepository>(
    () => VaccineRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );
  sl.registerLazySingleton<RecordRepository>(() => RecordRepositoryImpl());

  // ─── Use Cases ──────────────────────────────────────────────
  sl.registerLazySingleton(() => GetChildrenUseCase(sl()));
  sl.registerLazySingleton(() => GetChildByIdUseCase(sl()));
  sl.registerLazySingleton(() => AddChildUseCase(sl()));
  sl.registerLazySingleton(() => GetVaccineScheduleUseCase(sl()));
  sl.registerLazySingleton(() => RecordVaccineUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // ─── BLoCs ──────────────────────────────────────────────────
  sl.registerFactory(() => AuthBloc());
  sl.registerFactory(
    () => ChildBloc(getChildren: sl(), getChildById: sl(), addChild: sl()),
  );
  sl.registerFactory(() => VaccineBloc(getSchedule: sl(), recordVaccine: sl()));
}
