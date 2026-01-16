import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/fortune.dart';
import '../../services/fortune_service.dart';
import '../../services/payment_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/tarot_cards.dart';
import '../../widgets/tarot_card_widget.dart';

class TarotFortuneScreen extends StatefulWidget {
  const TarotFortuneScreen({super.key});

  @override
  State<TarotFortuneScreen> createState() => _TarotFortuneScreenState();
}

class _TarotFortuneScreenState extends State<TarotFortuneScreen>
    with TickerProviderStateMixin {
  final List<TarotCard> _selectedCards = [];
  List<TarotCard> _availableCards = [];
  bool _isLoading = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _shuffleCards();
  }

  void _shuffleCards() {
    setState(() {
      _availableCards = TarotCards.getRandomCards(22); // Her seferinde karıştır
      _selectedCards.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarot Falı'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetCards),
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
                Text(
                  '3 kart seçin (${_selectedCards.length}/3)',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '3 kart seçtikten sonra falınızı gönderebilirsiniz',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 400, // Sabit yükseklik
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
                        tablet: 24,
                        desktop: 32,
                      ),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppTheme.getGridCrossAxisCount(context),
                      crossAxisSpacing: AppTheme.getResponsiveValue(
                        context,
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                      mainAxisSpacing: AppTheme.getResponsiveValue(
                        context,
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                      childAspectRatio: AppTheme.getCardAspectRatio(context),
                    ),
                    itemCount: _availableCards.length,
                    itemBuilder: (context, index) {
                      final card = _availableCards[index];
                      final isSelected = _selectedCards.contains(card);

                      return TarotCardWidget(
                        card: card,
                        isSelected: isSelected,
                        isRevealed: false, // Kart isimleri gizli
                        onTap: () => _toggleCardSelection(card),
                      );
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
                if (_selectedCards.length == 3)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitFortune,
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
                        _isLoading ? 'Gönderiliyor...' : 'Falı Gönder',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepPurple400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _toggleCardSelection(TarotCard card) {
    setState(() {
      if (_selectedCards.contains(card)) {
        _selectedCards.remove(card);
      } else if (_selectedCards.length < 3) {
        _selectedCards.add(card);
      }
    });
  }

  void _resetCards() {
    _shuffleCards();
  }

  Future<void> _submitFortune() async {
    if (_selectedCards.length != 3) return;

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
        type: FortuneType.tarot,
        content: _selectedCards.map((card) => card.name).toList(),
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
          fortuneType: 'tarot',
          creditsUsed: 1,
        );

        // AuthProvider'ı güncelle
        await authProvider.refreshUser();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tarot falınız başarıyla gönderildi! 1 kredi kullanıldı.',
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
