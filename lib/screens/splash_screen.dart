import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Bildirim iznini kontrol et
    try {
      await NotificationService().initialize();
      print('✅ Bildirim servisi başlatıldı');
    } catch (e) {
      print('❌ Bildirim servisi hatası: $e');
    }

    // 3 saniye sonra login ekranına geç
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: AppConstants.mediumAnimationDuration,
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: AppConstants.mediumAnimationDuration,
                delay: const Duration(milliseconds: 200),
                child: Text(
                  AppConstants.appTagline,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
