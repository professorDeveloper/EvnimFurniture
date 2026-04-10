import 'package:get_it/get_it.dart';

import '../services/view_history_service.dart';
import '../../features/detail/data/datasources/detail_remote_datasource.dart';
import '../../features/detail/data/repositories/detail_repository_impl.dart';
import '../../features/detail/domain/repositories/detail_repository.dart';
import '../../features/detail/domain/usecases/get_detail_colors_usecase.dart';
import '../../features/detail/presentation/bloc/detail_bloc.dart';
import '../../features/home/domain/usecases/get_furniture_detail_usecase.dart';
import '../../features/home/domain/usecases/get_furniture_material_colors_usecase.dart';
import '../../features/home/domain/usecases/get_materials_furniture_usecase.dart';
import '../../features/materials/data/datasource/materials_remote_datasource.dart';
import '../../features/materials/data/repo/materials_repository_impl.dart';
import '../../features/materials/domain/repo/materials_repository.dart';
import '../../features/materials/domain/usecase/get_materials_usecase.dart';
import '../../features/materials/presentation/bloc/materials_bloc.dart';
import '../network/dio_client.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  // View history (Hive)
  final viewHistoryService = ViewHistoryService();
  await viewHistoryService.init();
  sl.registerSingleton<ViewHistoryService>(viewHistoryService);

  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ── Home feature ──
  sl.registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetMaterialFurnitureUseCase>(
        () => GetMaterialFurnitureUseCase(repository: sl<HomeRepository>()),
  );
  sl.registerLazySingleton<GetFurnitureDetailUseCase>(
        () => GetFurnitureDetailUseCase(repository: sl<HomeRepository>()),
  );
  sl.registerLazySingleton<GetFurnitureMaterialColorsUseCase>(
        () => GetFurnitureMaterialColorsUseCase(repository: sl<HomeRepository>()),
  );
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerFactory(() => HomeBloc(useCase: sl()));

  sl.registerLazySingleton<MaterialsRemoteDataSource>(
        () => MaterialsRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<MaterialsRepository>(
        () => MaterialsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(
        () => GetMaterialsUseCase(repository: sl<MaterialsRepository>()),
  );
  sl.registerFactory(
        () => MaterialsBloc(useCase: sl()),
  );

  // Detail feature
  sl.registerLazySingleton<DetailRemoteDataSource>(
        () => DetailRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<DetailRepository>(
        () => DetailRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(
        () => GetDetailColorsUseCase(repository: sl<DetailRepository>()),
  );
  sl.registerFactory(
        () => DetailBloc(useCase: sl()),
  );
}