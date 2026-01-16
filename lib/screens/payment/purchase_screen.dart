import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/package.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../services/iyzico_webview_service.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/custom_dialogs.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _selectedPackageId;
  String _selectedPaymentMethod = 'iyzico'; // Varsayılan iyzico

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final packages = _paymentService.getAvailablePackages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fal Paketleri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mysticGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mevcut Kredi Bakiyesi
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
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.gold400,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Mevcut Kredi Bakiyeniz',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${user?.creditBalance ?? 0} Fal',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppTheme.gold400,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Ödeme Yöntemi Seçimi
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppTheme.deepPurple400.withOpacity(0.1),
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
                          'Ödeme Yöntemi',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPaymentMethodOption(
                                'iyzico',
                                'Iyzico',
                                'Kredi Kartı / Banka Kartı',
                                Icons.credit_card,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPaymentMethodOption(
                                'simulated',
                                'Test Ödemesi',
                                'Geliştirme için',
                                Icons.bug_report,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Paketler Başlığı
                Text(
                  'Fal Paketleri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Paket Listesi
                ...packages
                    .map((package) => _buildPackageCard(package))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final isSelected = _selectedPackageId == package.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  AppTheme.gold400.withOpacity(0.3),
                  AppTheme.deepPurple600.withOpacity(0.2),
                ]
              : [
                  AppTheme.deepPurple400.withOpacity(0.2),
                  AppTheme.deepPurple600.withOpacity(0.1),
                ],
        ),
        border: Border.all(
          color: isSelected
              ? AppTheme.gold400
              : AppTheme.gold400.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPackageId = package.id;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Paket İkonu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getPackageColor(package.type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getPackageIcon(package.type),
                        color: _getPackageColor(package.type),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Paket Bilgileri
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            package.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    // Seçim İkonu
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.gold400,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Fiyat ve Kredi Bilgisi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.formattedCreditCount,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        Text(
                          package.formattedPrice,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.gold400,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _purchasePackage(package),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppTheme.gold400
                              : AppTheme.deepPurple400,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor:
                              (isSelected
                                      ? AppTheme.gold400
                                      : AppTheme.deepPurple400)
                                  .withOpacity(0.3),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Satın Al'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String method,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white70, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? color : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? color.withOpacity(0.8) : Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPackageColor(PackageType type) {
    switch (type) {
      case PackageType.small:
        return Colors.green;
      case PackageType.medium:
        return Colors.blue;
      case PackageType.large:
        return Colors.purple;
    }
  }

  IconData _getPackageIcon(PackageType type) {
    switch (type) {
      case PackageType.small:
        return Icons.star;
      case PackageType.medium:
        return Icons.star_half;
      case PackageType.large:
        return Icons.auto_awesome;
    }
  }

  Future<void> _purchasePackage(Package package) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      _showErrorDialog('Kullanıcı bulunamadı');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_selectedPaymentMethod == 'iyzico') {
        // Iyzico WebView ile ödeme
        final success = await IyzicoWebViewService.showPaymentPage(
          context: context,
          userId: user.id,
          userEmail: user.email,
          userName: user.displayName ?? 'Kullanıcı',
          package: package,
        );

        if (success) {
          _showSuccessDialog(package);
          await authProvider.refreshUser();
        } else {
          _showErrorDialog('Ödeme işlemi başarısız oldu');
        }
      } else {
        // Simulated ödeme
        final success = await _paymentService.processPayment(
          userId: user.id,
          userEmail: user.email,
          userName: user.displayName ?? 'Kullanıcı',
          package: package,
          paymentMethod: _selectedPaymentMethod,
          paymentDetails: {
            'packageName': package.name,
            'amount': package.price,
            'currency': package.currency,
            'paymentMethod': _selectedPaymentMethod,
          },
        );

        if (success) {
          _showSuccessDialog(package);
          await authProvider.refreshUser();
        } else {
          _showErrorDialog('Ödeme işlemi başarısız oldu');
        }
      }
    } catch (e) {
      _showErrorDialog('Ödeme sırasında hata oluştu: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(Package package) {
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: 'Ödeme Başarılı! 🎉',
        message:
            '${package.name} başarıyla satın alındı!\n\n${package.creditCount} fal kredisi hesabınıza yüklendi.\n\nToplam kredi bakiyeniz: ${Provider.of<AuthProvider>(context, listen: false).user!.creditBalance + package.creditCount}',
        icon: Icons.celebration,
        buttonText: 'Harika!',
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: 'Ödeme Başarısız 😔',
        message: message,
        icon: Icons.error_outline,
        buttonText: 'Tekrar Dene',
      ),
    );
  }
}
