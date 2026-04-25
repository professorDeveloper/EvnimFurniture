import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../services/view_history_service.dart';
import '../../features/favourites/data/datasources/favourites_remote_datasource.dart';
import '../../features/favourites/data/repositories/favourites_repository_impl.dart';
import '../../features/favourites/domain/repositories/favourites_repository.dart';
import '../../features/favourites/domain/usecases/get_favourites_usecase.dart';
import '../../features/favourites/domain/usecases/remove_favourite_usecase.dart';
import '../../features/favourites/presentation/bloc/favourites_bloc.dart';
import '../../features/detail/data/datasources/detail_remote_datasource.dart';
import '../../features/detail/data/repositories/detail_repository_impl.dart';
import '../../features/detail/domain/repositories/detail_repository.dart';
import '../../features/detail/domain/usecases/get_detail_colors_usecase.dart';
import '../../features/detail/domain/usecases/get_my_rating_usecase.dart';
import '../../features/detail/domain/usecases/rate_furniture_material_usecase.dart';
import '../../features/detail/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/detail/domain/usecases/try_in_room_usecase.dart';
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

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/send_email_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_otp_usecase.dart';
import '../../features/auth/domain/usecases/get_me_usecase.dart';
import '../../features/auth/domain/usecases/complete_profile_usecase.dart';
import '../../features/auth/domain/usecases/edit_profile_usecase.dart';
import '../../features/auth/domain/usecases/social_login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/category/data/datasources/category_remote_datasource.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/get_categories_usecase.dart';
import '../../features/category/domain/usecases/get_category_furniture_usecase.dart';
import '../../features/category/presentation/bloc/categories_bloc.dart';
import '../../features/category/presentation/bloc/category_furniture_bloc.dart';

import '../../features/view_all/data/datasources/view_all_remote_datasource.dart';
import '../../features/view_all/data/repositories/view_all_repository_impl.dart';
import '../../features/view_all/domain/repositories/view_all_repository.dart';

import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  // View history (Hive)
  final viewHistoryService = ViewHistoryService();
  await viewHistoryService.init();
  sl.registerSingleton<ViewHistoryService>(viewHistoryService);

  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // ── Home feature ──
  // Home
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
  sl.registerFactory(() => HomeBloc(useCase: sl(), repository: sl<HomeRepository>()));

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
  sl.registerLazySingleton(
        () => GetMyRatingUseCase(repository: sl<DetailRepository>()),
  );
  sl.registerLazySingleton(
        () => RateFurnitureMaterialUseCase(repository: sl<DetailRepository>()),
  );
  sl.registerLazySingleton(
        () => TryInRoomUseCase(repository: sl<DetailRepository>()),
  );
  sl.registerLazySingleton(
        () => ToggleFavoriteUseCase(repository: sl<DetailRepository>()),
  );
  sl.registerFactory(
        () => DetailBloc(
          useCase: sl(),
          getMyRatingUseCase: sl(),
          rateFurnitureMaterialUseCase: sl(),
          tryInRoomUseCase: sl(),
          toggleFavoriteUseCase: sl(),
        ),
  );

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      firebaseAuth: sl(),
    ),
  );

  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl()));
  sl.registerLazySingleton(() => SendEmailOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailOtpUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));
  sl.registerLazySingleton(() => CompleteProfileUseCase(sl()));
  sl.registerLazySingleton(() => EditProfileUseCase(sl()));
  sl.registerLazySingleton(() => SocialLoginUseCase(sl()));

  sl.registerFactory(() => AuthBloc(
        sendOtpUseCase: sl(),
        verifyOtpUseCase: sl(),
        resendOtpUseCase: sl(),
        sendEmailOtpUseCase: sl(),
        verifyEmailOtpUseCase: sl(),
        getMeUseCase: sl(),
        completeProfileUseCase: sl(),
        editProfileUseCase: sl(),
        socialLoginUseCase: sl(),
        authRepository: sl(),
      ));

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));

  sl.registerFactory(() => NotificationBloc(useCase: sl()));

  // Category feature
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(
    () => GetCategoriesUseCase(repository: sl<CategoryRepository>()),
  );
  sl.registerLazySingleton(
    () => GetCategoryFurnitureUseCase(repository: sl<CategoryRepository>()),
  );
  sl.registerFactory(
    () => CategoriesBloc(useCase: sl()),
  );
  sl.registerFactory(
    () => CategoryFurnitureBloc(useCase: sl()),
  );

  // View All
  sl.registerLazySingleton<ViewAllRemoteDataSource>(
    () => ViewAllRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<ViewAllRepository>(
    () => ViewAllRepositoryImpl(remoteDataSource: sl()),
  );

  // Favourites
  sl.registerLazySingleton<FavouritesRemoteDataSource>(
    () => FavouritesRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<FavouritesRepository>(
    () => FavouritesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(
    () => GetFavouritesUseCase(repository: sl<FavouritesRepository>()),
  );
  sl.registerLazySingleton(
    () => RemoveFavouriteUseCase(repository: sl<FavouritesRepository>()),
  );
  sl.registerFactory(
    () => FavouritesBloc(
      getFavouritesUseCase: sl(),
      removeFavouriteUseCase: sl(),
    ),
  );
}
