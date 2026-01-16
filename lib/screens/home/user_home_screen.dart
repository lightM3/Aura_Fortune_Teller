import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../fortune/user_fortunes_screen.dart';
import 'package:provider/provider.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.account_balance_wallet),
                          onPressed: () {
                            Navigator.pushNamed(context, '/purchase');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.person),
                          onPressed: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: GridView.count(
                  padding: EdgeInsets.all(
                    AppTheme.getResponsiveValue(
                      context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    ),
                  ),
                  crossAxisCount: AppTheme.getGridCrossAxisCount(context),
                  crossAxisSpacing: AppTheme.getResponsiveValue(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                  mainAxisSpacing: AppTheme.getResponsiveValue(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                  childAspectRatio: MediaQuery.of(context).size.width < 600
                      ? 0.8
                      : 0.7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildFortuneTypeCard(
                      context,
                      title: 'Kahve Falı',
                      icon: Icons.local_cafe,
                      color: AppTheme.deepPurple400,
                      onTap: () {
                        Navigator.pushNamed(context, '/coffee-fortune');
                      },
                    ),
                    _buildFortuneTypeCard(
                      context,
                      title: 'Tarot',
                      icon: Icons.auto_awesome,
                      color: AppTheme.gold400,
                      onTap: () {
                        Navigator.pushNamed(context, '/tarot-fortune');
                      },
                    ),
                    _buildFortuneTypeCard(
                      context,
                      title: 'İskambil Falı',
                      icon: Icons.style,
                      color: AppTheme.deepPurple300,
                      onTap: () {
                        Navigator.pushNamed(context, '/playing-card-fortune');
                      },
                    ),
                    _buildFortuneTypeCard(
                      context,
                      title: 'Burç Yorumları',
                      icon: Icons.auto_awesome,
                      color: AppTheme.gold400,
                      onTap: () {
                        Navigator.pushNamed(context, '/horoscope');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        backgroundColor: AppTheme.deepPurple800,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppTheme.gold400),
        contentTextStyle: Theme.of(context).textTheme.bodyMedium,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTypeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
