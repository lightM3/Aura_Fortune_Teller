import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/user_home_screen.dart';
import 'screens/home/oracle_home_screen.dart';
import 'screens/fortune/coffee_fortune_screen.dart';
import 'screens/fortune/tarot_fortune_screen.dart';
import 'screens/fortune/playing_card_fortune_screen.dart';
import 'screens/fortune/oracle_response_screen.dart';
import 'screens/horoscope/horoscope_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/payment/purchase_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'providers/auth_provider.dart';
import 'models/fortune.dart';
import 'utils/constants.dart';
import 'services/notification_service.dart';
import 'services/offline_service.dart';
import 'services/performance_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Firebase'i başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Mobil optimizasyon servislerini başlat
  try {
    // Bildirim servisini başlat
    await NotificationService().initialize();
    print('✅ Notification service initialized');

    // Performans servisini başlat
    PerformanceService();
    print('✅ Performance service initialized');

    // Offline servisini başlat
    await OfflineService().cleanOldCache();
    print('✅ Offline service initialized');
  } catch (e) {
    print('❌ Service initialization error: $e');
  }

  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/user-home': (context) => const UserHomeScreen(),
          '/oracle-home': (context) => const OracleHomeScreen(),
          '/coffee-fortune': (context) => const CoffeeFortuneScreen(),
          '/tarot-fortune': (context) => const TarotFortuneScreen(),
          '/playing-card-fortune': (context) =>
              const PlayingCardFortuneScreen(),
          '/oracle-response': (context, {arguments}) {
            if (arguments == null) {
              return const Scaffold(
                body: Center(child: Text('Hata: Fal bilgisi bulunamadı')),
              );
            }
            final fortune = arguments as Fortune;
            return OracleResponseScreen(fortune: fortune);
          },
          '/horoscope': (context) => const HoroscopeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/purchase': (context) => const PurchaseScreen(),
          '/admin': (context) => const AdminPanelScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        debugPrint(
          'AuthWrapper: isLoading=${authProvider.isLoading}, isAuthenticated=${authProvider.isAuthenticated}, isOracle=${authProvider.isOracle}',
        );

        // Loading durumu
        if (authProvider.isLoading) {
          debugPrint('AuthWrapper: Returning SplashScreen');
          return const SplashScreen();
        }

        // Kullanıcı giriş yapmamışsa
        if (!authProvider.isAuthenticated) {
          debugPrint('AuthWrapper: Returning LoginScreen');
          return const LoginScreen();
        }

        // Rol bazlı yönlendirme
        if (authProvider.isAdmin) {
          debugPrint('AuthWrapper: Returning AdminPanelScreen');
          return const AdminPanelScreen();
        } else if (authProvider.isOracle) {
          debugPrint('AuthWrapper: Returning OracleHomeScreen');
          return const OracleHomeScreen();
        } else {
          debugPrint('AuthWrapper: Returning UserHomeScreen');
          return const UserHomeScreen();
        }
      },
    );
  }
}
