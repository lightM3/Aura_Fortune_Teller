import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/package.dart';
import '../services/iyzico_service.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IyzicoService _iyzicoService = IyzicoService();

  // Varsayılan paketleri getir
  List<Package> getAvailablePackages() {
    return Package.getDefaultPackages();
  }

  // Kullanıcının kredi bakiyesini güncelle
  Future<bool> updateCreditBalance(String userId, int creditsToAdd) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('Kullanıcı bulunamadı');
        }

        final currentBalance = userDoc.data()?['creditBalance'] ?? 0;
        final newBalance = currentBalance + creditsToAdd;

        transaction.update(userRef, {
          'creditBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return true;
    } catch (e) {
      print('Kredi güncelleme hatası: $e');
      return false;
    }
  }

  // Kullanıcının kredi bakiyesini kontrol et
  Future<int> getUserCreditBalance(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return 0;
      }

      return userDoc.data()?['creditBalance'] ?? 0;
    } catch (e) {
      print('Kredi bakiyesi okuma hatası: $e');
      return 0;
    }
  }

  // Kredi kullan (fal gönderildiğinde)
  Future<bool> useCredit(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('Kullanıcı bulunamadı');
        }

        final currentBalance = userDoc.data()?['creditBalance'] ?? 0;

        if (currentBalance < 1) {
          throw Exception('Yetersiz kredi bakiyesi');
        }

        final newBalance = currentBalance - 1;

        transaction.update(userRef, {
          'creditBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return true;
    } catch (e) {
      print('Kredi kullanma hatası: $e');
      return false;
    }
  }

  // Kullanıcının yeterli kredisi var mı?
  Future<bool> hasEnoughCredits(
    String userId, {
    int requiredCredits = 1,
  }) async {
    try {
      final balance = await getUserCreditBalance(userId);
      return balance >= requiredCredits;
    } catch (e) {
      print('Kredi kontrolü hatası: $e');
      return false;
    }
  }

  // Ödeme işlemi (Iyzico ile)
  Future<bool> processPayment({
    required String userId,
    required String userEmail,
    required String userName,
    required Package package,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      if (paymentMethod == 'iyzico') {
        // Iyzico ile gerçek ödeme
        final paymentResult = await _iyzicoService.createPayment(
          userId: userId,
          userEmail: userEmail,
          userName: userName,
          package: package,
          callbackUrl: 'https://your-app.com/payment-callback',
        );

        if (paymentResult['success']) {
          // Ödeme başarılı, kredi yükle
          await _createPaymentRecord(
            userId: userId,
            package: package,
            paymentMethod: paymentMethod,
            paymentDetails: paymentResult,
            status: 'completed',
          );

          await updateCreditBalance(userId, package.creditCount);
          return true;
        } else {
          // Ödeme başarısız
          await _createPaymentRecord(
            userId: userId,
            package: package,
            paymentMethod: paymentMethod,
            paymentDetails: paymentResult,
            status: 'failed',
            error: paymentResult['error'],
          );
          return false;
        }
      } else {
        // Simüle edilmiş ödeme (test için)
        await _createPaymentRecord(
          userId: userId,
          package: package,
          paymentMethod: paymentMethod,
          paymentDetails: paymentDetails ?? {},
          status: 'completed',
        );

        await updateCreditBalance(userId, package.creditCount);
        return true;
      }
    } catch (e) {
      print('Ödeme işlemi hatası: $e');

      // Başarısız ödeme kaydı oluştur
      await _createPaymentRecord(
        userId: userId,
        package: package,
        paymentMethod: paymentMethod,
        paymentDetails: paymentDetails ?? {},
        status: 'failed',
        error: e.toString(),
      );

      return false;
    }
  }

  // Ödeme kaydı oluştur
  Future<void> _createPaymentRecord({
    required String userId,
    required Package package,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
    required String status,
    String? error,
  }) async {
    try {
      await _firestore.collection('payments').add({
        'userId': userId,
        'packageId': package.id,
        'packageName': package.name,
        'creditCount': package.creditCount,
        'amount': package.price,
        'currency': package.currency,
        'paymentMethod': paymentMethod,
        'paymentDetails': paymentDetails ?? {},
        'status': status,
        'error': error,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Ödeme kaydı oluşturma hatası: $e');
    }
  }

  // Kullanıcının ödeme geçmişini getir
  Future<List<Map<String, dynamic>>> getUserPaymentHistory(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Ödeme geçmişi okuma hatası: $e');
      return [];
    }
  }

  // Paket bilgilerini getir
  Package? getPackageById(String packageId) {
    try {
      final packages = getAvailablePackages();
      return packages.firstWhere((package) => package.id == packageId);
    } catch (e) {
      print('Paket bulunamadı: $e');
      return null;
    }
  }

  // Kredi kullanım geçmişini getir
  Future<List<Map<String, dynamic>>> getCreditUsageHistory(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('credit_usage')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Kredi kullanım geçmişi okuma hatası: $e');
      return [];
    }
  }

  // Kredi kullanım kaydı oluştur
  Future<void> createCreditUsageRecord({
    required String userId,
    required String fortuneId,
    required String fortuneType,
    required int creditsUsed,
  }) async {
    try {
      await _firestore.collection('credit_usage').add({
        'userId': userId,
        'fortuneId': fortuneId,
        'fortuneType': fortuneType,
        'creditsUsed': creditsUsed,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Kredi kullanım kaydı oluşturma hatası: $e');
    }
  }
}
