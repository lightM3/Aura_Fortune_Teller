import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _totalRevenue = 0;
  int _totalUsers = 0;
  int _totalFortunes = 0;
  int _totalCreditsSold = 0;
  List<Map<String, dynamic>> _recentPayments = [];
  List<Map<String, dynamic>> _topUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadRevenueData(),
        _loadUserData(),
        _loadFortuneData(),
        _loadRecentPayments(),
        _loadTopUsers(),
      ]);
    } catch (e) {
      print('Admin veri yükleme hatası: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRevenueData() async {
    try {
      final payments = await FirebaseFirestore.instance
          .collection('payments')
          .where('status', isEqualTo: 'completed')
          .get();

      int totalRevenue = 0;
      int totalCreditsSold = 0;

      for (var payment in payments.docs) {
        final data = payment.data();
        totalRevenue += (data['amount'] as num).toInt();
        totalCreditsSold += (data['creditCount'] as num).toInt();
      }

      setState(() {
        _totalRevenue = totalRevenue;
        _totalCreditsSold = totalCreditsSold;
      });
    } catch (e) {
      print('Gelir verisi hatası: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final users = await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        _totalUsers = users.docs.length;
      });
    } catch (e) {
      print('Kullanıcı verisi hatası: $e');
    }
  }

  Future<void> _loadFortuneData() async {
    try {
      final fortunes = await FirebaseFirestore.instance
          .collection('fortunes')
          .get();

      setState(() {
        _totalFortunes = fortunes.docs.length;
      });
    } catch (e) {
      print('Fal verisi hatası: $e');
    }
  }

  Future<void> _loadRecentPayments() async {
    try {
      final payments = await FirebaseFirestore.instance
          .collection('payments')
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      setState(() {
        _recentPayments = payments.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Son ödemeler hatası: $e');
    }
  }

  Future<void> _loadTopUsers() async {
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('creditBalance', descending: true)
          .limit(10)
          .get();

      setState(() {
        _topUsers = users.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Top kullanıcılar hatası: $e');
    }
  }

  // Çıkış yap
  Future<void> _signOut() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    } catch (e) {
      print('Çıkış hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çıkış yapılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Admin kontrolü
    if (!authProvider.isAdmin) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
          child: const Center(
            child: Text(
              'Yetkisiz erişim',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdminData,
            tooltip: 'Verileri Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.gold400),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İstatistik Kartları
                    _buildStatsSection(),
                    const SizedBox(height: 24),

                    // Paket Satışları
                    _buildPackageSalesSection(),
                    const SizedBox(height: 24),

                    // Son Ödemeler
                    _buildRecentPaymentsSection(),
                    const SizedBox(height: 24),

                    // Top Kullanıcılar
                    _buildTopUsersSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genel İstatistikler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Toplam Gelir',
              '₺$_totalRevenue',
              Icons.attach_money,
              Colors.green,
            ),
            _buildStatCard(
              'Toplam Kullanıcı',
              '$_totalUsers',
              Icons.people,
              AppTheme.deepPurple400,
            ),
            _buildStatCard(
              'Toplam Fal',
              '$_totalFortunes',
              Icons.auto_awesome,
              AppTheme.gold400,
            ),
            _buildStatCard(
              'Satılan Kredi',
              '$_totalCreditsSold',
              Icons.account_balance_wallet,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageSalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paket Satışları',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.deepPurple400.withOpacity(0.1),
            border: Border.all(
              color: AppTheme.gold400.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: _totalCreditsSold > 0
              ? _buildPackageSalesList()
              : const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white54,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Henüz paket satışı yapılmadı',
                          style: TextStyle(color: Colors.white54),
                        ),
                        Text(
                          'Kullanıcılar paket satın aldığında burada görünür',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPackageSalesList() {
    // Paket satışlarını hesapla
    Map<String, int> packageSales = {
      'Başlangıç Paketi': 0,
      'Standart Paket': 0,
      'Premium Paket': 0,
    };

    // Burada gerçek verileri Firestore'dan çekebiliriz
    // Şimdilik örnek verilerle gösterelim
    if (_totalCreditsSold > 0) {
      // Basit hesaplama: toplam krediden paket sayısını tahmin et
      int remaining = _totalCreditsSold;

      // Premium (10 kredi)
      int premium = remaining ~/ 10;
      remaining -= premium * 10;

      // Standart (5 kredi)
      int standard = remaining ~/ 5;
      remaining -= standard * 5;

      // Başlangıç (3 kredi)
      int basic = remaining ~/ 3;

      packageSales['Premium Paket'] = premium;
      packageSales['Standart Paket'] = standard;
      packageSales['Başlangıç Paketi'] = basic;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paket Adı',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Satış Adedi',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Paket listesi
          ...packageSales.entries.map((entry) {
            final packageName = entry.key;
            final salesCount = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: AppTheme.gold400.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Paket ikonu ve adı
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPackageColor(packageName).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPackageIcon(packageName),
                      color: _getPackageColor(packageName),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Paket bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          _getPackageDescription(packageName),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),

                  // Satış sayısı
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: salesCount > 0
                          ? AppTheme.gold400.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: salesCount > 0
                            ? AppTheme.gold400.withOpacity(0.4)
                            : Colors.grey.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      salesCount.toString(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: salesCount > 0 ? AppTheme.gold400 : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          // Toplam satış bilgisi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppTheme.gold400.withOpacity(0.1),
                  AppTheme.deepPurple400.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: AppTheme.gold400.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam Paket Satışı',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${packageSales.values.reduce((a, b) => a + b)} adet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.gold400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPackageColor(String packageName) {
    switch (packageName) {
      case 'Başlangıç Paketi':
        return Colors.green;
      case 'Standart Paket':
        return Colors.blue;
      case 'Premium Paket':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPackageIcon(String packageName) {
    switch (packageName) {
      case 'Başlangıç Paketi':
        return Icons.star_outline;
      case 'Standart Paket':
        return Icons.stars_outlined;
      case 'Premium Paket':
        return Icons.diamond_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  String _getPackageDescription(String packageName) {
    switch (packageName) {
      case 'Başlangıç Paketi':
        return '3 Fal - ₺100';
      case 'Standart Paket':
        return '5 Fal - ₺150';
      case 'Premium Paket':
        return '10 Fal - ₺250';
      default:
        return '';
    }
  }

  Widget _buildRecentPaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Ödemeler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.deepPurple400.withOpacity(0.1),
            border: Border.all(
              color: AppTheme.gold400.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: _recentPayments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Henüz ödeme kaydı bulunmuyor',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentPayments.length,
                  itemBuilder: (context, index) {
                    final payment = _recentPayments[index];
                    return _buildPaymentItem(payment);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    final createdAt = payment['createdAt'] as Timestamp?;
    final date = createdAt?.toDate();
    final amount = payment['amount'] ?? 0.0;
    final packageName = payment['packageName'] ?? 'Bilinmeyen Paket';
    final creditCount = payment['creditCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.gold400.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packageName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$creditCount kredi • ₺${amount.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                if (date != null)
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Text(
              'Başarılı',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'En Çok Kredisi Olan Kullanıcılar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.deepPurple400.withOpacity(0.1),
            border: Border.all(
              color: AppTheme.gold400.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: _topUsers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Henüz kullanıcı bulunmuyor',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _topUsers.length,
                  itemBuilder: (context, index) {
                    final user = _topUsers[index];
                    return _buildUserItem(user, index + 1);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user, int rank) {
    final displayName = user['displayName'] ?? 'İsimsiz Kullanıcı';
    final email = user['email'] ?? '';
    final creditBalance = user['creditBalance'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.gold400.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppTheme.gold400 : AppTheme.deepPurple400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            '$creditBalance kredi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.gold400,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
