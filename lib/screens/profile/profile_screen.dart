import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/fortune_service.dart';
import '../../models/fortune.dart';
import '../../widgets/custom_dialogs.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf seçilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final fortuneService = FortuneService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Avatar ve Temel Bilgiler
                Container(
                  width: double.infinity,
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
                    border: Border.all(
                      color: AppTheme.gold400.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Avatar
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.gold400.withOpacity(0.3),
                                  AppTheme.deepPurple400.withOpacity(0.2),
                                ],
                              ),
                              border: Border.all(
                                color: AppTheme.gold400.withOpacity(0.5),
                                width: 3,
                              ),
                            ),
                            child: _selectedImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                                  )
                                : user?.photoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      user!.photoUrl!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.white70,
                                            );
                                          },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white70,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.displayName ?? 'Kullanıcı',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Doğum Tarihi
                Container(
                  width: double.infinity,
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
                    border: Border.all(
                      color: AppTheme.gold400.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Doğum Tarihi',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            TextButton.icon(
                              onPressed: _selectBirthDate,
                              icon: const Icon(
                                Icons.edit,
                                color: AppTheme.gold400,
                              ),
                              label: Text(
                                'Düzenle',
                                style: TextStyle(color: AppTheme.gold400),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.birthDate != null
                              ? '${user!.birthDate!.day}/${user!.birthDate!.month}/${user!.birthDate!.year}'
                              : 'Belirtilmemiş',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                        if (user?.birthDate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _getBirthTimeNote(user!.birthDate!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white54),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // İstatistikler
                if (user?.isOracle == true) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.gold400.withOpacity(0.2),
                          AppTheme.deepPurple600.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppTheme.gold400.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Falcı İstatistikleri',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.gold400,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Fal Sayısı',
                                  '${user?.totalFortunesReceived ?? 0}',
                                  Icons.auto_awesome,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Puan',
                                  '${user?.averageRating.toStringAsFixed(1) ?? '0.0'}',
                                  Icons.star,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Fal Geçmişi
                Container(
                  width: double.infinity,
                  height: 400,
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
                    border: Border.all(
                      color: AppTheme.gold400.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fal Geçmişi',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: StreamBuilder<List<Fortune>>(
                            stream: fortuneService.getUserFortunes(
                              user?.id ?? '',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.gold400,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Hata: ${snapshot.error}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                );
                              }

                              final fortunes = snapshot.data ?? [];

                              if (fortunes.isEmpty) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 64,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Henüz fal göndermediniz',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: fortunes.length,
                                itemBuilder: (context, index) {
                                  final fortune = fortunes[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.gold400.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.gold400.withOpacity(
                                          0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.deepPurple400
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            _getFortuneIcon(fortune.type),
                                            color: AppTheme.gold400,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fortune.typeDisplayName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Gönderildi: ${_formatDate(fortune.createdAt)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.white70,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Durum: ${_getStatusText(fortune.status)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: _getStatusColor(
                                                        fortune.status,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppTheme.gold400,
                                          size: 16,
                                        ),
                                      ],
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: user?.birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum tarihinizi seçin',
    );

    if (picked != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateBirthDate(picked!);

      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Doğum tarihi güncellendi! 🎂',
        );
      }
    }
  }

  String _getBirthTimeNote(DateTime birthDate) {
    final hour = birthDate.hour;
    final minute = birthDate.minute;

    // Önemli saat aralıkları
    if ((hour >= 6 && hour < 8) || (hour >= 18 && hour < 20)) {
      return '⏰ Doğum saati burç yorumları için önemlidir! (${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})';
    } else if ((hour >= 20 && hour < 22) || (hour >= 0 && hour < 2)) {
      return '🌙 Gece doğumu (${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})';
    } else if ((hour >= 10 && hour < 12) || (hour >= 14 && hour < 16)) {
      return '☀️ Öğlen doğumu (${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})';
    } else {
      return '🕐 Doğum saati: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gold400.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold400.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.gold400, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.gold400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Bilinmiyor';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(FortuneStatus status) {
    switch (status) {
      case FortuneStatus.pending:
        return 'Beklemede';
      case FortuneStatus.completed:
        return 'Yanıtlandı';
    }
  }

  Color _getStatusColor(FortuneStatus status) {
    switch (status) {
      case FortuneStatus.pending:
        return Colors.orange;
      case FortuneStatus.completed:
        return Colors.green;
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
