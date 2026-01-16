import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_theme.dart';
import '../../models/fortune.dart';
import '../../services/fortune_service.dart';
import '../../providers/auth_provider.dart';
import '../fortune/oracle_response_screen.dart';
import 'package:provider/provider.dart';

class OracleHomeScreen extends StatelessWidget {
  const OracleHomeScreen({super.key});

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
                padding: EdgeInsets.all(
                  AppTheme.getResponsiveValue(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oracle Paneli',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Text(
                          'Bekleyen Faler',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.gold400.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.gold400.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => _showLogoutDialog(context),
                        style: IconButton.styleFrom(
                          foregroundColor: AppTheme.gold400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: StreamBuilder<List<Fortune>>(
                  stream: FortuneService().getPendingFortunes(),
                  builder: (context, snapshot) {
                    debugPrint(
                      'Oracle StreamBuilder: connectionState=${snapshot.connectionState}',
                    );
                    debugPrint(
                      'Oracle StreamBuilder: hasData=${snapshot.hasData}',
                    );
                    debugPrint(
                      'Oracle StreamBuilder: hasError=${snapshot.hasError}',
                    );
                    if (snapshot.hasError) {
                      debugPrint(
                        'Oracle StreamBuilder error: ${snapshot.error}',
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.gold400,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      debugPrint('Oracle: No pending fortunes found');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.deepPurple400.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: AppTheme.gold400.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppTheme.gold400.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Bekleyen fal yok',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yeni fal gönderildiğinde burada görünecek',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      );
                    }

                    debugPrint(
                      'Oracle: Found ${snapshot.data!.length} pending fortunes',
                    );
                    return ListView.builder(
                      padding: EdgeInsets.all(
                        AppTheme.getResponsiveValue(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final fortune = snapshot.data![index];
                        debugPrint(
                          'Oracle: Building fortune card for ${fortune.id}',
                        );
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: AppTheme.getResponsiveValue(
                              context,
                              mobile: 16,
                              tablet: 20,
                              desktop: 24,
                            ),
                          ),
                          child: _buildFortuneCard(context, fortune),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFortuneCard(BuildContext context, Fortune fortune) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.deepPurple400.withOpacity(0.2),
            AppTheme.deepPurple600.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: AppTheme.gold400.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepPurple400.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          AppTheme.getResponsiveValue(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.gold400.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.gold400.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getFortuneIcon(fortune.type),
                        color: AppTheme.gold400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fortune.typeDisplayName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.gold400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: fortune.status == FortuneStatus.completed
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: fortune.status == FortuneStatus.completed
                          ? Colors.green.withOpacity(0.4)
                          : Colors.orange.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        fortune.status == FortuneStatus.completed
                            ? Icons.check_circle
                            : Icons.pending,
                        color: fortune.status == FortuneStatus.completed
                            ? Colors.green
                            : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        fortune.statusDisplayName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: fortune.status == FortuneStatus.completed
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPurple400.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gönderen',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                      ),
                      Text(
                        fortune.senderName ?? 'Anonim Kullanıcı',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fortune.type != FortuneType.coffee) ...[
                        Text(
                          fortune.content.join(', '),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint(
                    'Yanıtla butonuna tıklandı. Fortune ID: ${fortune.id}',
                  );
                  debugPrint('Navigating to OracleResponseScreen...');

                  try {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          debugPrint(
                            'Building OracleResponseScreen with fortune: ${fortune.id}',
                          );
                          return OracleResponseScreen(fortune: fortune);
                        },
                      ),
                    );
                  } catch (e, stackTrace) {
                    debugPrint('Navigation error: $e');
                    debugPrint('Stack trace: $stackTrace');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fal yanıtlama ekranı açılamadı: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.edit_note),
                label: const Text('Falı Yanıtla'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold400,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppTheme.gold400.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFortuneIcon(FortuneType type) {
    switch (type) {
      case FortuneType.coffee:
        return Icons.local_cafe;
      case FortuneType.tarot:
        return Icons.auto_awesome;
      case FortuneType.playingCard:
        return Icons.style;
    }
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
}
