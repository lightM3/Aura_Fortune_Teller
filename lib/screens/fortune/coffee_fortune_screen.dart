import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../models/fortune.dart';
import '../../services/fortune_service.dart';
import '../../services/payment_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/custom_dialogs.dart';

class CoffeeFortuneScreen extends StatefulWidget {
  const CoffeeFortuneScreen({super.key});

  @override
  State<CoffeeFortuneScreen> createState() => _CoffeeFortuneScreenState();
}

class _CoffeeFortuneScreenState extends State<CoffeeFortuneScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];
  bool _isLoading = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kahve Falı'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Kahve Falı',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kahve fincanınızın fotoğrafını çekin veya yükleyin',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 300, // Sabit yükseklik
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
                      width: 2,
                    ),
                  ),
                  child: _imageFiles.isEmpty
                      ? Column(
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
                                Icons.local_cafe,
                                size: 64,
                                color: AppTheme.gold400.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Kahve Fotoğrafları',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_imageFiles.length} fotoğraf seçildi',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white60),
                            ),
                          ],
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageFiles.length,
                          itemBuilder: (context, index) {
                            final imageFile = _imageFiles[index];
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppTheme.gold400.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Image.file(
                                      File(imageFile.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: AppTheme.deepPurple400
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white70,
                                                  size: 48,
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _imageFiles.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeriden Seç'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepPurple400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Fotoğraf Çek'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold400,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Falcıya Not Alanı
                Container(
                  width: double.infinity,
                  height: 120, // Sabit yükseklik
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
                  child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    expands: true,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          'Falcıya not bırakmak ister misiniz? (İsteğe bağlı)',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _imageFiles.isNotEmpty ? _submitFortune : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepPurple400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Falı Gönder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _imageFiles.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fotoğraf seçilemedi: $e')));
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _imageFiles.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fotoğraf çekilemedi: $e')));
    }
  }

  Future<void> _submitFortune() async {
    if (_imageFiles.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fortuneService = FortuneService();
      final paymentService = PaymentService();

      // Kredi kontrolü
      final hasEnoughCredits = await paymentService.hasEnoughCredits(
        authProvider.user!.id,
      );

      if (!hasEnoughCredits) {
        if (mounted) {
          CustomSnackBar.showInfo(
            context,
            message: 'Yetersiz kredi bakiyesi! Lütfen paket satın alın.',
          );
        }
        return;
      }

      // Fal oluştur
      final fortune = await fortuneService.createFortune(
        senderId: authProvider.user!.id,
        senderName: authProvider.user!.displayName,
        type: FortuneType.coffee,
        content: _imageFiles.map((file) => file.path).toList(),
        userNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      // Kredi düş
      final creditUsed = await paymentService.useCredit(authProvider.user!.id);

      if (creditUsed) {
        // Kredi kullanım kaydı oluştur
        await paymentService.createCreditUsageRecord(
          userId: authProvider.user!.id,
          fortuneId: fortune.id,
          fortuneType: 'coffee',
          creditsUsed: 1,
        );

        // AuthProvider'ı güncelle
        await authProvider.refreshUser();
      }

      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Falınız başarıyla gönderildi! 1 kredi kullanıldı.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, message: 'Fal gönderilemedi: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
