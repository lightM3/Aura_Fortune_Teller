import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/fortune.dart';
import '../../services/fortune_service.dart';
import '../../services/payment_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class PlayingCardFortuneScreen extends StatefulWidget {
  const PlayingCardFortuneScreen({super.key});

  @override
  State<PlayingCardFortuneScreen> createState() =>
      _PlayingCardFortuneScreenState();
}

class _PlayingCardFortuneScreenState extends State<PlayingCardFortuneScreen> {
  final List<String> _selectedCards = [];
  final List<String> _suits = ['♠', '♥', '♦', '♣'];
  final List<String> _ranks = [
    'A',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'Q',
    'K',
  ];
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
        title: const Text('İskambil Falı'),
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
                  '5 kart seçin (${_selectedCards.length}/5)',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 450, // Sabit yükseklik
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.2),
                    border: Border.all(
                      color: AppTheme.gold400.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.all(
                      AppTheme.getResponsiveValue(
                        context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppTheme.getGridCrossAxisCount(context),
                      crossAxisSpacing: AppTheme.getResponsiveValue(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                      mainAxisSpacing: AppTheme.getResponsiveValue(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                      childAspectRatio: MediaQuery.of(context).size.width < 600
                          ? 1.2
                          : 1.0,
                    ),
                    itemCount: _suits.length * _ranks.length,
                    itemBuilder: (context, index) {
                      final suitIndex = index ~/ _ranks.length;
                      final rankIndex = index % _ranks.length;
                      final card = '${_ranks[rankIndex]}${_suits[suitIndex]}';
                      final isSelected = _selectedCards.contains(card);
                      final isRed =
                          _suits[suitIndex] == '♥' || _suits[suitIndex] == '♦';

                      return _buildPlayingCard(card, isSelected, isRed, () {
                        _toggleCardSelection(card);
                      });
                    },
                  ),
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
                    onPressed: _selectedCards.length == 5
                        ? _submitFortune
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepPurple400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
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

  Widget _buildPlayingCard(
    String card,
    bool isSelected,
    bool isRed,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isSelected
                ? AppTheme.gold400.withOpacity(0.2)
                : AppTheme.deepPurple400.withOpacity(0.1),
            isSelected
                ? AppTheme.gold400.withOpacity(0.1)
                : AppTheme.deepPurple600.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: isSelected ? AppTheme.gold400 : Colors.white.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.gold400.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.gold400.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      card,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 600
                            ? 16
                            : 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppTheme.gold400
                            : isRed
                            ? Colors.red
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleCardSelection(String card) {
    setState(() {
      if (_selectedCards.contains(card)) {
        _selectedCards.remove(card);
      } else if (_selectedCards.length < 5) {
        _selectedCards.add(card);
      }
    });
  }

  Future<void> _submitFortune() async {
    if (_selectedCards.length != 5) return;

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Yetersiz kredi bakiyesi! Lütfen paket satın alın.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Fal oluştur
      final fortune = await fortuneService.createFortune(
        senderId: authProvider.user!.id,
        senderName: authProvider.user!.displayName,
        type: FortuneType.playingCard,
        content: _selectedCards,
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
          fortuneType: 'playing_card',
          creditsUsed: 1,
        );

        // AuthProvider'ı güncelle
        await authProvider.refreshUser();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'İskambil falınız başarıyla gönderildi! 1 kredi kullanıldı.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fal gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
