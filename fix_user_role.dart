import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Kullanıcı rolünü düzelt
  await FirebaseFirestore.instance
      .collection('users')
      .doc('uRFATu5FMEcpGKsnAKzQ6q4pFGF2')
      .update({'role': 'user'});

  print('Kullanıcı rolü user olarak güncellendi');
}
