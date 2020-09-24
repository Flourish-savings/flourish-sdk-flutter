import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreManager {
  FirebaseFirestore _firestore;
  final String userId;
  final FirebaseApp firebaseApp;

  FirestoreManager([this.userId, this.firebaseApp]) {
    _firestore = FirebaseFirestore.instanceFor(app: firebaseApp);
  }

  static Future<FirestoreManager> from([String userId]) async {
    final firebaseApp = await Firebase.initializeApp();
    return FirestoreManager(userId, firebaseApp);
  }

  Stream<DocumentSnapshot> get onNotification {
    return _firestore.collection('users').doc(userId).snapshots();
  }
}
