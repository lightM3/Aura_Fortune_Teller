import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fortune.dart';
import '../models/user_model.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  // Cache directory
  Future<Directory> get _cacheDir async {
    final directory = await getApplicationDocumentsDirectory();
    return Directory('${directory.path}/cache');
  }

  // Fortune'ları offline'a kaydet
  Future<void> cacheFortunes(List<Fortune> fortunes) async {
    try {
      final cacheDir = await _cacheDir;
      await cacheDir.create(recursive: true);

      final file = File('${cacheDir.path}/fortunes.json');
      final fortunesJson = fortunes.map((f) => f.toJson()).toList();

      await file.writeAsString(jsonEncode(fortunesJson));
      print('Fortunes cached offline: ${fortunes.length} items');
    } catch (e) {
      print('Error caching fortunes: $e');
    }
  }

  // Offline'dan fortune'ları getir
  Future<List<Fortune>> getCachedFortunes() async {
    try {
      final cacheDir = await _cacheDir;
      final file = File('${cacheDir.path}/fortunes.json');

      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      final fortunesJson = jsonDecode(content) as List;

      return fortunesJson.map((json) => Fortune.fromJson(json)).toList();
    } catch (e) {
      print('Error getting cached fortunes: $e');
      return [];
    }
  }

  // Kullanıcı verisini offline'a kaydet
  Future<void> cacheUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user', jsonEncode(user.toJson()));
      print('User cached offline: ${user.email}');
    } catch (e) {
      print('Error caching user: $e');
    }
  }

  // Offline'dan kullanıcı verisini getir
  Future<UserModel?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('cached_user');

      if (userJson == null) {
        return null;
      }

      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error getting cached user: $e');
      return null;
    }
  }

  // Kredi bakiyesini offline'a kaydet
  Future<void> cacheCreditBalance(String userId, int creditBalance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('credit_balance_$userId', creditBalance);
      print('Credit balance cached: $creditBalance');
    } catch (e) {
      print('Error caching credit balance: $e');
    }
  }

  // Offline'dan kredi bakiyesini getir
  Future<int> getCachedCreditBalance(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('credit_balance_$userId') ?? 0;
    } catch (e) {
      print('Error getting cached credit balance: $e');
      return 0;
    }
  }

  // Paketleri offline'a kaydet
  Future<void> cachePackages(List<Map<String, dynamic>> packages) async {
    try {
      final cacheDir = await _cacheDir;
      await cacheDir.create(recursive: true);

      final file = File('${cacheDir.path}/packages.json');
      await file.writeAsString(jsonEncode(packages));
      print('Packages cached offline: ${packages.length} items');
    } catch (e) {
      print('Error caching packages: $e');
    }
  }

  // Offline'dan paketleri getir
  Future<List<Map<String, dynamic>>> getCachedPackages() async {
    try {
      final cacheDir = await _cacheDir;
      final file = File('${cacheDir.path}/packages.json');

      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      final packagesJson = jsonDecode(content) as List;

      return packagesJson.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting cached packages: $e');
      return [];
    }
  }

  // İnternet bağlantısını kontrol et
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Cache temizle
  Future<void> clearCache() async {
    try {
      final cacheDir = await _cacheDir;
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        print('Cache cleared');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('SharedPreferences cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Cache boyutunu al
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _cacheDir;
      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }

  // Eski cache dosyalarını temizle (7 günden eski)
  Future<void> cleanOldCache() async {
    try {
      final cacheDir = await _cacheDir;
      if (!await cacheDir.exists()) {
        return;
      }

      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 7));

      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          final modified = stat.modified;

          if (modified.isBefore(cutoff)) {
            await entity.delete();
            print('Deleted old cache file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning old cache: $e');
    }
  }

  // Sync durumunu kontrol et
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString('last_sync');
      final hasInternet = await hasInternetConnection();
      final cacheSize = await getCacheSize();

      return {
        'last_sync': lastSync,
        'has_internet': hasInternet,
        'cache_size': cacheSize,
        'cache_size_mb': (cacheSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('Error getting sync status: $e');
      return {
        'last_sync': null,
        'has_internet': false,
        'cache_size': 0,
        'cache_size_mb': '0.00',
      };
    }
  }

  // Son sync zamanını güncelle
  Future<void> updateLastSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync', DateTime.now().toIso8601String());
      print('Last sync updated');
    } catch (e) {
      print('Error updating last sync: $e');
    }
  }

  // Offline mod özellikleri kontrolü
  Future<Map<String, bool>> getOfflineFeatures() async {
    final hasInternet = await hasInternetConnection();
    final cachedFortunes = await getCachedFortunes();
    final cachedUser = await getCachedUser();
    final cachedPackages = await getCachedPackages();
    final cachedCreditBalance = cachedUser != null
        ? await getCachedCreditBalance(cachedUser.id)
        : 0;

    return {
      'has_internet': hasInternet,
      'has_cached_fortunes': cachedFortunes.isNotEmpty,
      'has_cached_user': cachedUser != null,
      'has_cached_packages': cachedPackages.isNotEmpty,
      'has_cached_credits': cachedCreditBalance > 0,
      'can_view_fortunes': cachedFortunes.isNotEmpty,
      'can_view_profile': cachedUser != null,
      'can_purchase_packages':
          hasInternet, // Paket satın alma için internet gerekli
      'can_send_fortune':
          hasInternet &&
          cachedCreditBalance > 0, // Fal göndermek için internet gerekli
    };
  }
}
