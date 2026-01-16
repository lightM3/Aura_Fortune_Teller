import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../models/fortune.dart';
import '../../services/fortune_service.dart';

class OracleResponseScreen extends StatefulWidget {
  final Fortune fortune;

  const OracleResponseScreen({super.key, required this.fortune});

  @override
  State<OracleResponseScreen> createState() {
    debugPrint('OracleResponseScreen created with fortune: ${fortune.id}');
    return _OracleResponseScreenState();
  }
}

class _OracleResponseScreenState extends State<OracleResponseScreen> {
  final _responseController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _showFullScreenImage(String imagePath, int initialIndex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              // Full screen image viewer
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.white70,
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Fotoğraf yüklenemedi',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Photo navigation buttons
              if (widget.fortune.content.length > 1) ...[
                Positioned(
                  left: 16,
                  top: MediaQuery.of(context).size.height * 0.45,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      final newIndex =
                          (initialIndex - 1) % widget.fortune.content.length;
                      _showFullScreenImage(
                        widget.fortune.content[newIndex],
                        newIndex,
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).size.height * 0.45,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      final newIndex =
                          (initialIndex + 1) % widget.fortune.content.length;
                      _showFullScreenImage(
                        widget.fortune.content[newIndex],
                        newIndex,
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('OracleResponseScreen: build called');

    return Scaffold(
      appBar: AppBar(
        title: Text('Fal Yanıtlama - ${widget.fortune.typeDisplayName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              AppTheme.getResponsiveValue(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            child: Column(
              children: [
                // Fal Bilgileri
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
                                    _getFortuneIcon(widget.fortune.type),
                                    color: AppTheme.gold400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.fortune.typeDisplayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: AppTheme.gold400,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gönderen',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white60),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.fortune.senderName ?? 'Anonim Kullanıcı',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 16),
                        if (widget.fortune.type != FortuneType.coffee) ...[
                          Text(
                            'Seçilenler',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white60),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: widget.fortune.content.map((item) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.deepPurple400.withOpacity(
                                    0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        if (widget.fortune.userNote != null &&
                            widget.fortune.userNote!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Falcıya Not',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white60),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.gold400.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.gold400.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.fortune.userNote!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.gold400,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                        if (widget.fortune.type == FortuneType.coffee &&
                            widget.fortune.content.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Kahve Fotoğrafları',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white60),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppTheme.deepPurple400.withOpacity(0.1),
                              border: Border.all(
                                color: AppTheme.gold400.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: PageView.builder(
                              itemCount: widget.fortune.content.length,
                              itemBuilder: (context, index) {
                                final imagePath = widget.fortune.content[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GestureDetector(
                                      onTap: () {
                                        _showFullScreenImage(imagePath, index);
                                      },
                                      child: Image.file(
                                        File(imagePath), // Yerel dosya yolu
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
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.broken_image,
                                                        color: Colors.white70,
                                                        size: 32,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Fotoğraf yüklenemedi',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Yanıt Formu
                Text(
                  'Fal Yorumu',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
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
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _responseController,
                    maxLines: null,
                    expands: true,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Fal yorumunuzu buraya yazın...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitResponse,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isLoading ? 'Gönderiliyor...' : 'Yanıtı Gönder',
                    ),
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

  Future<void> _submitResponse() async {
    debugPrint('OracleResponseScreen: _submitResponse called');
    final response = _responseController.text.trim();
    debugPrint('OracleResponseScreen: response length: ${response.length}');

    if (response.isEmpty) {
      debugPrint('OracleResponseScreen: Response is empty, showing error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen fal yorumunu yazın'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('OracleResponseScreen: Starting submission');
    setState(() => _isLoading = true);

    try {
      final fortuneService = FortuneService();
      debugPrint(
        'OracleResponseScreen: Calling updateFortune with ID: ${widget.fortune.id}',
      );

      await fortuneService.updateFortune(
        fortuneId: widget.fortune.id,
        response: response,
      );

      debugPrint('OracleResponseScreen: Update successful');

      if (mounted) {
        debugPrint('OracleResponseScreen: Showing success message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fal yanıtı başarıyla gönderildi!'),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint('OracleResponseScreen: Navigating back');
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('OracleResponseScreen: Error occurred: $e');
      debugPrint('OracleResponseScreen: Stack trace: $stackTrace');

      if (mounted) {
        debugPrint('OracleResponseScreen: Showing error message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yanıt gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      debugPrint('OracleResponseScreen: Finally block called');
      if (mounted) {
        debugPrint('OracleResponseScreen: Setting loading to false');
        setState(() => _isLoading = false);
      }
    }
  }
}
