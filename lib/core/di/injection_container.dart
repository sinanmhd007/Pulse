import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../network/network_info.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_in_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_in_up.dart' as sign_up_usecase;
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/news/data/datasources/news_local_data_source.dart';
import '../../features/news/data/datasources/news_remote_data_source.dart';
import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/repositories/news_repository.dart';
import '../../features/news/domain/usecases/get_live_news.dart';
import '../../features/news/domain/usecases/search_news.dart';
import '../../features/news/presentation/bloc/news_bloc.dart';

import '../../features/crypto/data/datasources/crypto_local_data_source.dart';
import '../../features/crypto/data/datasources/crypto_remote_data_source.dart';
import '../../features/crypto/data/repositories/crypto_repository_impl.dart';
import '../../features/crypto/domain/repositories/crypto_repository.dart';
import '../../features/crypto/domain/usecases/get_live_crypto_prices.dart';
import '../../features/crypto/domain/usecases/search_crypto.dart';
import '../../features/crypto/presentation/bloc/crypto_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(
        getCurrentUser: sl(),
        signIn: sl(),
        signUp: sl(),
        signInGoogle: sl(),
        signOut: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => sign_up_usecase.SignUp(sl()));
  sl.registerLazySingleton(() => SignInGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );

  //! Features - News
  sl.registerFactory(() => NewsBloc(
        getLiveNews: sl(),
        searchNews: sl(),
      ));
  sl.registerLazySingleton(() => GetLiveNews(sl()));
  sl.registerLazySingleton(() => SearchNews(sl()));
  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Crypto
  sl.registerFactory(() => CryptoBloc(
        getLiveCryptoPrices: sl(),
        searchCrypto: sl(),
      ));
  sl.registerLazySingleton(() => GetLiveCryptoPrices(sl()));
  sl.registerLazySingleton(() => SearchCrypto(sl()));
  sl.registerLazySingleton<CryptoRepository>(
    () => CryptoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<CryptoRemoteDataSource>(
    () => CryptoRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<CryptoLocalDataSource>(
    () => CryptoLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
}
