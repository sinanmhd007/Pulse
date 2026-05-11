import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/stocks/presentation/bloc/stock_bloc.dart';
import 'features/stocks/presentation/bloc/stock_event.dart';
import 'features/crypto/presentation/bloc/crypto_bloc.dart';
import 'features/crypto/presentation/bloc/crypto_event.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: "assets/env/.env");
  await di.init();
  runApp(const PulseApp());
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<StockBloc>()..add(FetchLiveStocks())),
        BlocProvider(
          create: (_) => di.sl<CryptoBloc>()..add(FetchLiveCrypto()),
        ),
      ],
      child: MaterialApp(
        title: 'Pulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashPage(),
      ),
    );
  }
}
