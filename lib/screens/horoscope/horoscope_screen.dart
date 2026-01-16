import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/horoscope.dart';
import '../../services/horoscope_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen>
    with TickerProviderStateMixin {
  ZodiacSign? _selectedSign;
  Horoscope? _dailyHoroscope;
  Horoscope? _weeklyHoroscope;
  bool _isLoading = false;
  late TabController _tabController;
  final _birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserBirthDate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _loadUserBirthDate() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.birthDate != null) {
      setState(() {
        _selectedSign = ZodiacSign.getSignFromDate(
          authProvider.user!.birthDate!,
        );
        _birthDateController.text =
            '${authProvider.user!.birthDate!.day}/${authProvider.user!.birthDate!.month}/${authProvider.user!.birthDate!.year}';
      });
      _loadHoroscopes();
    }
  }

  Future<void> _loadHoroscopes() async {
    if (_selectedSign == null) return;

    setState(() => _isLoading = true);

    try {
      final horoscopeService = HoroscopeService();
      final daily = await horoscopeService.getDailyHoroscope(_selectedSign!);
      final weekly = await horoscopeService.getWeeklyHoroscope(_selectedSign!);

      // Debug loglarını ekle
      debugPrint('=== GEMINI API DEBUG ===');
      debugPrint('Selected Sign: ${_selectedSign?.name}');
      debugPrint('Daily Response: ${daily?.dailyCommentary}');
      debugPrint('Weekly Response: ${weekly?.weeklyCommentary}');
      debugPrint('=== DEBUG END ===');

      setState(() {
        _dailyHoroscope = daily;
        _weeklyHoroscope = weekly;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Hata detaylı log
      debugPrint('=== GEMINI API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('=== ERROR END ===');

      // CustomSnackBar ile göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Burç yorumları yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Burç Yorumları'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold400,
          labelColor: AppTheme.gold400,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Burç Seçimi
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
                        if (_selectedSign != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold400.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedSign!.symbol,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: AppTheme.gold400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedSign!.turkishName} Burcu',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppTheme.gold400,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Yorumlar
                if (_selectedSign != null) ...[
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDailyHoroscope(),
                        _buildWeeklyHoroscope(),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.deepPurple400.withOpacity(0.1),
                          AppTheme.deepPurple600.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: AppTheme.gold400.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 64,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Burç yorumlarını görmek için\nlütfen doğum tarihinizi seçin',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyHoroscope() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.gold400),
      );
    }

    if (_dailyHoroscope == null) {
      return const Center(
        child: Text(
          'Günlük yorum yüklenemedi',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
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
        border: Border.all(color: AppTheme.gold400.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: AppTheme.gold400, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Günlük Yorum',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.gold400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _dailyHoroscope!.dailyCommentary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyHoroscope() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.gold400),
      );
    }

    if (_weeklyHoroscope == null) {
      return const Center(
        child: Text(
          'Haftalık yorum yüklenemedi',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
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
        border: Border.all(color: AppTheme.gold400.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, color: AppTheme.gold400, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Haftalık Yorum',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.gold400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _weeklyHoroscope!.weeklyCommentary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
