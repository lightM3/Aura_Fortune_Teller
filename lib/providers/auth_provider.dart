import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _authService.currentUser != null;
  bool get isUser => _user?.isUser ?? false;
  bool get isOracle => _user?.isOracle ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getUserData(firebaseUser.uid);
        debugPrint('User data loaded: ${_user?.toString()}');
        debugPrint('Is oracle: ${_user?.isOracle}');
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Firebase kontrolü
      if (!_authService.isFirebaseInitialized) {
        _isLoading = false;
        notifyListeners();
        throw Exception(
          'Firebase yapılandırılmamış. Lütfen Firebase\'i yapılandırın.',
        );
      }

      final userModel = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (userModel != null) {
        _user = userModel;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Hata mesajını üst katmana ilet
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
    required UserRole role,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Firebase kontrolü
      if (!_authService.isFirebaseInitialized) {
        _isLoading = false;
        notifyListeners();
        throw Exception(
          'Firebase yapılandırılmamış. Lütfen Firebase\'i yapılandırın.',
        );
      }

      final userModel = await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
        role,
      );

      if (userModel != null) {
        _user = userModel;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Hata mesajını üst katmana ilet
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // Kullanıcı verisini yenile
  Future<void> refreshUser() async {
    if (_user != null) {
      _user = await _authService.getUserData(_user!.id);
      notifyListeners();
    }
  }

  // Doğum tarihini güncelle
  Future<void> updateBirthDate(DateTime birthDate) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(birthDate: birthDate);
      await _authService.updateUserData(updatedUser);
      _user = updatedUser;
      notifyListeners();
    }
  }

  // Profil fotoğrafını güncelle
  Future<void> updateProfilePhoto(File photoFile) async {
    if (_user != null) {
      try {
        final photoUrl = await _authService.uploadProfilePhoto(
          photoFile,
          _user!.id,
        );
        final updatedUser = _user!.copyWith(photoUrl: photoUrl);
        await _authService.updateUserData(updatedUser);
        _user = updatedUser;
        notifyListeners();
      } catch (e) {
        throw Exception('Profil fotoğrafı yüklenemedi: $e');
      }
    }
  }
}
