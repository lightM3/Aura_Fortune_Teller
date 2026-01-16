import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import 'dart:io';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth get auth {
    if (_auth == null) {
      try {
        _auth = FirebaseAuth.instance;
      } catch (e) {
        throw Exception(
          'Firebase başlatılmamış. Lütfen Firebase.initializeApp() çağırın.',
        );
      }
    }
    return _auth!;
  }

  FirebaseFirestore get firestore {
    if (_firestore == null) {
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        throw Exception(
          'Firebase başlatılmamış. Lütfen Firebase.initializeApp() çağırın.',
        );
      }
    }
    return _firestore!;
  }

  bool get isFirebaseInitialized {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Mevcut kullanıcıyı döndür
  User? get currentUser {
    if (!isFirebaseInitialized) return null;
    return auth.currentUser;
  }

  // Auth state stream
  Stream<User?> get authStateChanges {
    if (!isFirebaseInitialized) {
      return Stream.value(null);
    }
    return auth.authStateChanges();
  }

  // Kullanıcı giriş yap
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (!isFirebaseInitialized) {
      throw Exception('Firebase başlatılmamış');
    }
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Son giriş zamanını güncelle
      await firestore.collection('users').doc(result.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return await getUserData(result.user!.uid);
    } catch (e) {
      throw Exception('Giriş yapılamadı: $e');
    }
  }

  // Kullanıcı kayıt ol
  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String? displayName,
    UserRole role,
  ) async {
    if (!isFirebaseInitialized) {
      throw Exception('Firebase başlatılmamış');
    }
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı bilgilerini Firestore'a kaydet
      UserModel newUser = UserModel(
        id: result.user!.uid,
        email: email,
        displayName:
            displayName ??
            email.split('@')[0], // Eğer displayName yoksa email'den al
        role: role,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toFirestore());

      return newUser;
    } catch (e) {
      throw Exception('Kayıt olunamadı: $e');
    }
  }

  // Kullanıcı çıkış yap
  Future<void> signOut() async {
    if (!isFirebaseInitialized) return;
    await auth.signOut();
  }

  // Kullanıcı verilerini getir
  Future<UserModel?> getUserData(String uid) async {
    if (!isFirebaseInitialized) return null;
    try {
      DocumentSnapshot doc = await firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Kullanıcı verileri alınamadı: $e');
    }
  }

  // Kullanıcı verilerini stream olarak dinle
  Stream<UserModel?> getUserDataStream(String uid) {
    if (!isFirebaseInitialized) {
      return Stream.value(null);
    }
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Profil fotoğrafını yükle
  Future<String> uploadProfilePhoto(File photoFile, String userId) async {
    if (!isFirebaseInitialized) {
      throw Exception('Firebase başlatılmamış');
    }

    try {
      // Storage referansı oluştur
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Fotoğrafı yükle
      final uploadTask = await ref.putFile(photoFile);
      final snapshot = await uploadTask;

      // Download URL al
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Profil fotoğrafı yüklenemedi: $e');
    }
  }

  // Kullanıcı verilerini güncelle
  Future<void> updateUserData(UserModel user) async {
    if (!isFirebaseInitialized) {
      throw Exception('Firebase başlatılmamış');
    }

    try {
      await firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Kullanıcı verileri güncellenemedi: $e');
    }
  }
}
