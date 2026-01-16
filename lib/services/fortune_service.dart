import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/fortune.dart';

class FortuneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yeni fal oluştur
  Future<Fortune> createFortune({
    required String senderId,
    String? senderName,
    required FortuneType type,
    required List<String> content,
    String? userNote,
  }) async {
    try {
      debugPrint(
        'Creating fortune: senderId=$senderId, senderName=$senderName, type=$type, content=$content, userNote=$userNote',
      );

      Fortune fortune = Fortune(
        id: '', // Firestore otomatik ID oluşturacak
        senderId: senderId,
        senderName: senderName,
        type: type,
        content: content,
        status: FortuneStatus.pending,
        userNote: userNote,
      );

      DocumentReference docRef = await _firestore
          .collection('fortunes')
          .add(fortune.toFirestore());

      debugPrint('Fortune created with ID: ${docRef.id}');
      return fortune.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Error creating fortune: $e');
      throw Exception('Fal oluşturulamadı: $e');
    }
  }

  // Fal güncelle (Oracle cevap verdiğinde)
  Future<void> updateFortune({
    required String fortuneId,
    required String response,
  }) async {
    debugPrint('FortuneService: updateFortune called with ID: $fortuneId');
    debugPrint('FortuneService: response length: ${response.length}');

    try {
      debugPrint('FortuneService: Starting Firestore update');
      await _firestore.collection('fortunes').doc(fortuneId).update({
        'response': response,
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FortuneService: Firestore update successful');
    } catch (e, stackTrace) {
      debugPrint('FortuneService: Error in updateFortune: $e');
      debugPrint('FortuneService: Stack trace: $stackTrace');
      throw Exception('Fal güncellenemedi: $e');
    }
  }

  // Kullanıcının falerini getir
  Stream<List<Fortune>> getUserFortunes(String userId) {
    debugPrint('Getting user fortunes for userId: $userId');
    return _firestore
        .collection('fortunes')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            'User fortunes snapshot: ${snapshot.docs.length} documents',
          );
          return snapshot.docs.map((doc) {
            debugPrint('Processing user fortune: ${doc.id}');
            return Fortune.fromFirestore(doc);
          }).toList();
        });
  }

  // Bekleyen faleri getir (Oracle için)
  Stream<List<Fortune>> getPendingFortunes() {
    debugPrint('Getting pending fortunes...');
    return _firestore
        .collection('fortunes')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            'Pending fortunes snapshot: ${snapshot.docs.length} documents',
          );
          return snapshot.docs.map((doc) {
            debugPrint('Processing fortune: ${doc.id}');
            return Fortune.fromFirestore(doc);
          }).toList();
        });
  }

  // Belirli bir falı getir
  Future<Fortune?> getFortune(String fortuneId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('fortunes')
          .doc(fortuneId)
          .get();

      if (doc.exists) {
        return Fortune.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Fal getirilemedi: $e');
    }
  }

  // Falı sil
  Future<void> deleteFortune(String fortuneId) async {
    try {
      await _firestore.collection('fortunes').doc(fortuneId).delete();
    } catch (e) {
      throw Exception('Fal silinemedi: $e');
    }
  }
}
