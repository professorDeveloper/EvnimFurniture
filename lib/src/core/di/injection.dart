import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

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

import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Home
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));

  sl.registerFactory(() => HomeBloc(useCase: sl()));

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
}
